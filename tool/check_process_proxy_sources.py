"""Offline source-contract checks; not Flutter analysis or Windows validation."""
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[1]
locales = {p.name: json.loads(p.read_text()) for p in (ROOT / 'arb').glob('*.arb')}
base = {k for k in locales['intl_en.arb'] if k.startswith('processProxy')}
for locale, entries in locales.items():
    keys = {k for k in entries if k.startswith('processProxy')}
    assert keys == base, (locale, base - keys, keys - base)
    for key in keys:
        assert set(re.findall(r'\{(\w+)\}', entries[key])) == set(
            re.findall(r'\{(\w+)\}', locales['intl_en.arb'][key])
        ), (locale, key)
references = set()
files = [ROOT / 'lib/services/process_proxy.dart', ROOT / 'lib/views/process_proxy.dart', ROOT / 'lib/views/process_proxy_error.dart']
files += list((ROOT / 'lib/services/process_proxy').glob('*.dart'))
files += list((ROOT / 'lib/views/process_proxy').glob('*.dart'))
for path in files:
    source = path.read_text()
    references.update(re.findall(r'(?<!\.)\b\w+\.(processProxy\w+)', source))
    for uri in re.findall(r"(?:import|export) '([^']+)'", source):
        if uri.startswith('package:fl_clash/'):
            target = ROOT / 'lib' / uri.removeprefix('package:fl_clash/')
        elif ':' not in uri:
            target = path.parent / uri
        else:
            continue
        assert target.is_file(), (path.relative_to(ROOT), uri)
assert references <= base, references - base
workflow = (ROOT / '.github/workflows/process-proxy-checks.yaml').read_text()
assert 'contents: read' in workflow
assert 'secrets.' not in workflow and 'pull_request_target' not in workflow
assert not (ROOT / '.github/workflows/pages.yaml').exists()
assert not (ROOT / '.github/workflows/build.yaml').exists()
print(f'{len(base)} keys x {len(locales)} locales, {len(references)} getter sources, {len(files)} import surfaces checked; no compile claim.')
