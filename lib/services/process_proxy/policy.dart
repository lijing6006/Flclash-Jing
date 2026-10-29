import 'dart:convert';
import 'dart:io';

class ProcessProxyException implements Exception {
  final String code;
  final String? detail;

  const ProcessProxyException(this.code, [this.detail]);

  @override
  String toString() => detail == null ? code : '$code: $detail';
}

class ProcessProxyRuntime {
  final bool running;
  final bool safeMode;
  final bool systemProxy;
  final bool tunEnabled;
  final bool directMode;
  final int mixedPort;
  final int socksPort;
  final int httpPort;
  final String username;
  final String password;

  const ProcessProxyRuntime({
    required this.running,
    required this.safeMode,
    required this.systemProxy,
    required this.tunEnabled,
    required this.mixedPort,
    required this.socksPort,
    required this.httpPort,
    this.directMode = false,
    this.username = '',
    this.password = '',
  });

  ProcessProxyEndpoint get endpoint {
    if (!running) throw const ProcessProxyException('coreNotRunning');
    if (safeMode) throw const ProcessProxyException('safeMode');
    if (directMode) throw const ProcessProxyException('directMode');
    if (systemProxy || tunEnabled) {
      throw const ProcessProxyException('globalProxyEnabled');
    }
    for (final port in [mixedPort, socksPort]) {
      if (port > 0 && port <= 65535) {
        return ProcessProxyEndpoint('SOCKS5', port, username, password);
      }
    }
    if (httpPort > 0 && httpPort <= 65535) {
      return ProcessProxyEndpoint('HTTP11', httpPort, username, password);
    }
    throw const ProcessProxyException('noListener');
  }
}

class ProcessProxyEndpoint {
  final String type;
  final int port;
  final String username;
  final String password;

  const ProcessProxyEndpoint(
    this.type,
    this.port,
    this.username,
    this.password,
  );

  bool sameAs(ProcessProxyEndpoint other) =>
      type == other.type &&
      port == other.port &&
      username == other.username &&
      password == other.password;

  @override
  String toString() => '$type 127.0.0.1:$port';
}

class ProcessProxyLaunchRequest {
  final String backendPath;
  final String executable;
  final List<String> arguments;
  final String workingDirectory;
  final bool prepareQuic;
  final String bypassRules;
  final bool includeChildren;
  final bool bypassPrivateNetworks;
  final bool blockUdp;
  final bool remoteDns;
  final bool trustedBackend;
  final bool decryptHttps;
  final bool decryptQuic;

  const ProcessProxyLaunchRequest({
    required this.backendPath,
    required this.executable,
    this.arguments = const [],
    this.workingDirectory = '',
    this.prepareQuic = false,
    this.bypassRules = '',
    this.includeChildren = true,
    this.bypassPrivateNetworks = true,
    this.blockUdp = true,
    this.remoteDns = false,
    this.trustedBackend = false,
    this.decryptHttps = false,
    this.decryptQuic = false,
  });

  Map<String, Object> toJson() => {
    'backendPath': backendPath,
    'executable': executable,
    'arguments': arguments,
    'workingDirectory': workingDirectory,
    'bypassRules': bypassRules,
    'includeChildren': includeChildren,
    'bypassPrivateNetworks': bypassPrivateNetworks,
    'blockUdp': blockUdp,
    'remoteDns': remoteDns,
  };

  factory ProcessProxyLaunchRequest.fromJson(Map<String, dynamic> json) {
    return ProcessProxyLaunchRequest(
      backendPath: json['backendPath'] as String? ?? '',
      executable: json['executable'] as String? ?? '',
      arguments: (json['arguments'] as List? ?? []).cast<String>(),
      workingDirectory: json['workingDirectory'] as String? ?? '',
      bypassRules: json['bypassRules'] as String? ?? '',
      includeChildren: json['includeChildren'] as bool? ?? true,
      bypassPrivateNetworks: json['bypassPrivateNetworks'] as bool? ?? true,
      blockUdp: json['blockUdp'] as bool? ?? true,
      remoteDns: json['remoteDns'] as bool? ?? false,
    );
  }

