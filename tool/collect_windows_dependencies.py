"""Collect only resolved build dependencies, never an entire cache or user home."""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
from urllib.parse import unquote, urlparse
from urllib.request import url2pathname

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "build/package-dependencies"
SKIP_DIRS = {".git", ".dart_tool", ".github", ".idea", ".vscode", "build", "target", "__pycache__"}
SKIP_FILES = {".env", ".netrc", ".npmrc", ".pypirc", ".git-credentials"}
HEADERS = ("ProxyModule.h", "structinfo.h", "InetCompat.h", "ProcessIdentity.h", "AppLauncherProtocol.h")
ABI_COMMIT = "c95248ac8cc790efe0ebaa37383b1008e42c78ce"


def copy_sources(source, target):
    source = source.resolve()
    target.mkdir(parents=True, exist_ok=True)
    for directory, dirs, files in os.walk(source, followlinks=False):
        directory = Path(directory)
        dirs[:] = sorted(d for d in dirs if d not in SKIP_DIRS and not (directory / d).is_symlink())
        relative = directory.relative_to(source)
        (target / relative).mkdir(parents=True, exist_ok=True)
        for name in sorted(files):
            if name in SKIP_FILES or name.startswith(".env."):
                continue
            path = directory / name
            if path.is_symlink() and not path.resolve().is_relative_to(source):
                raise ValueError(f"External source symlink in {source.name}: {relative / name}")
            shutil.copy2(path, target / relative / name)


def package_root(config, uri):
    parsed = urlparse(uri)
    if parsed.scheme == "file":
        if parsed.netloc:
            raise ValueError("Network package root is not allowed")
        return Path(url2pathname(parsed.path)).resolve()
    if parsed.scheme:
        raise ValueError("Unexpected package URI scheme")
    return (config.parent / unquote(uri)).resolve()


def notice_file(path):
    name = path.name.lower()
    return (name.startswith(("license", "licence", "copying", "notice", "copyright"))
            or name in {"authors", "patents", "patent_grant"})


def main():
    if DEST.exists():
        raise ValueError("Dependency output must be fresh")
    DEST.mkdir(parents=True)
    go = DEST / "go/vendor"
    subprocess.run(["go", "mod", "vendor", "-o", str(go)], cwd=ROOT / "core", check=True)
    cargo = DEST / "rust/vendor"
    cargo.parent.mkdir(parents=True)
    result = subprocess.run([
        "cargo", "vendor", "--locked", "--versioned-dirs",
        "--manifest-path", str(ROOT / "plugins/rust_api/rust/Cargo.toml"),
        "--sync", str(ROOT / "services/helper/Cargo.toml"), str(cargo),
    ], cwd=ROOT, check=True, stdout=subprocess.PIPE, text=True)
    config_text = result.stdout.replace(str(cargo).replace("\\", "\\\\"), "vendor").replace(str(cargo), "vendor")
    (cargo.parent / "cargo-vendor-config.toml").write_text(config_text, encoding="utf-8")
    config = ROOT / ".dart_tool/package_config.json"
    packages = json.loads(config.read_text(encoding="utf-8"))["packages"]
    lock = (ROOT / "pubspec.lock").read_text(encoding="utf-8")
    inventory = []
    for package in packages:
        name = package["name"]
        if not re.fullmatch(r"[a-zA-Z0-9_]+", name):
            raise ValueError("Invalid package name")
        source = package_root(config, package["rootUri"])
        if source.is_relative_to(ROOT):
            inventory.append({"package": name, "source": "project source archive"})
            continue
        copy_sources(source, DEST / "dart" / name)
        stanza = re.search(r"(?ms)^  " + re.escape(name) + r":\n.*?(?=^  [a-zA-Z0-9_]+:\n|^sdks:|\Z)", lock)
        inventory.append({"package": name, "lock_entry": stanza.group(0) if stanza else "Flutter SDK package"})
    flutter = Path(os.environ["FLUTTER_ROOT"])
    sdk_notices = DEST / "flutter-notices"
    sdk_notices.mkdir()
    for name in ("LICENSE", "PATENT_GRANT"):
        path = flutter / name
        if path.is_file():
            shutil.copy2(path, sdk_notices / name)
    engine = flutter / "bin/cache/artifacts/engine"
    for path in engine.glob("windows*/LICENSE*"):
        shutil.copy2(path, sdk_notices / f"{path.parent.name}-{path.name}")
    abi = Path(os.environ["RUNNER_TEMP"]) / "ProxyLane"
    revision = subprocess.check_output(["git", "-C", str(abi), "rev-parse", "HEAD"], text=True).strip()
    if revision != ABI_COMMIT:
        raise ValueError("Unexpected ABI source revision")
    target = DEST / "proxylane-interfaces"
    target.mkdir()
    for name in HEADERS:
        shutil.copy2(abi / "src/ProxyLaneHook" / name, target / name)
    shutil.copy2(abi / "third_party/nlohmann/json.hpp", target / "json.hpp")
    for name in ("UPSTREAM-LICENSE", "NLOHMANN-LICENSE"):
        shutil.copy2(ROOT / "windows/proxylane_bridge" / name, target / name)
    notices = ROOT / "build/package-dependency-notices"
    if notices.exists():
        raise ValueError("Notice output must be fresh")
    notices.mkdir()
    for path in DEST.rglob("*"):
        if path.is_file() and notice_file(path):
            relative = path.relative_to(DEST)
            destination = notices / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, destination)
    if not any((notices / "go").rglob("*")) or not any((notices / "rust").rglob("*")):
        raise ValueError("Go and Rust license trees must not be empty")
    manifest = {
        "schema": 1, "dart_packages": inventory,
        "go": "go mod vendor; exact versions in go/vendor/modules.txt and source core/go.sum",
        "rust": "cargo vendor --locked; exact versions in directory names and source Cargo.lock files",
        "flutter_sdk": "https://github.com/flutter/flutter/tree/3.47.6",
        "flutter_engine_revision": (flutter / "bin/internal/engine.version").read_text().strip(),
        "proxylane_interface_commit": ABI_COMMIT,
        "backend_implementation_included": False,
    }
    (DEST / "DEPENDENCIES.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (DEST / "README.md").write_text(
        "# Build dependency source snapshots\n\n"
        "These are the exact resolved Go, Rust, Dart/Flutter framework package sources and ABI headers used by this build, with their own license notices. "
        "No ProxyLane backend implementation is included. Framework/toolchain engine sources are identified by the fixed Flutter tag and engine revision in DEPENDENCIES.json.\n\n"
        "Use alongside the same release's project source ZIP. Go vendor/modules.txt records vendored versions; restore the vendor tree under core/vendor for offline Go builds. "
        "Rust cargo-vendor-config.toml contains the source replacement template; set its vendor directory to the extracted absolute path before using it as Cargo configuration. "
        "Dart package snapshots are under dart/; normal builds resolve pubspec.lock, while offline reconstruction can supply local path overrides. "
        "The companion CMake build validates the official pinned Git revision, so use the documented pinned checkout; the inspected ABI definitions themselves are also preserved here.\n",
        encoding="utf-8")
    print(f"Collected {len(inventory)} Dart package origins and native dependency license trees.")


if __name__ == "__main__":
    main()
