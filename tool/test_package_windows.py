import io
from pathlib import Path
import struct
import tempfile
import unittest
import zipfile

from collect_windows_dependencies import copy_sources, notice_file, package_root

from package_windows import (
    FORBIDDEN, REQUIRED, append_archive, pe_machine, safe_archive_name, verify_bundle,
)


def pe_bytes(machine=0x8664):
    value = bytearray(70)
    value[:2] = b"MZ"
    struct.pack_into("<I", value, 60, 64)
    value[64:68] = b"PE\0\0"
    struct.pack_into("<H", value, 68, machine)
    return bytes(value)


class PackageTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for name in REQUIRED:
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(pe_bytes() if name in REQUIRED[:5] else b"fixture")
        (self.root / "rust_api.dll").write_bytes(pe_bytes())

    def test_full_app_contract(self):
        verify_bundle(self.root)

    def test_bridge_only_is_not_an_application(self):
        for name in REQUIRED:
            if name != "FlClashProxyBridge.exe":
                (self.root / name).unlink()
        with self.assertRaises(ValueError):
            verify_bundle(self.root)

    def test_every_required_component_must_exist(self):
        for name in REQUIRED:
            with self.subTest(name=name):
                path = self.root / name
                content = path.read_bytes()
                path.unlink()
                with self.assertRaises(ValueError):
                    verify_bundle(self.root)
                path.write_bytes(content)

    def test_empty_component_rejected(self):
        (self.root / "data/app.so").write_bytes(b"")
        with self.assertRaises(ValueError):
            verify_bundle(self.root)

    def test_missing_rust_library_rejected(self):
        (self.root / "rust_api.dll").unlink()
        with self.assertRaises(ValueError):
            verify_bundle(self.root)

    def test_non_executable_rejected(self):
        (self.root / "FlClash.exe").write_bytes(b"not a real executable")
        with self.assertRaises(ValueError):
            verify_bundle(self.root)

    def test_wrong_architecture_rejected(self):
        (self.root / "FlClash.exe").write_bytes(pe_bytes(0x14C))
        with self.assertRaises(ValueError):
            verify_bundle(self.root)

    def test_pe_offset_and_signature_checked(self):
        path = self.root / "sample.exe"
        data = bytearray(pe_bytes())
        struct.pack_into("<I", data, 60, 0xFFFFFFFF)
        path.write_bytes(data)
        with self.assertRaises(ValueError):
            pe_machine(path)
        data = bytearray(pe_bytes())
        data[64] = 0
        path.write_bytes(data)
        with self.assertRaises(ValueError):
            pe_machine(path)

    def test_external_backend_and_ini_rejected(self):
        for name in FORBIDDEN:
            with self.subTest(name=name):
                path = self.root / name.upper()
                path.write_bytes(b"fixture")
                with self.assertRaises(ValueError):
                    verify_bundle(self.root)
                path.unlink()

    def test_private_runtime_material_rejected(self):
        for name in ("ca.key", "ca.pfx", "ca.p12", "capture.pkts"):
            path = self.root / name
            path.write_bytes(b"fixture")
            with self.assertRaises(ValueError):
                verify_bundle(self.root)
            path.unlink()

    def test_archive_traversal_rejected(self):
        for name in ("", "/absolute", "../escape", "a/../../b", r"a\b", "C:/drive"):
            with self.subTest(name=name):
                with self.assertRaises(ValueError):
                    safe_archive_name(name)
        self.assertEqual(safe_archive_name("core/LICENSE"), "core/LICENSE")

    def test_source_archive_preserves_license_and_excludes_optional_binary(self):
        source = io.BytesIO()
        with zipfile.ZipFile(source, "w") as archive:
            archive.writestr("LICENSE", "fixture license")
            archive.writestr("windows/EnableLoopback.exe", b"fixture binary")
        result = io.BytesIO()
        with zipfile.ZipFile(result, "w") as archive:
            append_archive(archive, source.getvalue(), "src/",
                           skip=("windows/EnableLoopback.exe",))
        with zipfile.ZipFile(result) as archive:
            self.assertEqual(archive.namelist(), ["src/LICENSE"])
            self.assertEqual(archive.read("src/LICENSE"), b"fixture license")


class DependencySourceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def test_copy_keeps_sources_and_license_but_not_cache_or_credentials(self):
        source = self.root / "package"
        source.mkdir()
        for name in ("LICENSE", "library.dart", ".env", ".netrc"):
            (source / name).write_text("fixture")
        (source / ".git").mkdir()
        (source / ".git/config").write_text("fixture")
        (source / "build").mkdir()
        (source / "build/cache").write_text("fixture")
        target = self.root / "snapshot"
        copy_sources(source, target)
        self.assertEqual(sorted(p.name for p in target.iterdir()), ["LICENSE", "library.dart"])

    def test_notice_names(self):
        for name in ("LICENSE-MIT", "COPYING", "NOTICE.txt", "Copyright", "PATENT_GRANT"):
            self.assertTrue(notice_file(Path(name)))
        self.assertFalse(notice_file(Path("main.rs")))

    def test_relative_package_root(self):
        config = self.root / ".dart_tool/package_config.json"
        self.assertEqual(package_root(config, "../dependency/"), self.root / "dependency")

    def test_file_uri_package_root(self):
        self.assertEqual(package_root(self.root / "config.json", self.root.as_uri()), self.root)

    def test_network_package_root_rejected(self):
        with self.assertRaises(ValueError):
            package_root(self.root / "config.json", "https://example.test/package")
        with self.assertRaises(ValueError):
            package_root(self.root / "config.json", "file://server/package")


if __name__ == "__main__":
    unittest.main()
