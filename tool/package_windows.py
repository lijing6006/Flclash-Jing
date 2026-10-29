"""Package a compiled Windows app without launching any executable."""
import hashlib
import io
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import struct
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[1]
PROXYLANE_COMMIT = "c95248ac8cc790efe0ebaa37383b1008e42c78ce"
CORE_COMMIT = "c5062921054902b25215a6a933e72ccd714c9bfa"
REQUIRED = (
    "FlClash.exe", "FlClashCore.exe", "FlClashHelperService.exe",
    "FlClashProxyBridge.exe", "flutter_windows.dll", "manifest.json",
    "vcruntime140.dll", "msvcp140.dll", "data/icudtl.dat", "data/app.so",
    "data/flutter_assets/AssetManifest.bin", "data/flutter_assets/NOTICES.Z",
)
EXCLUDED = {"enableloopback.exe"}
FORBIDDEN = {
    "proxylane.exe", "proxylane64.exe", "proxylanehook32.dll",
    "proxylanehook64.dll", "proxylanemitm64.dll",
    "proxylanesecuretransport64.dll", "proxylane.ini",
}


def sha256(path):
    with Path(path).open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def pe_machine(path):
    with Path(path).open("rb") as stream:
        header = stream.read(64)
        if len(header) != 64 or header[:2] != b"MZ":
            raise ValueError(f"Not a PE executable: {path}")
        offset = struct.unpack_from("<I", header, 60)[0]
        if offset < 64 or offset > Path(path).stat().st_size - 6:
            raise ValueError(f"Invalid PE offset: {path}")
        stream.seek(offset)
        signature = stream.read(6)
        if signature[:4] != b"PE\0\0":
            raise ValueError(f"Invalid PE signature: {path}")
        return struct.unpack_from("<H", signature, 4)[0]


def safe_archive_name(name):
    path = PurePosixPath(name)
    if not name or path.is_absolute() or ".." in path.parts or "\\" in name:
        raise ValueError(f"Unsafe archive path: {name}")
    if any(":" in part for part in path.parts):
        raise ValueError(f"Unsafe archive path: {name}")
    return name


def verify_bundle(bundle):
    for name in REQUIRED:
        path = bundle / name
        if not path.is_file() or path.stat().st_size == 0:
            raise ValueError(f"Missing actual application component: {name}")
    for name in REQUIRED[:5]:
        if pe_machine(bundle / name) != 0x8664:
            raise ValueError(f"Expected x64 Windows PE: {name}")
    if not any(p.name.lower().endswith("rust_api.dll") for p in bundle.rglob("*.dll")):
        raise ValueError("Missing compiled Rust native library")
    for path in bundle.rglob("*"):
        if path.is_symlink():
            raise ValueError(f"Unexpected symlink in binary package: {path}")
        if path.name.lower() in FORBIDDEN:
            raise ValueError(f"External backend/config must not be bundled: {path.name}")
        if path.is_file() and path.suffix.lower() in {".key", ".pfx", ".p12", ".pkts"}:
            raise ValueError(f"Sensitive runtime material must not be bundled: {path.name}")


def git(*args, cwd=ROOT):
    return subprocess.check_output(["git", "-C", str(cwd), *args])


def append_archive(output, source, prefix, skip=()):
    with zipfile.ZipFile(io.BytesIO(source)) as archive:
        for entry in archive.infolist():
            name = safe_archive_name(entry.filename)
            if entry.is_dir() or name in skip:
                continue
            output.writestr(prefix + name, archive.read(entry))


def write_json(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def open_output_zip(path):
    return zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED, compresslevel=9, strict_timestamps=False)


