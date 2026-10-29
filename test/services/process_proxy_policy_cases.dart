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
  'rejects direct mode instead of pretending selected node is used': () {
    const runtime = ProcessProxyRuntime(
      running: true,
      safeMode: false,
      systemProxy: false,
      tunEnabled: false,
      directMode: true,
      mixedPort: 9527,
      socksPort: 0,
      httpPort: 0,
    );
    _fails(() => runtime.endpoint, 'directMode');
  },
  'rejects wildcard and dot-segment executable paths': () {
    for (final path in [r'C:\*.exe', r'C:\app?.exe', r'C:\tools\..\app.exe']) {
      _fails(() => validateExecutablePath(path), 'invalidExecutable');
    }
  },
  'working directory is local and explicit with no network or dot paths': () {
    validateWorkingDirectoryPath(r'C:\Apps\Profile');
    validateWorkingDirectoryPath('');
    for (final path in [
      r'\\server\share',
      r'C:\Apps\..',
      r'C:\*',
      'relative',
      r'C:\Apps:other',
    ]) {
      _fails(
        () => validateWorkingDirectoryPath(path),
        'invalidWorkingDirectory',
      );
    }
  },
  'QUIC preparation consent is never persisted and requires UDP': () {
    const request = ProcessProxyLaunchRequest(
      backendPath: r'C:\Tools\ProxyLane64.exe',
      executable: r'C:\Apps\app.exe',
      prepareQuic: true,
      trustedBackend: true,
    );
    _fails(request.validate, 'quicNeedsUdp');
    _check(!request.toJson().containsKey('prepareQuic'));
    _check(!ProcessProxyLaunchRequest.fromJson(request.toJson()).prepareQuic);
  },
  'Windows paths share the audited backend UTF8 byte limit': () {
    _fails(() => validateExecutablePath('C:\\${'中' * 80}.exe'), 'pathTooLong');
    _fails(
      () => validateWorkingDirectoryPath('C:\\${'中' * 80}'),
      'pathTooLong',
    );
    validateExecutablePath(r'C:\应用\工具.exe');
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
  'rejects invalid numeric IP instead of treating it as domain': () {
    _fails(
      () => compileBypassRules('999.999.1.2', privateNetworks: false),
      'invalidBypassRule',
    );
  },
  'normalizes literal IPv6 to backend representation': () {
    final rules = compileBypassRules(
      '2001:0DB8:0:0:0:0:0:1',
      privateNetworks: false,
    );
    _check(rules.contains('[2001:db8::1]:*'));
  },
  'enforces actual backend credential buffer length': () {
    _fails(
      () => buildProcessProxyIni(
        _request,
        ProcessProxyEndpoint('SOCKS5', 9527, 'user', 'x' * 128),
        'FlClash_test',
      ),
      'invalidAuthentication',
    );
  },
  'rejects quote-delimited INI credentials rather than silently changing them':
      () {
        _fails(
          () => buildProcessProxyIni(
            _request,
            const ProcessProxyEndpoint('SOCKS5', 9527, 'user', "'secret'"),
            'FlClash_test',
          ),
          'invalidAuthentication',
        );
      },
  'proxy-only targets do not accidentally include loopback or private defaults':
      () {
        _check(compileProxyOnlyRules('').isEmpty);
        final rules = compileProxyOnlyRules('*.example.com');
        _check(
          rules.length == 2 &&
              rules.contains('example.com:*') &&
              rules.contains('*.example.com:*'),
        );
        _check(!rules.any((r) => r.startsWith('127.') || r.startsWith('10.')));
      },
  'proxy-only targets reuse strict domain IP CIDR validation': () {
    _check(compileProxyOnlyRules('192.0.2.0/24').single == '192.0.2.*:*');
    _fails(() => compileProxyOnlyRules('*'), 'invalidBypassRule');
    _fails(() => compileProxyOnlyRules('host;other'), 'invalidBypassRule');
  },
  'child basename globs compile explicitly to full-path suffix matches': () {
    final rules = compileChildRules('chrome.exe\n*helper?.exe\n# note');
    _check(rules.join('|') == r'*\chrome.exe|*\*helper?.exe');
    _check(compileChildRules('').isEmpty);
  },
  'child absolute directory globs retain Windows semantics': () {
    _check(
      compileChildRules(r'C:\Program Files\Browser\*').single ==
          r'C:\Program Files\Browser\*',
    );
    _check(
      compileChildRules('C:/Apps/helper.exe').single == r'C:\Apps\helper.exe',
    );
  },
  'child filters reject shell separators devices UNC and dot paths': () {
    for (final rule in [
      r'\\server\*.exe',
      r'\\?\C:\Apps\a.exe',
      r'C:\Apps\..\a.exe',
      'a.exe;b.exe',
      'a.exe|b.exe',
      'relative/path.exe',
      'tool.cmd',
    ]) {
      _fails(() => compileChildRules(rule), 'invalidChildRule');
    }
  },
  'child filter UTF8 size matches the backend byte limit': () {
    _fails(() => compileChildRules('${'中' * 80}.exe'), 'invalidChildRule');
  },
  'child filters deduplicate and enforce a bounded pattern list': () {
    _check(compileChildRules('a.exe\na.exe').length == 1);
    _fails(
      () => compileChildRules(
        [for (var i = 0; i < 129; i++) '$i.exe'].join('\n'),
      ),
      'tooManyRules',
    );
  },
  'new filter settings persist without any sensitive consent': () {
    const request = ProcessProxyLaunchRequest(
      backendPath: r'C:\ProxyLane\ProxyLane64.exe',
      executable: r'C:\Apps\app.exe',
      proxyOnlyRules: 'example.com',
      childRules: 'helper.exe',
      childRuleInclude: true,
      prepareQuic: true,
      trustedBackend: true,
    );
    final restored = ProcessProxyLaunchRequest.fromJson(request.toJson());
    _check(
      restored.proxyOnlyRules == 'example.com' &&
          restored.childRules == 'helper.exe' &&
          restored.childRuleInclude,
    );
    _check(!restored.prepareQuic && !restored.trustedBackend);
  },
  'native credentials preserve quotes and edge spaces without INI roundtrip':
      () {
        validateProcessProxyAuthentication(
          const ProcessProxyEndpoint('SOCKS5', 9527, ' user ', '"quoted"'),
        );
      },
  'native credentials reject all control bytes and actual backend size overflow':
      () {
        for (final password in ['secret\tvalue', 'secret\x7f', 'x' * 128]) {
          _fails(
            () => validateProcessProxyAuthentication(
              ProcessProxyEndpoint('SOCKS5', 9527, 'user', password),
            ),
            'invalidAuthentication',
          );
        }
      },
  'settings JSON round trip': () {
    final restored = ProcessProxyLaunchRequest.fromJson(
      jsonDecode(jsonEncode(_request.toJson())) as Map<String, dynamic>,
    );
    _check(restored.executable == _request.executable);
  },
};
