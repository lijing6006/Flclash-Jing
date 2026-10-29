import 'dart:convert';

import '../../lib/services/process_proxy/policy.dart';

void _check(bool condition) {
  if (!condition) throw StateError('Assertion failed');
}

void _fails(void Function() action, String code) {
  try {
    action();
  } on ProcessProxyException catch (error) {
    _check(error.code == code);
    return;
  }
  throw StateError('Expected $code');
}

ProcessProxyRuntime _runtime({
  bool running = true,
  bool safeMode = false,
  bool systemProxy = false,
  bool tunEnabled = false,
  int mixed = 9527,
  int socks = 0,
  int http = 0,
}) => ProcessProxyRuntime(
  running: running,
  safeMode: safeMode,
  systemProxy: systemProxy,
  tunEnabled: tunEnabled,
  mixedPort: mixed,
  socksPort: socks,
  httpPort: http,
);

const _request = ProcessProxyLaunchRequest(
  backendPath: r'C:\Tools\ProxyLane64.exe',
  executable: r'C:\Program Files\Browser\browser.exe',
  trustedBackend: true,
);

final Map<String, void Function()> processProxyPolicyCases = {
  'uses non-default configured mixed port': () {
    _check(_runtime().endpoint.port == 9527);
  },
  'uses SOCKS fallback before HTTP': () {
    _check(_runtime(mixed: 0, socks: 1085, http: 8888).endpoint.port == 1085);
  },
  'uses HTTP only when SOCKS disabled': () {
    _check(_runtime(mixed: 0, http: 8888).endpoint.type == 'HTTP11');
  },
  'rejects stopped core': () {
    _fails(() => _runtime(running: false).endpoint, 'coreNotRunning');
  },
  'rejects safe mode': () {
    _fails(() => _runtime(safeMode: true).endpoint, 'safeMode');
  },
  'rejects system proxy takeover': () {
    _fails(() => _runtime(systemProxy: true).endpoint, 'globalProxyEnabled');
  },
  'rejects TUN takeover': () {
    _fails(() => _runtime(tunEnabled: true).endpoint, 'globalProxyEnabled');
  },
  'rejects disabled or invalid listeners': () {
    _fails(() => _runtime(mixed: 0).endpoint, 'noListener');
    _fails(() => _runtime(mixed: 70000, socks: -1).endpoint, 'noListener');
  },
  'rejects UNC and script targets': () {
    for (final path in [r'\\server\app.exe', r'C:\app.cmd', 'app.exe']) {
      _fails(() => validateExecutablePath(path), 'invalidExecutable');
    }
  },
  'rejects alternate data streams and control characters': () {
    for (final path in [r'C:\app:evil.exe', 'C:\\bad\nname.exe']) {
      _fails(() => validateExecutablePath(path), 'invalidExecutable');
    }
  },
  'preserves arguments without shell evaluation': () {
    final args = parseProcessArguments(r'["a b", "&whoami", "--", ""]');
    _check(args.length == 4 && args[1] == '&whoami' && args.last.isEmpty);
  },
  'rejects malformed arguments': () {
    for (final input in ['foo', '{}', '[1]', '["unterminated]']) {
      _fails(() => parseProcessArguments(input), 'invalidArguments');
    }
  },
  'requires backend trust each session': () {
    final restored = ProcessProxyLaunchRequest.fromJson(_request.toJson());
    _check(!restored.trustedBackend);
    _fails(restored.validate, 'backendNotTrusted');
  },
  'does not persist decrypt permission': () {
    final json = _request.toJson()..['decryptHttps'] = true;
    final restored = ProcessProxyLaunchRequest.fromJson(json);
    _check(!restored.decryptHttps && !restored.decryptQuic);
  },
  'defaults local DNS and blocks UDP': () {
    _check(!_request.remoteDns && _request.blockUdp);
  },
  'wildcard domain includes apex': () {
    final rules = compileBypassRules('*.example.com', privateNetworks: false);
    _check(rules.contains('*.example.com:*'));
    _check(rules.contains('example.com:*'));
  },
  'deduplicates rules and ignores comments': () {
    final rules = compileBypassRules(
      '# notes\nExample.COM\nexample.com\n',
      privateNetworks: false,
    );
    _check(rules.where((r) => r == 'example.com:*').length == 1);
  },
  'always bypasses loopback without global wildcard': () {
    final rules = compileBypassRules('', privateNetworks: false);
    _check(rules.contains('127.*:*') && rules.contains('[::1]:*'));
    _check(!rules.contains('*:*'));
  },
  'private ranges stay within RFC1918': () {
    final rules = compileBypassRules('', privateNetworks: true);
    _check(rules.contains('172.16.*:*') && rules.contains('172.31.*:*'));
    _check(!rules.contains('172.*:*') && !rules.contains('172.32.*:*'));
  },
  'expands non-octet IPv4 CIDR exactly': () {
    final rules = compileBypassRules('172.16.0.0/12', privateNetworks: false);
    _check(rules.where((r) => r.startsWith('172.')).length == 16);
    _check(rules.contains('172.31.*:*') && !rules.contains('172.32.*:*'));
  },
  'expands host CIDR and smaller subnet': () {
    final rules = compileBypassRules(
      '192.0.2.5/32\n192.0.2.128/25',
      privateNetworks: false,
    );
    _check(rules.contains('192.0.2.5:*') && rules.contains('192.0.2.255:*'));
    _check(!rules.contains('192.0.2.127:*'));
  },
  'rejects IPv6 CIDR and overly broad CIDR instead of ignoring': () {
    for (final input in ['::/0', '0.0.0.0/0', '1.2.3.4/33']) {
      _fails(
        () => compileBypassRules(input, privateNetworks: false),
        'unsupportedCidr',
      );
    }
  },
  'rejects INI and wildcard injections': () {
    for (final input in [
      '*',
      '*:*',
      'foo|bar',
      'foo;bar',
      'foo=bar',
      '[options]',
      'https://example.com',
    ]) {
      try {
        compileBypassRules(input, privateNetworks: false);
      } on ProcessProxyException {
        continue;
      }
      throw StateError('Accepted unsafe rule');
    }
  },
  'safe INI contract and dynamic port': () {
    final ini = buildProcessProxyIni(
      _request,
      _runtime().endpoint,
      'FlClash_test',
    );
    for (final line in [
      'Host=127.0.0.1',
      'Port=9527',
      'DecryptHTTPS=0',
      'DecryptQUIC=0',
      'MitmSkipUpstreamVerify=0',
      'RedirectPrivateDNS=0',
      'dnsOpt=0',
      'TargetFilterMode=0',
      'ChildFilterMode=0',
      'Enabled=0',
    ]) {
      _check(ini.contains('$line\r\n'));
    }
    _check(!ini.contains('7890') && !ini.contains('8.8.8.8'));
  },
  'credentials are not displayed by endpoint': () {
    const endpoint = ProcessProxyEndpoint('SOCKS5', 9888, 'user', 'secret');
    _check(!endpoint.toString().contains('secret'));
  },
  'rejects INI credential injection': () {
    _fails(
      () => buildProcessProxyIni(
        _request,
        const ProcessProxyEndpoint('SOCKS5', 9527, 'user', '\n[options]'),
        'FlClash_test',
      ),
      'invalidAuthentication',
    );
  },
  'writes UTF16LE with BOM for Windows INI': () {
    final bytes = encodeProcessProxyIni('中文');
    _check(bytes.length == 6 && bytes[0] == 255 && bytes[1] == 254);
    _check(bytes[2] == 0x2d && bytes[3] == 0x4e);
  },
  'settings JSON round trip': () {
    final restored = ProcessProxyLaunchRequest.fromJson(
      jsonDecode(jsonEncode(_request.toJson())) as Map<String, dynamic>,
    );
    _check(restored.executable == _request.executable);
  },
};