def main():
    commit = git("rev-parse", "HEAD").decode().strip()
    if not re.fullmatch(r"[0-9a-f]{40}", commit):
        raise ValueError("Invalid source commit")
    if os.environ.get("GITHUB_SHA", commit) != commit:
        raise ValueError("Checkout differs from workflow commit")
    core = ROOT / "core/Clash.Meta"
    if git("rev-parse", "HEAD", cwd=core).decode().strip() != CORE_COMMIT:
        raise ValueError("Unexpected core submodule")
    if re.search(r"(?m)^\s*build_assets:\s*false", (ROOT / "pubspec.yaml").read_text()):
        raise ValueError("Native build hooks must remain enabled")
    bridge = ROOT / "build/proxylane_bridge/Release/FlClashProxyBridge.exe"
    build = ROOT / "build/windows/x64/runner/Release"
    output = ROOT / "dist/windows-package"
    staging = ROOT / "build/windows-package-staging"
    if output.exists() or staging.exists():
        raise ValueError("Use a clean output directory; existing packages are never overwritten")
    output.mkdir(parents=True)
    shutil.copytree(build, staging, ignore=shutil.ignore_patterns("*.pdb", "*.lib", "*.exp"))
    shutil.copy2(bridge, staging / bridge.name)
    for path in staging.iterdir():
        if path.name.lower() in EXCLUDED:
            path.unlink()
    verify_bundle(staging)
    shutil.copy2(ROOT / "LICENSE", staging / "LICENSE")
    shutil.copytree(ROOT / "licenses/fonts", staging / "licenses/fonts")
    shutil.copy2(ROOT / "docs/process-proxy/WINDOWS_PACKAGE.md", staging / "READ_ME_FIRST.md")
    notices = staging / "licenses/proxylane_bridge"
    notices.mkdir(parents=True)
    for name in ("UPSTREAM-LICENSE", "NLOHMANN-LICENSE"):
        shutil.copy2(ROOT / "windows/proxylane_bridge" / name, notices / name)
    core_license = core / "LICENSE"
    if not core_license.is_file():
        raise ValueError("Core license is required")
    shutil.copy2(core_license, staging / "licenses/Clash.Meta-LICENSE")
    dependency_sources = ROOT / "build/package-dependencies"
    if not (dependency_sources / "DEPENDENCIES.json").is_file():
        raise ValueError("Resolved dependency sources and notices are required")
    shutil.copytree(ROOT / "build/package-dependency-notices", staging / "licenses/dependencies")
    files = [
        {"path": p.relative_to(staging).as_posix(), "bytes": p.stat().st_size, "sha256": sha256(p)}
        for p in sorted(staging.rglob("*")) if p.is_file()
    ]
    manifest = {
        "schema": 1, "source_commit": commit, "core_commit": CORE_COMMIT,
        "proxylane_abi_commit": PROXYLANE_COMMIT, "platform": "windows-x64",
        "flutter": "3.47.6", "go": "1.27.1", "rust": "1.99.0",
        "runtime_tested": False, "signed": False,
        "backend_included": False, "excluded_optional_helper": "EnableLoopback.exe",
        "files": files,
    }
    write_json(staging / "PACKAGE_MANIFEST.json", manifest)
    write_json(output / "PACKAGE_MANIFEST.json", manifest)
    basename = f"Flclash-Jing-windows-x64-preview-{commit[:12]}"
    binary_zip = output / f"{basename}.zip"
    with open_output_zip(binary_zip) as archive:
        for path in sorted(staging.rglob("*")):
            if path.is_file():
                archive.write(path, basename + "/" + path.relative_to(staging).as_posix())
    with zipfile.ZipFile(binary_zip) as archive:
        if archive.testzip() is not None:
            raise ValueError("Binary archive CRC check failed")
        for entry in files:
            data = archive.read(basename + "/" + entry["path"])
            if hashlib.sha256(data).hexdigest() != entry["sha256"]:
                raise ValueError("Binary archive manifest mismatch")
    source_zip = output / f"Flclash-Jing-source-{commit[:12]}.zip"
    prefix = f"Flclash-Jing-source-{commit[:12]}/"
    with open_output_zip(source_zip) as archive:
        append_archive(archive, git("archive", "--format=zip", commit), prefix,
                       skip=("windows/EnableLoopback.exe",))
        append_archive(archive, git("archive", "--format=zip", CORE_COMMIT, cwd=core),
                       prefix + "core/Clash.Meta/")
        archive.writestr(prefix + "PACKAGE_SOURCE.json", json.dumps({
            "commit": commit, "core_commit": CORE_COMMIT,
            "build_recipe": ".github/workflows/windows-package.yaml",
            "dependency_locks": ["pubspec.lock", "core/go.sum",
                                 "plugins/rust_api/rust/Cargo.lock", "services/helper/Cargo.lock"],
            "proxylane_interface_source": f"https://github.com/threatexpert/ProxyLane/tree/{PROXYLANE_COMMIT}",
            "excluded": ["windows/EnableLoopback.exe"],
            "notes": "Core submodule source is included. Resolved dependency and ABI header snapshots are in the companion dependency-source ZIP; SDK/engine source revisions are identified there. No ProxyLane backend binary or user data is included."
        }, indent=2) + "\n")
    with zipfile.ZipFile(source_zip) as archive:
        if archive.testzip() is not None:
            raise ValueError("Source archive CRC check failed")
    dependency_zip = output / f"Flclash-Jing-dependency-source-{commit[:12]}.zip"
    with open_output_zip(dependency_zip) as archive:
        for path in sorted(dependency_sources.rglob("*")):
            if path.is_file():
                archive.write(path, "dependencies/" + path.relative_to(dependency_sources).as_posix())
    with zipfile.ZipFile(dependency_zip) as archive:
        if archive.testzip() is not None:
            raise ValueError("Dependency archive CRC check failed")
    notes = f"""# Windows x64 实验预览 / Experimental preview

源码 / Source: {commit}
完整 Flutter release 应用及 Go/Rust 核心、原生 companion；不是只有桥接程序。
下载 **{binary_zip.name}**，完整解压后运行其中的 **FlClash.exe**。不要只拷贝单个 EXE。

**仍须自行选择官方 ProxyLane v1.3.5 完整安装，才能使用进程代理。后端 DLL 未包含。**
HTTPS/QUIC 解密、录制及证书信任不会因下载或解压而开启；每项仍须显式确认。
本包未数字签名；构建与静态产物校验不等于真实 Windows 代理/注入/证书运行验收。
不建议替换正在使用的稳定安装，不要关闭安全软件。与上游可能共用配置，首次启动前备份。
许可证来源未确认的可选 EnableLoopback.exe 未打包；UWP loopback 辅助按钮不可用，Win32 进程代理不依赖它。

This is the actual Flutter desktop application with its Go/Rust runtime and compiled stdio companion.
Extract the complete portable ZIP and launch FlClash.exe; it is not a standalone single-file executable.
The separately obtained official ProxyLane 1.3.5 backend is still required and is NOT redistributed.
Unsigned experimental build: successful compilation is not real process/traffic/certificate validation.
The optional inherited UWP loopback utility is omitted pending redistribution-license verification.
Corresponding project/core and resolved dependency sources, audited ABI headers, build recipe, licenses and SHA256SUMS accompany this release.
"""
    (output / "RELEASE_NOTES.md").write_text(notes, encoding="utf-8")
    checksummed = [binary_zip, source_zip, dependency_zip, output / "PACKAGE_MANIFEST.json", output / "RELEASE_NOTES.md"]
    (output / "SHA256SUMS").write_text(
        "".join(f"{sha256(p)}  {p.name}\n" for p in checksummed), encoding="ascii")
    print(json.dumps({"source_commit": commit, "artifacts": [
        {"file": p.name, "bytes": p.stat().st_size, "sha256": sha256(p)}
        for p in checksummed]}, indent=2))


if __name__ == "__main__":
    main()