  void validate() {
    if (!trustedBackend) throw const ProcessProxyException('backendNotTrusted');
    validateExecutablePath(backendPath);
    validateExecutablePath(executable);
    validateWorkingDirectoryPath(workingDirectory);
    if (!backendPath
        .replaceAll('/', r'\')
        .toLowerCase()
        .endsWith(r'\proxylane64.exe')) {
      throw const ProcessProxyException('backendName');
    }
    if (arguments.length > 128 ||
        arguments.fold<int>(0, (n, a) => n + a.length) > 16000 ||
        arguments.any((a) => a.contains('\x00'))) {
      throw const ProcessProxyException('invalidArguments');
    }
    if ((decryptQuic || prepareQuic) && blockUdp) {
      throw const ProcessProxyException('quicNeedsUdp');
    }
    compileBypassRules(bypassRules, privateNetworks: bypassPrivateNetworks);
  }
}

void validateExecutablePath(String path) {
  if (!RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(path) ||
      !path.toLowerCase().endsWith('.exe') ||
      path.contains(RegExp(r'[\x00-\x1f"<>|*?]')) ||
      path.substring(2).contains(':') ||
      path.split(RegExp(r'[\\/]')).any((part) => part == '.' || part == '..') ||
      path.length > 240) {
    throw const ProcessProxyException('invalidExecutable');
  }
}

void validateWorkingDirectoryPath(String path) {
  if (path.isEmpty) return;
  if (!RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(path) ||
      path.contains(RegExp(r'[\x00-\x1f"<>|*?]')) ||
      path.substring(2).contains(':') ||
      path.split(RegExp(r'[\\/]')).any((part) => part == '.' || part == '..') ||
      path.length > 240) {
    throw const ProcessProxyException('invalidWorkingDirectory');
  }
}

List<String> parseProcessArguments(String value) {
  try {
    final decoded = jsonDecode(value.trim().isEmpty ? '[]' : value);
    if (decoded is! List || decoded.any((a) => a is! String)) {
      throw const FormatException();
    }
    return decoded.cast<String>();
  } catch (_) {
    throw const ProcessProxyException('invalidArguments');
  }
}

List<String> compileBypassRules(String text, {required bool privateNetworks}) {
  if (text.length > 16384) throw const ProcessProxyException('tooManyRules');
  final rules = <String>{'localhost:*', '127.*:*', '[::1]:*'};
  if (privateNetworks) {
    rules.addAll([
      '10.*:*',
      for (var n = 16; n <= 31; n++) '172.$n.*:*',
      '192.168.*:*',
      '169.254.*:*',
      '[fc*]:*',
      '[fd*]:*',
      '[fe8*]:*',
      '[fe9*]:*',
      '[fea*]:*',
      '[feb*]:*',
    ]);
  }
  for (final raw in const LineSplitter().convert(text)) {
    final rule = raw.trim().toLowerCase();
    if (rule.isEmpty || rule.startsWith('#')) continue;
    if (rule.length > 255 || rule.contains(RegExp(r'[\s|;=\\\x00-\x1f]'))) {
      throw ProcessProxyException('invalidBypassRule', raw);
    }
    if (rule.contains('/')) {
      rules.addAll(_ipv4CidrPatterns(rule));
    } else {
      final ip = InternetAddress.tryParse(rule);
      if (ip != null) {
        rules.add(
          ip.type == InternetAddressType.IPv6
              ? '[${_canonicalIpv6(ip)}]:*'
              : '${ip.address}:*',
        );
      } else if (!RegExp(r'^[0-9.]+$').hasMatch(rule) &&
          RegExp(
            r'^(\*\.)?([a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)*[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$',
          ).hasMatch(rule)) {
        if (rule.startsWith('*.')) rules.add('${rule.substring(2)}:*');
        rules.add('$rule:*');
      } else {
        throw ProcessProxyException('invalidBypassRule', raw);
      }
    }
    if (rules.length > 512) throw const ProcessProxyException('tooManyRules');
  }
  return rules.toList(growable: false);
}

String _canonicalIpv6(InternetAddress address) {
  final bytes = address.rawAddress;
  if (bytes.take(10).every((b) => b == 0) &&
      bytes[10] == 255 &&
      bytes[11] == 255) {
    return '::ffff:${bytes.skip(12).join('.')}';
  }
  final words = [
    for (var i = 0; i < 16; i += 2) (bytes[i] << 8) | bytes[i + 1],
  ];
  var bestStart = -1;
  var bestLength = 1;
  for (var i = 0; i < words.length;) {
    if (words[i] != 0) {
      i++;
      continue;
    }
    final start = i;
    while (i < words.length && words[i] == 0) {
      i++;
    }
    if (i - start > bestLength) {
      bestStart = start;
      bestLength = i - start;
    }
  }
  final hex = words.map((word) => word.toRadixString(16)).toList();
  if (bestStart < 0) return hex.join(':');
  return '${hex.take(bestStart).join(':')}::${hex.skip(bestStart + bestLength).join(':')}';
}

Iterable<String> _ipv4CidrPatterns(String input) sync* {
  final parts = input.split('/');
  final address = InternetAddress.tryParse(parts.first);
  final bits = parts.length == 2 ? int.tryParse(parts.last) : null;
  if (address == null ||
      address.type != InternetAddressType.IPv4 ||
      bits == null ||
      bits < 8 ||
      bits > 32) {
    throw ProcessProxyException('unsupportedCidr', input);
  }
  final octets = address.rawAddress;
  final complete = bits ~/ 8;
  final remainder = bits % 8;
  final prefixes = octets.take(complete).toList();
  if (remainder == 0) {
    yield '${prefixes.join('.')}${complete < 4 ? '.*' : ''}:*';
    return;
  }
  final size = 1 << (8 - remainder);
  final start = octets[complete] & (256 - size);
  for (var n = start; n < start + size; n++) {
    yield '${[...prefixes, n].join('.')}${complete < 3 ? '.*' : ''}:*';
  }
}

String buildProcessProxyIni(
  ProcessProxyLaunchRequest request,
  ProcessProxyEndpoint endpoint,
  String profile,
) {
  if (!RegExp(r'^FlClash_[a-zA-Z0-9_]+$').hasMatch(profile)) {
    throw const ProcessProxyException('invalidProfile');
  }
  for (final value in [endpoint.username, endpoint.password]) {
    if (value != value.trim() ||
        value.contains(RegExp(r'''[\r\n\x00"']''')) ||
        utf8.encode(value).length > 127) {
      throw const ProcessProxyException('invalidAuthentication');
    }
  }
  final filters = compileBypassRules(
    request.bypassRules,
    privateNetworks: request.bypassPrivateNetworks,
  );
  int flag(bool value) => value ? 1 : 0;
  return [
    '; Flclash-Jing isolated session. Never import existing backend preferences.',
    '[options]',
    'lastselected=$profile',
    'DecryptHTTPS=${flag(request.decryptHttps)}',
    'DecryptQUIC=${flag(request.decryptQuic)}',
    'MitmSkipUpstreamVerify=0',
    '[recording]',
    'Enabled=0',
    '[proxy_$profile]',
    'HookChildProcess=${flag(request.includeChildren)}',
    'HookTCP=1',
    'HookUDP=${flag(!request.blockUdp && endpoint.type == 'SOCKS5')}',
    'BlockUDP=${flag(request.blockUdp || endpoint.type != 'SOCKS5')}',
    'BlockIPv6=0',
    'dnsOpt=${flag(request.remoteDns)}',
    'RedirectPrivateDNS=0',
    'RedirectDNS=',
    'ChildFilter=',
    'ChildFilterMode=0',
    'TargetFilter=${filters.join('|')}',
    'TargetFilterMode=0',
    'Type=${endpoint.type}',
    'Host=127.0.0.1',
    'Port=${endpoint.port}',
    'User=${endpoint.username}',
    'Pass=${endpoint.password}',
    'Transport=PLAIN',
    'PSK=',
    '',
  ].join('\r\n');
}

List<int> encodeProcessProxyIni(String text) => [
  0xff,
  0xfe,
  for (final unit in text.codeUnits) ...[unit & 0xff, unit >> 8],
];
