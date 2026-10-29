// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(count) =>
      "${Intl.plural(count, other: '${count} selected')}";

  static String m1(name) => "Added ${name} to local proxies";

  static String m2(name) => "${name} is already in local proxies";

  static String m3(count, skipped) =>
      "${count} to add, ${skipped} skipped as existing";

  static String m4(detail) => "Couldn\'t clear the data: ${detail}";

  static String m5(code) =>
      "Windows refused to run FlClashCore.exe (error ${code}). An app control policy such as Smart App Control or AppLocker blocks unsigned programs; allow FlClash in that policy or turn it off, then try again.";

  static String m6(name) =>
      "The app failed to finish launching twice in a row. To break the loop, the profile ${name} has been deselected and automatic setup was skipped. You can select it again at any time.";

  static String m7(url) => "Do you want to create a profile from ${url}?";

  static String m8(count, label) =>
      "${Intl.plural(count, one: '1 SUB-RULE rule was dropped, since custom profiles do not support sub-rules', other: '${label} SUB-RULE rules were dropped, since custom profiles do not support sub-rules')}";

  static String m9(message) => "The core cannot parse this proxy: ${message}";

  static String m10(proxy, target) =>
      "${proxy} dials through ${target}, which leads back to ${proxy}, so the dial loops";

  static String m11(name) =>
      "The name ${name} is already used by another proxy or proxy group";

  static String m12(path) =>
      "Proxy groups reference each other in a loop: ${path}";

  static String m13(name) =>
      "The empty fallback must be a proxy, but ${name} does not exist or is a proxy group";

  static String m14(name, message) =>
      "${name} is not a valid regex: ${message}";

  static String m15(name) => "The dialer proxy ${name} does not exist";

  static String m16(names) => "These proxy providers do not exist: ${names}";

  static String m17(names) =>
      "These proxies or policies do not exist: ${names}";

  static String m18(name) =>
      "${name} is a built-in policy name and cannot be used here";

  static String m19(count) =>
      "${count} items have problems, and applying this profile may fail";

  static String m20(count) =>
      "${Intl.plural(count, one: '1 day ago', other: '${count} days ago')}";

  static String m21(count) => "${Intl.plural(count, other: '${count}d ago')}";

  static String m22(label) =>
      "Are you sure you want to delete the selected ${label}?";

  static String m23(label) => "Are you sure you want to delete this ${label}?";

  static String m24(label) => "${label} details";

  static String m25(name) =>
      "Dialing through ${name} leads back to the proxy that uses it, so the connection was stopped";

  static String m26(label) => "${label} cannot be empty";

  static String m27(label) => "${label} already exists";

  static String m28(count) => "${count} items failed";

  static String m29(label, message) => "${label}: ${message}";

  static String m30(name) => "${name} is already up to date";

  static String m31(name) => "${name} updated";

  static String m32(count) =>
      "${Intl.plural(count, one: '1 group', other: '${count} groups')}";

  static String m33(count) => "${count} timed out";

  static String m34(action) =>
      "Already used by “${action}”. Saving moves it here.";

  static String m35(modifiers) => "Include at least one of ${modifiers}";

  static String m36(count) =>
      "${Intl.plural(count, one: '1 hour ago', other: '${count} hours ago')}";

  static String m37(count) => "${Intl.plural(count, other: '${count}h ago')}";

  static String m38(target) => "${target} is an invalid policy";

  static String m39(proxyName) => "${proxyName} is an invalid proxy";

  static String m40(providerName) =>
      "${providerName} is an invalid proxy provider";

  static String m41(ruleSet) => "${ruleSet} is an invalid rule set";

  static String m42(subRule) => "${subRule} is an invalid SUB_RULE";

  static String m43(count) =>
      "${Intl.plural(count, one: '1 item', other: '${count} items')}";

  static String m44(line, message) => "Line ${line}: ${message}";

  static String m45(appName) =>
      "1. Open System Settings > Privacy & Security\n2. Choose Location Services\n3. Find and check ${appName} in the list\n\nWhen you are done, return to the app to continue. Thank you for your cooperation.";

  static String m46(label, max) => "${label} must be at most ${max} characters";

  static String m47(size) => "Released ${size}";

  static String m48(count) =>
      "${Intl.plural(count, one: '1 minute ago', other: '${count} minutes ago')}";

  static String m49(count) => "${Intl.plural(count, other: '${count}m ago')}";

  static String m50(count) =>
      "${Intl.plural(count, one: '1 month ago', other: '${count} months ago')}";

  static String m51(count) => "${Intl.plural(count, other: '${count}mo ago')}";

  static String m52(code) =>
      "The server denied access (HTTP ${code}). The link may have expired, or the credentials are wrong";

  static String m53(code) => "The server rejected the request (HTTP ${code})";

  static String m54(code) =>
      "Nothing was found at this address (HTTP ${code}). Check that the URL is correct";

  static String m55(detail) => "Network request failed: ${detail}";

  static String m56(code) =>
      "The server ran into a problem (HTTP ${code}). Try again later";

  static String m57(label) => "No ${label} yet";

  static String m58(label, min, max) =>
      "${label} must be between ${min} and ${max}";

  static String m59(label) => "${label} must be a number";

  static String m60(label) => "${label} must be between 1024 and 49151";

  static String m61(port) => "Port ${port}";

  static String m62(action) =>
      "Apply “${action}” to this session? Monitoring and recordings may contain credentials or private content. Closing this page does not stop an active capture.";

  static String m63(action) =>
      "Confirm “${action}” for the current Windows user only? This changes local CA material or trust. Applications may need to reconnect. No machine-wide certificate store will be changed.";

  static String m64(application) =>
      "Launch a new instance of ${application}? Save your work and close an already-running instance yourself first. Single-instance apps may reuse an old unproxied process. No existing process will be stopped automatically.";

  static String m65(rule) =>
      "This CIDR cannot be translated safely for this backend: ${rule}. Use an exact IP or a supported network prefix.";

  static String m66(rule) =>
      "Invalid IP/domain rule: ${rule}. Use one IP, supported CIDR or domain pattern per line; do not enter URLs or ports.";

  static String m67(error) => "Operation failed: ${error}";

  static String m68(count) => "Reported packets: ${count}";

  static String m69(number, offset, length) =>
      "Datagram ${number}: offset ${offset}, ${length} bytes";

  static String m70(length) =>
      "Read-only prefix limited to ${length} bytes; range and direction are locked.";

  static String m71(count) =>
      "Add these ${count} profiles? Existing profiles are retained; conflicting names or IDs are rejected. No application will start. Review the executable paths below.";

  static String m72(name) =>
      "Load “${name}” into the launch form? Nothing will start, and backend trust and sensitive consent will be cleared.";

  static String m73(count) =>
      "Disconnect the ${count} selected existing TCP connections in this session, including direct bypass connections? Uploads or sessions may be interrupted. Applications must reconnect themselves; success is not guaranteed. UDP is unaffected.";

  static String m74(start, end, total, all) =>
      "Records ${start}–${end} of ${total} matches (${all} in the recording)";

  static String m75(count) => "Recording warnings: ${count}";

  static String m76(days) =>
      "${Intl.plural(days, one: '1 day left', other: '${days} days left')}";

  static String m77(date, days) =>
      "Expires ${date}, ${Intl.plural(days, one: '1 day', other: '${days} days')} left";

  static String m78(time) => "Updated ${time}";

  static String m79(label, profiles) =>
      "${label} is still used by ${profiles}, which will not work properly once it is deleted. Are you sure you want to delete it?";

  static String m80(count, label) =>
      "${Intl.plural(count, one: '1 proxy', other: '${label} proxies')}";

  static String m81(name, count) => "${name} and others (${count} proxies)";

  static String m82(removed) =>
      "These proxies will be deleted: ${removed}. A line whose name changed counts as a new proxy, and custom profiles naming the deleted ones will flag them as missing. Apply anyway?";

  static String m83(removed, added) =>
      "These proxies will be deleted: ${removed}. These will be added: ${added}. A line whose name changed counts as a new proxy, and custom profiles naming the deleted ones will flag them as missing. Apply anyway?";

  static String m84(label) =>
      "${label} is still named by rules, proxy groups, dialer proxies, DNS or NTP in this profile, which stop working once it is deleted. Are you sure you want to delete it?";

  static String m85(count, label) =>
      "${Intl.plural(count, one: '1 proxy group', other: '${label} proxy groups')}";

  static String m86(count, label) =>
      "${Intl.plural(count, one: '1 rule', other: '${label} rules')}";

  static String m87(appName) => "${appName} (Safe mode)";

  static String m88(count) =>
      "${Intl.plural(count, one: '1 second', other: '${count} seconds')}";

  static String m89(count) => "${count} in effect";

  static String m90(count) =>
      "${Intl.plural(count, one: '1 issue', other: '${count} issues')}";

  static String m91(count) =>
      "${Intl.plural(count, one: '1 setting', other: '${count} settings')}";

  static String m92(link) => "No proxy could be read from ${link}";

  static String m93(label) => "${label} must be a single item";

  static String m94(value) => "Peak ${value}";

  static String m95(value) => "Total ${value}";

  static String m96(transport) => "${transport} Headers";

  static String m97(label) => "${label} must be a URL";

  static String m98(count) =>
      "${Intl.plural(count, one: '1 year ago', other: '${count} years ago')}";

  static String m99(count) => "${Intl.plural(count, other: '${count}y ago')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "accessControl": MessageLookupByLibrary.simpleMessage("Access control"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Only selected apps go through the VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Access control picks which apps use the proxy.",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "App access control is disabled",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Selected apps are excluded from the VPN",
    ),
    "accessControlSelectedCount": m0,
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "action": MessageLookupByLibrary.simpleMessage("Action"),
    "actionDelayTest": MessageLookupByLibrary.simpleMessage("Test all delays"),
    "actionDirectMode": MessageLookupByLibrary.simpleMessage("Direct mode"),
    "actionGlobalMode": MessageLookupByLibrary.simpleMessage("Global mode"),
    "actionMode": MessageLookupByLibrary.simpleMessage("Switch mode"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("System proxy"),
    "actionRuleMode": MessageLookupByLibrary.simpleMessage("Rule mode"),
    "actionStart": MessageLookupByLibrary.simpleMessage("Start/Stop"),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionUpdateProfiles": MessageLookupByLibrary.simpleMessage(
      "Update profiles",
    ),
    "actionView": MessageLookupByLibrary.simpleMessage("Show/Hide"),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addCustomProxy": MessageLookupByLibrary.simpleMessage("Add proxy"),
    "addFilters": MessageLookupByLibrary.simpleMessage("Add filters"),
    "addNodes": MessageLookupByLibrary.simpleMessage("Add nodes"),
    "addOverrideEntry": MessageLookupByLibrary.simpleMessage(
      "Add override entry",
    ),
    "addProfile": MessageLookupByLibrary.simpleMessage("Add profile"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage("Add proxy group"),
    "addRule": MessageLookupByLibrary.simpleMessage("Add rule"),
    "addSettingEntry": MessageLookupByLibrary.simpleMessage("Add setting"),
    "addSsid": MessageLookupByLibrary.simpleMessage("Add SSID"),
    "addToLocalProxies": MessageLookupByLibrary.simpleMessage(
      "Add to local proxies",
    ),
    "addedRules": MessageLookupByLibrary.simpleMessage("Added rules"),
    "addedToLocalProxies": m1,
    "additionalParameters": MessageLookupByLibrary.simpleMessage(
      "Additional parameters",
    ),
    "additionalPrefix": MessageLookupByLibrary.simpleMessage("Name prefix"),
    "additionalSuffix": MessageLookupByLibrary.simpleMessage("Name suffix"),
    "address": MessageLookupByLibrary.simpleMessage("Address"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "WebDAV server address",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid WebDAV address",
    ),
    "advancedConfig": MessageLookupByLibrary.simpleMessage(
      "Advanced configuration",
    ),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Advanced configuration holds network, DNS, added rules, and scripts.",
    ),
    "ageEncryptedProfile": MessageLookupByLibrary.simpleMessage(
      "Encrypted profile",
    ),
    "ageSecretKey": MessageLookupByLibrary.simpleMessage("Age secret key"),
    "ageSecretKeyRequiredTip": MessageLookupByLibrary.simpleMessage(
      "This profile is encrypted with age and needs an age secret key to decrypt",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("Agree"),
    "allReferencedProxies": MessageLookupByLibrary.simpleMessage(
      "All referenced proxies",
    ),
    "allReferencedProxyProviders": MessageLookupByLibrary.simpleMessage(
      "All referenced proxy providers",
    ),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Allow apps to bypass VPN",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("Allow LAN"),
    "allowedIps": MessageLookupByLibrary.simpleMessage("Allowed IPs"),
    "alreadyInLocalProxies": m2,
    "answers": MessageLookupByLibrary.simpleMessage("Answers"),
    "app": MessageLookupByLibrary.simpleMessage("App"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "App access control",
    ),
    "appIconDesign": MessageLookupByLibrary.simpleMessage("App icon design"),
    "appProxiesEmpty": MessageLookupByLibrary.simpleMessage("No local proxies"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage(
      "Append system DNS",
    ),
    "applied": MessageLookupByLibrary.simpleMessage("Applied"),
    "applyNow": MessageLookupByLibrary.simpleMessage("Apply now"),
    "authentication": MessageLookupByLibrary.simpleMessage("Authentication"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "Authentication asks for a username and password on the local proxy port.",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "The system proxy is not applied while authentication is on.",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("Authorize"),
    "authorized": MessageLookupByLibrary.simpleMessage("Authorized"),
    "auto": MessageLookupByLibrary.simpleMessage("Auto"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Auto check for updates",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Auto close connections",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Auto close connections drops open connections when you switch proxies.",
    ),
    "autoInclude": MessageLookupByLibrary.simpleMessage("Auto-include"),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Auto launch"),
    "autoRun": MessageLookupByLibrary.simpleMessage("Auto run"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Auto run starts the proxy when the app opens.",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Auto-set system DNS",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Auto update"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Auto-update interval",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "backgroundBlur": MessageLookupByLibrary.simpleMessage("Background blur"),
    "backup": MessageLookupByLibrary.simpleMessage("Backup"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Backup and restore",
    ),
    "backupFromNewerVersion": MessageLookupByLibrary.simpleMessage(
      "This backup comes from a newer version of the app. Update the app before restoring it",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("Backup successful"),
    "basicInfo": MessageLookupByLibrary.simpleMessage("Basic info"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("Basic strategies"),
    "batchAdd": MessageLookupByLibrary.simpleMessage("Batch add"),
    "batchImport": MessageLookupByLibrary.simpleMessage("Batch import"),
    "batchLinkInputTip": MessageLookupByLibrary.simpleMessage(
      "One link per line",
    ),
    "batchListInputTip": MessageLookupByLibrary.simpleMessage(
      "One item per line, or separated by commas",
    ),
    "batchMapInputTip": MessageLookupByLibrary.simpleMessage(
      "One entry per line: key, a space, then value",
    ),
    "batchPreviewTip": m3,
    "batchUrlInputTip": MessageLookupByLibrary.simpleMessage(
      "One URL per line",
    ),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "Ignore battery optimization keeps the app running in the background.",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("Bind"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("Blacklist mode"),
    "blockConnection": MessageLookupByLibrary.simpleMessage("Block connection"),
    "brightness": MessageLookupByLibrary.simpleMessage("Brightness"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Bypass domains"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Bypass domains apply only while the system proxy is on.",
    ),
    "bypassPrivateRoute": MessageLookupByLibrary.simpleMessage(
      "Bypass private addresses",
    ),
    "bypassPrivateRouteDesc": MessageLookupByLibrary.simpleMessage(
      "With Bypass private addresses on, LAN, loopback and multicast addresses skip TUN.",
    ),
    "cache": MessageLookupByLibrary.simpleMessage("Cache"),
    "cacheAlgorithm": MessageLookupByLibrary.simpleMessage("Cache algorithm"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "The cache is corrupted. Clear it?",
    ),
    "cacheMaxSize": MessageLookupByLibrary.simpleMessage("Cache size"),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Allow camera access in system settings to scan QR codes, or choose a QR code image from the album.",
    ),
    "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Camera permission required",
    ),
    "cameraUnavailable": MessageLookupByLibrary.simpleMessage(
      "Camera unavailable",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("Deselect all"),
    "cannotSave": MessageLookupByLibrary.simpleMessage("Can\'t save"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "Failed to switch proxy; the previous selection has been restored",
    ),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage(
      "Breaking changes",
    ),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage("New features"),
    "changelogFixes": MessageLookupByLibrary.simpleMessage("Bug fixes"),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage("Performance"),
    "changelogReverts": MessageLookupByLibrary.simpleMessage("Reverts"),
    "checkCertificate": MessageLookupByLibrary.simpleMessage(
      "Verify TLS certificates",
    ),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "With TLS verification off, subscriptions and backups are open to man-in-the-middle attacks.",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("Check for updates"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "The app is already up to date",
    ),
    "cipher": MessageLookupByLibrary.simpleMessage("Cipher"),
    "clearData": MessageLookupByLibrary.simpleMessage("Clear data"),
    "clearDataAndExitTip": MessageLookupByLibrary.simpleMessage(
      "This deletes all profiles, settings, and local data, then closes the app. Open it again to start fresh.",
    ),
    "clearDataFailed": m4,
    "clearDnsCache": MessageLookupByLibrary.simpleMessage("Clear DNS cache"),
    "clearDnsCacheFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to clear DNS cache",
    ),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Clear search"),
    "clientFingerprint": MessageLookupByLibrary.simpleMessage(
      "Client fingerprint",
    ),
    "clipboardExport": MessageLookupByLibrary.simpleMessage(
      "Export to clipboard",
    ),
    "clipboardImport": MessageLookupByLibrary.simpleMessage(
      "Import from clipboard",
    ),
    "clipboardWriteFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t copy to the clipboard. The selection may be too large",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "closeConnections": MessageLookupByLibrary.simpleMessage(
      "Close connections",
    ),
    "color": MessageLookupByLibrary.simpleMessage("Color"),
    "colorStyle": MessageLookupByLibrary.simpleMessage("Color style"),
    "columns": MessageLookupByLibrary.simpleMessage("Columns"),
    "compact": MessageLookupByLibrary.simpleMessage("Compact"),
    "compatible": MessageLookupByLibrary.simpleMessage("Compatibility mode"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to clear all data?",
    ),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this proxy group?",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to exit the current window?",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to force crash the core?",
    ),
    "congestionControl": MessageLookupByLibrary.simpleMessage(
      "Congestion control",
    ),
    "congestionController": MessageLookupByLibrary.simpleMessage(
      "TCP congestion control",
    ),
    "congestionControllerDesc": MessageLookupByLibrary.simpleMessage(
      "TCP congestion control works only with the mips stack.",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("Connected"),
    "connecting": MessageLookupByLibrary.simpleMessage("Connecting…"),
    "connection": MessageLookupByLibrary.simpleMessage("Connection"),
    "connectionStats": MessageLookupByLibrary.simpleMessage("Connection stats"),
    "connectionStatsDesc": MessageLookupByLibrary.simpleMessage(
      "Live connections, recent requests and DNS queries",
    ),
    "connections": MessageLookupByLibrary.simpleMessage("Connections"),
    "connectivity": MessageLookupByLibrary.simpleMessage("Connectivity: "),
    "content": MessageLookupByLibrary.simpleMessage("Content"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Content cannot be empty",
    ),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "Control global added rules",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Copy environment variables",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Copy link"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Copied successfully"),
    "core": MessageLookupByLibrary.simpleMessage("Core"),
    "coreBlockedByPolicyTip": m5,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows Smart App Control blocked FlClashCore.exe because it is not signed. Open Windows Security → App & browser control → Smart App Control settings, choose Off, then start FlClash again. Smart App Control cannot be turned back on without reinstalling Windows.",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Core status"),
    "country": MessageLookupByLibrary.simpleMessage("Region"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("Crash detected"),
    "crashDetectedTip": m6,
    "crashTest": MessageLookupByLibrary.simpleMessage("Crash test"),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "createProfileFromUrlTip": m7,
    "creationTime": MessageLookupByLibrary.simpleMessage("Creation time"),
    "currentOutboundDesc": MessageLookupByLibrary.simpleMessage(
      "Holds the start button and can\'t be removed",
    ),
    "custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "customColor": MessageLookupByLibrary.simpleMessage("Custom color"),
    "customImportDroppedSubRules": m8,
    "customIssueCoreRejected": m9,
    "customIssueDialerLoop": m10,
    "customIssueDuplicateName": m11,
    "customIssueEmptyName": MessageLookupByLibrary.simpleMessage(
      "The name is empty",
    ),
    "customIssueGroupLoop": m12,
    "customIssueInvalidEmptyFallback": m13,
    "customIssueInvalidFilter": m14,
    "customIssueMissingDialer": m15,
    "customIssueMissingProviders": m16,
    "customIssueMissingProxies": m17,
    "customIssueNoProxySource": MessageLookupByLibrary.simpleMessage(
      "No proxies or proxy providers are selected, so the core rejects this group",
    ),
    "customIssueReservedName": m18,
    "customIssuesSummary": m19,
    "customProfile": MessageLookupByLibrary.simpleMessage("Custom"),
    "customProfileResources": MessageLookupByLibrary.simpleMessage(
      "Custom profile resources",
    ),
    "customProfileResourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Custom profile resources are the proxies, rule providers, filters, and icon sets you add yourself for custom profiles to use.",
    ),
    "cut": MessageLookupByLibrary.simpleMessage("Cut"),
    "dark": MessageLookupByLibrary.simpleMessage("Dark"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "dashboardAddableSection": MessageLookupByLibrary.simpleMessage(
      "Available to add",
    ),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "Failed to save the change; it has been rolled back",
    ),
    "daysAgo": m20,
    "daysAgoShort": m21,
    "defaultSelected": MessageLookupByLibrary.simpleMessage(
      "Default selection",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("Default"),
    "definitionNotMap": MessageLookupByLibrary.simpleMessage(
      "The configuration must be a YAML mapping with a name and a type",
    ),
    "delay": MessageLookupByLibrary.simpleMessage("Delay"),
    "delayFailed": MessageLookupByLibrary.simpleMessage("Failed"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Delay test"),
    "delayTestTimeout": MessageLookupByLibrary.simpleMessage(
      "Delay test timeout",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteMultipTip": m22,
    "deleteTip": m23,
    "desc": MessageLookupByLibrary.simpleMessage(
      "A multi-platform proxy client based on ClashMeta, simple and easy to use, open-source and ad-free.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Destination"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage(
      "Destination GeoIP",
    ),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage(
      "Destination IP ASN",
    ),
    "details": m24,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Relies on a third-party API; for reference only",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Developer mode"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Developer mode is enabled.",
    ),
    "dialerProxy": MessageLookupByLibrary.simpleMessage("Dialer proxy"),
    "dialerProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Dialer proxy is the outbound used to reach the NTP server.",
    ),
    "dialerProxyLoopStopped": m25,
    "direct": MessageLookupByLibrary.simpleMessage("Direct"),
    "disableIcmpForwarding": MessageLookupByLibrary.simpleMessage(
      "Disable ICMP forwarding",
    ),
    "disableIcmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "With ICMP forwarding disabled, TUN answers ping itself, so ping no longer shows the real latency.",
    ),
    "disableKeepAlive": MessageLookupByLibrary.simpleMessage(
      "Disable TCP keep-alive",
    ),
    "disableUDP": MessageLookupByLibrary.simpleMessage("Disable UDP"),
    "disabled": MessageLookupByLibrary.simpleMessage("Disabled"),
    "discardChanges": MessageLookupByLibrary.simpleMessage(
      "Discard the changes?",
    ),
    "disclaimer": MessageLookupByLibrary.simpleMessage("Disclaimer"),
    "disclaimerAcceptContent": MessageLookupByLibrary.simpleMessage(
      "By installing, copying, or using the Software, you are deemed to have read and agreed to this entire statement. If you disagree with any of its terms, stop using and uninstall the Software immediately.",
    ),
    "disclaimerAcceptTitle": MessageLookupByLibrary.simpleMessage("Acceptance"),
    "disclaimerAcknowledgeLabel": MessageLookupByLibrary.simpleMessage(
      "I have read and understand this statement",
    ),
    "disclaimerAcknowledgeTip": MessageLookupByLibrary.simpleMessage(
      "To confirm you understand, read the following statement and check the box below:",
    ),
    "disclaimerAcknowledgeTitle": MessageLookupByLibrary.simpleMessage(
      "Confirm the statement",
    ),
    "disclaimerChangesContent": MessageLookupByLibrary.simpleMessage(
      "The developers may revise this statement with any release, and the revision takes effect when that release is published. Continuing to use the Software after updating means you accept the revised statement.",
    ),
    "disclaimerChangesTitle": MessageLookupByLibrary.simpleMessage(
      "Changes to this statement",
    ),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "Before using FlClash (\"the Software\"), please read this statement carefully and make sure you understand all of it. Tapping \"Agree\" means you have read, understood, and accept every term below. If you do not agree, tap \"Exit\" and stop using the Software.",
    ),
    "disclaimerLiabilityContent": MessageLookupByLibrary.simpleMessage(
      "To the maximum extent permitted by applicable law, neither the developers nor any contributor shall be liable for any direct, indirect, incidental, special, punitive, or consequential damages arising from the use of or inability to use the Software, including but not limited to data loss, device damage, network failures, business interruption, lost profits, or any resulting legal dispute, even if advised of the possibility of such damages.",
    ),
    "disclaimerLiabilityTitle": MessageLookupByLibrary.simpleMessage(
      "Limitation of liability",
    ),
    "disclaimerLicenseContent": MessageLookupByLibrary.simpleMessage(
      "The Software is open source under the GPL-3.0 license. You may use, modify, and distribute it freely as long as you comply with that license, which requires derivative works to be released under GPL-3.0 as well and the original copyright notices to be kept.\n\nThird-party components in the Software, including the Clash.Meta core, follow their own licenses. The original authors are not responsible for any issue arising from modified or redistributed versions.",
    ),
    "disclaimerLicenseTitle": MessageLookupByLibrary.simpleMessage(
      "Open-source license",
    ),
    "disclaimerNoServiceStatement": MessageLookupByLibrary.simpleMessage(
      "The Software itself does not provide any proxy server, node, subscription, or network access service, and has no partnership, agency, or guarantee relationship with any provider of such services.",
    ),
    "disclaimerPrivacyContent": MessageLookupByLibrary.simpleMessage(
      "The Software does not collect or upload your subscription URLs, node details, configuration content, visited websites, connection records, traffic content, or logs. This data stays on your device and the developers have no access to it.\n\nThe Software only reaches the network when you use a feature that needs it, such as fetching the subscription URL you provided when updating a profile, or contacting GitHub when checking for updates.\n\nThe Software includes no analytics or crash reporting service on any platform.",
    ),
    "disclaimerPrivacyTitle": MessageLookupByLibrary.simpleMessage(
      "Data collection and privacy",
    ),
    "disclaimerResponsibilityContent": MessageLookupByLibrary.simpleMessage(
      "You are responsible for making sure that using the Software is lawful where you live, and you alone bear the legal responsibility for everything you do with it and its consequences.\n\nThe subscriptions, nodes, and configurations you import are your own choice. Whether their source is lawful, their content is safe, and their service is reliable is a matter between you and their providers.",
    ),
    "disclaimerResponsibilityTitle": MessageLookupByLibrary.simpleMessage(
      "Your responsibility",
    ),
    "disclaimerRestateHint": MessageLookupByLibrary.simpleMessage(
      "Enter the statement above",
    ),
    "disclaimerRestateMismatch": MessageLookupByLibrary.simpleMessage(
      "Does not match the statement",
    ),
    "disclaimerRestateTip": MessageLookupByLibrary.simpleMessage(
      "To confirm you understand, enter the following statement in full in the field below:",
    ),
    "disclaimerRestateTitle": MessageLookupByLibrary.simpleMessage(
      "Restate the statement",
    ),
    "disclaimerSoftwareContent": MessageLookupByLibrary.simpleMessage(
      "The Software is an open-source network proxy client built on the Clash.Meta (mihomo) core. It only provides local tooling such as configuration management, rule-based routing, and traffic forwarding.",
    ),
    "disclaimerSoftwareTitle": MessageLookupByLibrary.simpleMessage(
      "Nature of the software",
    ),
    "disclaimerThirdPartyContent": MessageLookupByLibrary.simpleMessage(
      "Subscription links, configuration files, rule sets, scripts, external resources, and external links are all provided by third parties. The developers cannot and do not review or guarantee their legality, accuracy, security, or availability.\n\nAny data leak, financial loss, account ban, or other loss caused by third-party content is to be settled between you and the third party; the developers bear no responsibility for it.",
    ),
    "disclaimerThirdPartyTitle": MessageLookupByLibrary.simpleMessage(
      "Third-party content",
    ),
    "disclaimerUsageContent": MessageLookupByLibrary.simpleMessage(
      "The Software is intended only for non-commercial uses such as learning, exchange, and technical research. Using it for any commercial purpose is strictly prohibited, including but not limited to paid distribution, bundled sales, use as part of a commercial service, or doing business in the name of the Software. Any commercial activity is unrelated to the Software and its developers.\n\nUsing the Software for anything that violates the laws and regulations of your country or region is strictly prohibited, including but not limited to bypassing lawfully imposed network access restrictions, spreading illegal content, launching network attacks, or infringing the lawful rights of others.",
    ),
    "disclaimerUsageTitle": MessageLookupByLibrary.simpleMessage(
      "Restrictions on use",
    ),
    "disclaimerWarrantyContent": MessageLookupByLibrary.simpleMessage(
      "The Software is provided \"as is\" and \"as available\", without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, non-infringement, uninterrupted availability, freedom from errors, or freedom from security vulnerabilities.\n\nThe developers do not guarantee that the Software will meet your needs or that it will run without interruption or error.",
    ),
    "disclaimerWarrantyTitle": MessageLookupByLibrary.simpleMessage(
      "No warranty",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("Disconnected"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "New version found",
    ),
    "dnsCacheCleared": MessageLookupByLibrary.simpleMessage(
      "DNS cache cleared",
    ),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "Without this entry, TUN hijacks every DNS query to port 53 (any:53).",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS hijacking"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS mode"),
    "dnsOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Entries added here replace the DNS of every URL and file profile; anything not added keeps the profile\'s own setting. Custom profiles set their DNS in their content.",
    ),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("DNS queries"),
    "docked": MessageLookupByLibrary.simpleMessage("Docked"),
    "domain": MessageLookupByLibrary.simpleMessage("Domain"),
    "done": MessageLookupByLibrary.simpleMessage("Done"),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "downloadBandwidth": MessageLookupByLibrary.simpleMessage(
      "Download bandwidth",
    ),
    "duration": MessageLookupByLibrary.simpleMessage("Duration"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editDashboard": MessageLookupByLibrary.simpleMessage("Edit dashboard"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "Edit global rules",
    ),
    "editProxy": MessageLookupByLibrary.simpleMessage("Edit proxy"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage("Edit proxy group"),
    "editRule": MessageLookupByLibrary.simpleMessage("Edit rule"),
    "editSsid": MessageLookupByLibrary.simpleMessage("Edit SSID"),
    "editorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Editor unavailable",
    ),
    "elapsed": MessageLookupByLibrary.simpleMessage("Took"),
    "emptyFallback": MessageLookupByLibrary.simpleMessage("Empty fallback"),
    "emptyTip": m26,
    "en": MessageLookupByLibrary.simpleMessage("English"),
    "enabled": MessageLookupByLibrary.simpleMessage("Enabled"),
    "entries": MessageLookupByLibrary.simpleMessage(" entries"),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "errorDetails": MessageLookupByLibrary.simpleMessage("Error details"),
    "es": MessageLookupByLibrary.simpleMessage("Spanish"),
    "exclude": MessageLookupByLibrary.simpleMessage("Hide from recent tasks"),
    "excludeDstPort": MessageLookupByLibrary.simpleMessage(
      "Excluded destination ports",
    ),
    "excludeDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Traffic to excluded destination ports skips TUN.",
    ),
    "excludeFilter": MessageLookupByLibrary.simpleMessage("Exclude filter"),
    "excludeInterface": MessageLookupByLibrary.simpleMessage(
      "Excluded interfaces",
    ),
    "excludeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "Traffic arriving on excluded interfaces, such as docker0, skips TUN.",
    ),
    "excludeSrcPort": MessageLookupByLibrary.simpleMessage(
      "Excluded source ports",
    ),
    "excludeSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Traffic from excluded source ports skips TUN.",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("Exclude SSIDs"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "When connected to Wi-Fi with an excluded SSID, the app\'s running state switches automatically.",
    ),
    "excludeUid": MessageLookupByLibrary.simpleMessage("Excluded user IDs"),
    "excludeUidDesc": MessageLookupByLibrary.simpleMessage(
      "Traffic from processes of excluded user IDs skips TUN.",
    ),
    "existsTip": m27,
    "exit": MessageLookupByLibrary.simpleMessage("Exit"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage("Exit full screen"),
    "exitNodes": MessageLookupByLibrary.simpleMessage("Exit nodes"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("Expected status"),
    "expireTime": MessageLookupByLibrary.simpleMessage("Expiration time"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Export file"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Export logs"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Export successful"),
    "extend": MessageLookupByLibrary.simpleMessage("Extend"),
    "extendMode": MessageLookupByLibrary.simpleMessage("Extend mode"),
    "extendScript": MessageLookupByLibrary.simpleMessage("Extend script"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "External controller",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "The external controller lets you control the core on port 9090.",
    ),
    "externalControllerSecret": MessageLookupByLibrary.simpleMessage(
      "External controller secret",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("External link"),
    "extraLarge": MessageLookupByLibrary.simpleMessage("Extra large"),
    "fade": MessageLookupByLibrary.simpleMessage("Fade"),
    "failedCount": m28,
    "failedItem": m29,
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fake-IP filter"),
    "fakeipFilterMode": MessageLookupByLibrary.simpleMessage(
      "Fake-IP filter mode",
    ),
    "fakeipFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "In Fake-IP filter mode, blacklist excludes matches, whitelist fakes only matches, and rule matches as rules.",
    ),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fake-IP range"),
    "fakeipRange6": MessageLookupByLibrary.simpleMessage(
      "Fake-IP range (IPv6)",
    ),
    "fakeipTtl": MessageLookupByLibrary.simpleMessage("Fake-IP TTL"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Fallback filter"),
    "file": MessageLookupByLibrary.simpleMessage("File"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "The file has been modified. Save the changes?",
    ),
    "filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "filters": MessageLookupByLibrary.simpleMessage("Filters"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Find process"),
    "floating": MessageLookupByLibrary.simpleMessage("Floating"),
    "followProfile": MessageLookupByLibrary.simpleMessage("Follow profile"),
    "followSystem": MessageLookupByLibrary.simpleMessage("Follow system"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("Font family"),
    "fontSize": MessageLookupByLibrary.simpleMessage("Size"),
    "forceDnsMapping": MessageLookupByLibrary.simpleMessage(
      "Force DNS mapping",
    ),
    "forceDnsMappingDesc": MessageLookupByLibrary.simpleMessage(
      "Force DNS mapping also sniffs connections whose domain came from a DNS mapping.",
    ),
    "forceDomain": MessageLookupByLibrary.simpleMessage("Force domains"),
    "forceDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Force domains are sniffed too; other connections that already have a domain are left alone.",
    ),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to force restart the core?",
    ),
    "fr": MessageLookupByLibrary.simpleMessage("French"),
    "general": MessageLookupByLibrary.simpleMessage("General"),
    "generalOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Entries added here replace the setting of every profile; anything not added keeps the profile\'s own setting, or the core default when the profile has none.",
    ),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo"),
    "geoSkipped": m30,
    "geoUpdated": m31,
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "Geo low-memory mode",
    ),
    "global": MessageLookupByLibrary.simpleMessage("Global"),
    "go": MessageLookupByLibrary.simpleMessage("Go"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Download"),
    "goToConfigureAddedRules": MessageLookupByLibrary.simpleMessage(
      "Go to added rules configuration",
    ),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage(
      "Go to script configuration",
    ),
    "grid": MessageLookupByLibrary.simpleMessage("Grid"),
    "groupCount": m32,
    "groupCountUnit": MessageLookupByLibrary.simpleMessage("groups"),
    "groupTimeoutCount": m33,
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Cache the changes?",
    ),
    "hashByInUser": MessageLookupByLibrary.simpleMessage(
      "Hash by inbound user",
    ),
    "healthCheck": MessageLookupByLibrary.simpleMessage("Health check"),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Helper service unavailable; TUN mode cannot be enabled. Reinstall FlClash to restore it.",
    ),
    "hex": MessageLookupByLibrary.simpleMessage("Hex"),
    "hideFromList": MessageLookupByLibrary.simpleMessage("Hide from list"),
    "hideIp": MessageLookupByLibrary.simpleMessage("Hide IP"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("Hide password"),
    "hideTimeoutProxies": MessageLookupByLibrary.simpleMessage(
      "Hide timed-out proxies",
    ),
    "hopInterval": MessageLookupByLibrary.simpleMessage("Hop interval"),
    "host": MessageLookupByLibrary.simpleMessage("Host"),
    "hostname": MessageLookupByLibrary.simpleMessage("Hostname"),
    "hotkeyConflictWith": m34,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "Global hotkeys work even while the window is hidden. Tap an action to record its key combination.",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Hotkey management",
    ),
    "hotkeyNeedsModifier": m35,
    "hotkeyNotSet": MessageLookupByLibrary.simpleMessage("Not set"),
    "hotkeyUnavailable": MessageLookupByLibrary.simpleMessage(
      "Not registered, it may be taken by another app",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("hours"),
    "hoursAgo": m36,
    "hoursAgoShort": m37,
    "hue": MessageLookupByLibrary.simpleMessage("Hue"),
    "icon": MessageLookupByLibrary.simpleMessage("Icon"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("Icon records"),
    "iconSets": MessageLookupByLibrary.simpleMessage("Icon sets"),
    "iconSetsEmptyTip": MessageLookupByLibrary.simpleMessage(
      "No icon sets yet. Add them in Custom profile resources → Icon sets",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Icon style"),
    "iconStyleFilled": MessageLookupByLibrary.simpleMessage("Filled"),
    "iconStyleHidden": MessageLookupByLibrary.simpleMessage("Hidden"),
    "iconStylePlain": MessageLookupByLibrary.simpleMessage("Plain"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("Icon URL"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Ignore battery optimization",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Import"),
    "importConfigInvalid": MessageLookupByLibrary.simpleMessage(
      "This file is not a config that can be imported",
    ),
    "importConfigReplaceTip": MessageLookupByLibrary.simpleMessage(
      "Importing replaces the proxy groups, rules and settings this profile has now",
    ),
    "importFile": MessageLookupByLibrary.simpleMessage("Import from file"),
    "importFromLink": MessageLookupByLibrary.simpleMessage("Import from link"),
    "importUrl": MessageLookupByLibrary.simpleMessage("Import from URL"),
    "inbound": MessageLookupByLibrary.simpleMessage("Inbound"),
    "includeInterface": MessageLookupByLibrary.simpleMessage(
      "Included interfaces",
    ),
    "includeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "Only traffic arriving on included interfaces goes through TUN, and excluded interfaces no longer apply.",
    ),
    "includeUid": MessageLookupByLibrary.simpleMessage("Included user IDs"),
    "includeUidDesc": MessageLookupByLibrary.simpleMessage(
      "Only traffic from processes of included user IDs goes through TUN.",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("Never expires"),
    "init": MessageLookupByLibrary.simpleMessage("Init"),
    "initFailed": MessageLookupByLibrary.simpleMessage("Startup failed"),
    "initFailedTip": MessageLookupByLibrary.simpleMessage(
      "FlClash ran into an error while starting and can\'t continue. Copy the details to report the problem. If it keeps happening, clearing the data usually lets the app start again.",
    ),
    "initiator": MessageLookupByLibrary.simpleMessage("Initiator"),
    "initiatorShort": MessageLookupByLibrary.simpleMessage("From"),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage(
      "Enter the proxy group name",
    ),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage(
      "Enter the rule content",
    ),
    "installedAppsPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "The app list permission was denied, so installed apps cannot be listed. Please grant it manually in system settings.",
    ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "This system hides the installed app list until the permission is granted. Authorize it to configure the per-app proxy.",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "App list permission required",
    ),
    "installedFonts": MessageLookupByLibrary.simpleMessage("Installed fonts"),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "Smart selection",
    ),
    "interfaceName": MessageLookupByLibrary.simpleMessage("Interface name"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "Interface name is the network interface outbound connections use.",
    ),
    "interfaceNameMode": MessageLookupByLibrary.simpleMessage(
      "Outbound interface",
    ),
    "interfaceNameModeClear": MessageLookupByLibrary.simpleMessage("Clear"),
    "interfaceNameModeCustom": MessageLookupByLibrary.simpleMessage("Custom"),
    "interfaceNameModeFollow": MessageLookupByLibrary.simpleMessage(
      "Follow config",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("Internet"),
    "interval": MessageLookupByLibrary.simpleMessage("Interval"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Intranet IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage(
      "Invalid backup file",
    ),
    "invalidCidrContent": MessageLookupByLibrary.simpleMessage(
      "Enter an IP range in CIDR form such as 192.168.0.0/16",
    ),
    "invalidDscpContent": MessageLookupByLibrary.simpleMessage(
      "A DSCP mark cannot exceed 63",
    ),
    "invalidHostContent": MessageLookupByLibrary.simpleMessage(
      "Enter a domain or an IP address",
    ),
    "invalidIconSet": MessageLookupByLibrary.simpleMessage(
      "Not a valid icon set",
    ),
    "invalidLinkTip": MessageLookupByLibrary.simpleMessage(
      "Not a subscription link or a proxy share link",
    ),
    "invalidListenContent": MessageLookupByLibrary.simpleMessage(
      "Enter an address and port such as 0.0.0.0:1053",
    ),
    "invalidNetworkContent": MessageLookupByLibrary.simpleMessage(
      "Only tcp or udp is supported",
    ),
    "invalidPolicy": m38,
    "invalidPortRangeContent": MessageLookupByLibrary.simpleMessage(
      "Enter a port or a range such as 443 or 8000-9000",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "This QR code doesn\'t contain a profile link",
    ),
    "invalidProxy": m39,
    "invalidProxyProvider": m40,
    "invalidRangeContent": MessageLookupByLibrary.simpleMessage(
      "Enter numbers or ranges such as 80 or 8000-9000, separated by /",
    ),
    "invalidRuleSet": m41,
    "invalidSubRule": m42,
    "ipAddress": MessageLookupByLibrary.simpleMessage("IP address"),
    "ipAsn": MessageLookupByLibrary.simpleMessage("ASN"),
    "ipFlagAbuser": MessageLookupByLibrary.simpleMessage("Abuse history"),
    "ipFlagProxy": MessageLookupByLibrary.simpleMessage("Proxy"),
    "ipFlagTor": MessageLookupByLibrary.simpleMessage("Tor"),
    "ipFlagVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "ipFlags": MessageLookupByLibrary.simpleMessage("Flags"),
    "ipOrganization": MessageLookupByLibrary.simpleMessage("Organization"),
    "ipQualityFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t determine the IP type",
    ),
    "ipQualityGood": MessageLookupByLibrary.simpleMessage("Good"),
    "ipQualityLevel": MessageLookupByLibrary.simpleMessage("Level"),
    "ipQualityNormal": MessageLookupByLibrary.simpleMessage("Normal"),
    "ipQualityRetry": MessageLookupByLibrary.simpleMessage("Check again"),
    "ipQualityRisky": MessageLookupByLibrary.simpleMessage("Risky"),
    "ipQualityShort": MessageLookupByLibrary.simpleMessage("Quality"),
    "ipQualitySource": MessageLookupByLibrary.simpleMessage("Answered by"),
    "ipQualitySources": MessageLookupByLibrary.simpleMessage("Sources"),
    "ipSourceIpMismatch": MessageLookupByLibrary.simpleMessage(
      "Different outbound IP",
    ),
    "ipSourceNoType": MessageLookupByLibrary.simpleMessage("No type"),
    "ipSourceRateLimited": MessageLookupByLibrary.simpleMessage("Rate limited"),
    "ipType": MessageLookupByLibrary.simpleMessage("Type"),
    "ipTypeBusiness": MessageLookupByLibrary.simpleMessage("Business"),
    "ipTypeHosting": MessageLookupByLibrary.simpleMessage("Data center"),
    "ipTypeMobile": MessageLookupByLibrary.simpleMessage("Mobile network"),
    "ipTypeResidential": MessageLookupByLibrary.simpleMessage("Residential"),
    "ipTypeUnknown": MessageLookupByLibrary.simpleMessage("Unknown type"),
    "ipVersion": MessageLookupByLibrary.simpleMessage("IP version"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "IPv6 traffic is received only while IPv6 is on.",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "With IPv6 on, the VPN allows IPv6 inbound.",
    ),
    "ipv6Timeout": MessageLookupByLibrary.simpleMessage("IPv6 timeout (ms)"),
    "itemsCount": m43,
    "ja": MessageLookupByLibrary.simpleMessage("Japanese"),
    "justNow": MessageLookupByLibrary.simpleMessage("Just now"),
    "keepAliveIdle": MessageLookupByLibrary.simpleMessage(
      "TCP keep-alive idle",
    ),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCP keep-alive interval",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Key"),
    "ko": MessageLookupByLibrary.simpleMessage("Korean"),
    "label": MessageLookupByLibrary.simpleMessage("Label"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "large": MessageLookupByLibrary.simpleMessage("Large"),
    "lastUpdated": MessageLookupByLibrary.simpleMessage("Last updated"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage(
      "Launch did not finish",
    ),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "The app exited unexpectedly while it was starting up last time. Automatic setup was skipped for this launch; you can start it manually to retry.",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("Layout"),
    "light": MessageLookupByLibrary.simpleMessage("Light"),
    "lineIssueTip": m44,
    "lineWrap": MessageLookupByLibrary.simpleMessage("Word wrap"),
    "link": MessageLookupByLibrary.simpleMessage("Link"),
    "liquidGlass": MessageLookupByLibrary.simpleMessage("Liquid Glass"),
    "list": MessageLookupByLibrary.simpleMessage("List"),
    "listen": MessageLookupByLibrary.simpleMessage("Listen"),
    "listenRoutingMark": MessageLookupByLibrary.simpleMessage(
      "Listen routing mark",
    ),
    "listenRoutingMarkDesc": MessageLookupByLibrary.simpleMessage(
      "Listen routing mark works only on Linux.",
    ),
    "liveConnections": MessageLookupByLibrary.simpleMessage("Live connections"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading…"),
    "local": MessageLookupByLibrary.simpleMessage("Local"),
    "localImage": MessageLookupByLibrary.simpleMessage("Local image"),
    "localNetworkDeniedTip": MessageLookupByLibrary.simpleMessage(
      "Local network permission denied: using the gvisor stack, LAN is unreachable.",
    ),
    "localProxies": MessageLookupByLibrary.simpleMessage("Local proxies"),
    "locationPermission": MessageLookupByLibrary.simpleMessage(
      "Location permission",
    ),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "Location permission was denied, so the current Wi-Fi name cannot be read. Please enable location permission manually in system settings.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "The system requires location permission to read the Wi-Fi name. On Android choose \"Allow all the time\", otherwise the Wi-Fi name cannot be read while the app is in the background.",
    ),
    "locationPermissionGuide": m45,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Location permission required",
    ),
    "log": MessageLookupByLibrary.simpleMessage("Log"),
    "logLevel": MessageLookupByLibrary.simpleMessage("Log level"),
    "logcat": MessageLookupByLibrary.simpleMessage("Logcat"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "Turning off Logcat hides the logs entry.",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Logs"),
    "logsAndDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Logs and diagnostics",
    ),
    "logsTest": MessageLookupByLibrary.simpleMessage("Logs test"),
    "loopback": MessageLookupByLibrary.simpleMessage("UWP loopback exemption"),
    "loose": MessageLookupByLibrary.simpleMessage("Loose"),
    "matchCase": MessageLookupByLibrary.simpleMessage("Match case"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage("Match source IP"),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage("Max failures"),
    "maxLengthTip": m46,
    "maximize": MessageLookupByLibrary.simpleMessage("Maximize"),
    "memoryAppResident": MessageLookupByLibrary.simpleMessage(
      "Resident memory",
    ),
    "memoryAppShared": MessageLookupByLibrary.simpleMessage("App & shared"),
    "memoryCoreHeapIdle": MessageLookupByLibrary.simpleMessage("Heap idle"),
    "memoryCoreHeapInuse": MessageLookupByLibrary.simpleMessage("Heap in use"),
    "memoryCoreNotRunning": MessageLookupByLibrary.simpleMessage(
      "Core is not running",
    ),
    "memoryCoreRuntime": MessageLookupByLibrary.simpleMessage(
      "Runtime overhead",
    ),
    "memoryCoreStack": MessageLookupByLibrary.simpleMessage("Goroutine stacks"),
    "memoryEstimateDesc": MessageLookupByLibrary.simpleMessage(
      "Estimated from process resident memory; it may differ from what the system reports.",
    ),
    "memoryEstimateSharedDesc": MessageLookupByLibrary.simpleMessage(
      "The Core runs inside the app process. Its share is estimated from runtime stats, and the rest counts as app and shared memory.",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Memory info"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage(
      "Memory the app and the core use",
    ),
    "memoryReleased": MessageLookupByLibrary.simpleMessage("Memory released"),
    "memoryReleasedSize": m47,
    "messageTest": MessageLookupByLibrary.simpleMessage("Message test"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage(
      "This is a message.",
    ),
    "minimize": MessageLookupByLibrary.simpleMessage("Minimize"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("Minimize on exit"),
    "minutes": MessageLookupByLibrary.simpleMessage("minutes"),
    "minutesAgo": m48,
    "minutesAgoShort": m49,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Mixed port"),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "monochromeIcon": MessageLookupByLibrary.simpleMessage("Monochrome icon"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monochrome"),
    "monthsAgo": m50,
    "monthsAgoShort": m51,
    "more": MessageLookupByLibrary.simpleMessage("More"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage("Bottom bar"),
    "network": MessageLookupByLibrary.simpleMessage("Network"),
    "networkAccessDeniedError": m52,
    "networkBadResponseError": m53,
    "networkCancelledError": MessageLookupByLibrary.simpleMessage(
      "The request was cancelled",
    ),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t connect to the server. Check your network connection or proxy settings",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t resolve the server address. Check that the URL is correct and DNS is working",
    ),
    "networkName": MessageLookupByLibrary.simpleMessage("Network name"),
    "networkNotFoundError": m54,
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "Too many requests (HTTP 429). Wait a moment and try again",
    ),
    "networkRequestFailed": m55,
    "networkSecret": MessageLookupByLibrary.simpleMessage("Network secret"),
    "networkServerError": m56,
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Network speed"),
    "networkTakeover": MessageLookupByLibrary.simpleMessage("Traffic takeover"),
    "networkTimeoutError": MessageLookupByLibrary.simpleMessage(
      "The request timed out. Check your network or proxy, then try again",
    ),
    "networkTlsError": MessageLookupByLibrary.simpleMessage(
      "Secure connection failed. The server\'s certificate may be invalid, or the connection is being intercepted",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("Network type"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("Next match"),
    "no": MessageLookupByLibrary.simpleMessage("No"),
    "noData": MessageLookupByLibrary.simpleMessage("No data"),
    "noInfo": MessageLookupByLibrary.simpleMessage("No info"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage(
      "Don\'t remind me again",
    ),
    "noNetwork": MessageLookupByLibrary.simpleMessage("No network"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("No-network apps"),
    "noResolve": MessageLookupByLibrary.simpleMessage("Don\'t resolve IP"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage(
      "Don\'t resolve hostname",
    ),
    "noSearchResults": MessageLookupByLibrary.simpleMessage(
      "No matching results",
    ),
    "nodes": MessageLookupByLibrary.simpleMessage("Nodes"),
    "nonTextProviderFile": MessageLookupByLibrary.simpleMessage(
      "This external resource is not a text file",
    ),
    "none": MessageLookupByLibrary.simpleMessage("None"),
    "notRunning": MessageLookupByLibrary.simpleMessage("Not running"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "The current proxy group cannot be selected",
    ),
    "ntpInterval": MessageLookupByLibrary.simpleMessage(
      "Sync interval (minutes)",
    ),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage(
      "NTP takes the time from an NTP server instead of the system clock.",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Add a profile to get started",
    ),
    "nullTip": m57,
    "numberRangeTip": m58,
    "numberTip": m59,
    "obfs": MessageLookupByLibrary.simpleMessage("Obfuscation"),
    "obfsHost": MessageLookupByLibrary.simpleMessage("Obfuscation host"),
    "obfsMode": MessageLookupByLibrary.simpleMessage("Obfuscation mode"),
    "obfsParam": MessageLookupByLibrary.simpleMessage("Obfuscation parameter"),
    "obfsPassword": MessageLookupByLibrary.simpleMessage(
      "Obfuscation password",
    ),
    "onDemand": MessageLookupByLibrary.simpleMessage("On demand"),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "On demand pauses the proxy on excluded Wi-Fi.",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Only count proxy traffic",
    ),
    "optional": MessageLookupByLibrary.simpleMessage("Optional"),
    "options": MessageLookupByLibrary.simpleMessage("Options"),
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Other contributors",
    ),
    "outbound": MessageLookupByLibrary.simpleMessage("Outbound"),
    "outboundExit": MessageLookupByLibrary.simpleMessage("Exit"),
    "outboundIp": MessageLookupByLibrary.simpleMessage("Outbound IP"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Outbound mode"),
    "overrideDestination": MessageLookupByLibrary.simpleMessage(
      "Override destination",
    ),
    "overrideDestinationDesc": MessageLookupByLibrary.simpleMessage(
      "Override destination connects to the sniffed domain instead of the original address.",
    ),
    "overrideEntries": MessageLookupByLibrary.simpleMessage("Override entries"),
    "parsePureIp": MessageLookupByLibrary.simpleMessage("Parse pure IP"),
    "parsePureIpDesc": MessageLookupByLibrary.simpleMessage(
      "Parse pure IP sniffs connections that carry only an IP address.",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "paste": MessageLookupByLibrary.simpleMessage("Paste"),
    "peers": MessageLookupByLibrary.simpleMessage("Peers"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("Choose from album"),
    "pinWindow": MessageLookupByLibrary.simpleMessage("Pin window"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Please bind WebDAV",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "Please enter a script name",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Please upload a valid QR code",
    ),
    "plugin": MessageLookupByLibrary.simpleMessage("Plugin"),
    "pluginCipher": MessageLookupByLibrary.simpleMessage("Plugin cipher"),
    "pluginHost": MessageLookupByLibrary.simpleMessage("Plugin host"),
    "pluginMode": MessageLookupByLibrary.simpleMessage("Plugin mode"),
    "pluginPassword": MessageLookupByLibrary.simpleMessage("Plugin password"),
    "pluginPath": MessageLookupByLibrary.simpleMessage("Plugin path"),
    "pluginUsername": MessageLookupByLibrary.simpleMessage("Plugin username"),
    "port": MessageLookupByLibrary.simpleMessage("Port"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Please enter a different port",
    ),
    "portHopping": MessageLookupByLibrary.simpleMessage("Port hopping"),
    "portTip": m60,
    "portValue": m61,
    "ports": MessageLookupByLibrary.simpleMessage("Ports"),
    "preSharedKey": MessageLookupByLibrary.simpleMessage("Pre-shared key"),
    "preferred": MessageLookupByLibrary.simpleMessage("Preferred"),
    "prerequisites": MessageLookupByLibrary.simpleMessage("Prerequisites"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "Press a key combination",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("Preview"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("Previous match"),
    "privateKey": MessageLookupByLibrary.simpleMessage("Private key"),
    "privateKeyPassphrase": MessageLookupByLibrary.simpleMessage(
      "Private key passphrase",
    ),
    "process": MessageLookupByLibrary.simpleMessage("Process"),
    "processProxy": MessageLookupByLibrary.simpleMessage("Process proxy"),
    "processProxyAdvanced": MessageLookupByLibrary.simpleMessage(
      "Advanced capabilities — experimental",
    ),
    "processProxyAdvancedHelp": MessageLookupByLibrary.simpleMessage(
      "HTTPS/QUIC decryption, CA trust, monitoring, recording and replay are not yet fully migrated into FlClash. All are off by default. Changing decryption preferences does not install a certificate or start monitoring.",
    ),
    "processProxyApplications": MessageLookupByLibrary.simpleMessage(
      "Installed applications",
    ),
    "processProxyApplicationsHelp": MessageLookupByLibrary.simpleMessage(
      "Read-only search of local EXEs in App Paths and the Start menu. Preserves shortcut arguments and working directories. Does not start, attach to or stop any existing process. UWP apps and scripts are unsupported.",
    ),
    "processProxyApplyCapture": MessageLookupByLibrary.simpleMessage(
      "Apply capture limits",
    ),
    "processProxyArguments": MessageLookupByLibrary.simpleMessage(
      "Arguments (JSON string array)",
    ),
    "processProxyArgumentsHelp": MessageLookupByLibrary.simpleMessage(
      "Example: [\"--profile\", \"Work\"]. No shell is used. Do not enter passwords or tokens.",
    ),
    "processProxyBackend": MessageLookupByLibrary.simpleMessage(
      "ProxyLane backend",
    ),
    "processProxyBackendHelp": MessageLookupByLibrary.simpleMessage(
      "Select a trusted complete ProxyLane v1.3.5 installation. FlClash uses an isolated session copy and does not overwrite its original configuration.",
    ),
    "processProxyBackendPath": MessageLookupByLibrary.simpleMessage(
      "Official ProxyLane64.exe path",
    ),
    "processProxyBackendRunning": MessageLookupByLibrary.simpleMessage(
      "Backend running; verify traffic",
    ),
    "processProxyBlockUdp": MessageLookupByLibrary.simpleMessage(
      "Block UDP (QUIC uses TCP fallback where supported)",
    ),
    "processProxyBypass": MessageLookupByLibrary.simpleMessage(
      "Bypass IPs, CIDRs and domains — one per line",
    ),
    "processProxyBypassHelp": MessageLookupByLibrary.simpleMessage(
      "Excluded destinations connect directly. Add internal domains explicitly. IP rules apply when the backend sees the destination IP; hostname matching takes precedence.",
    ),
    "processProxyCaWarning": MessageLookupByLibrary.simpleMessage(
      "No certificate is installed automatically. Trusting a local CA lets that CA authenticate intercepted TLS connections for this user. Only proceed on applications and traffic you are authorized to inspect.",
    ),
    "processProxyCacheId": MessageLookupByLibrary.simpleMessage("Cache ID"),
    "processProxyCaptureOptions": MessageLookupByLibrary.simpleMessage(
      "Capture limits (JSON object)",
    ),
    "processProxyCapturePrivacy": MessageLookupByLibrary.simpleMessage(
      "Decryption and recording are off by default. Inspect only your authorized application traffic. Recordings stay in the local directory you choose; protect and delete them as needed. Stopping monitoring disables capture and decryption for new connections, but existing TLS bridges can persist until those connections end or you explicitly reconnect them. Trusted CAs remain until removed separately. Reconnecting may interrupt transfers and is never automatic.",
    ),
    "processProxyCertificates": MessageLookupByLibrary.simpleMessage(
      "Certificates",
    ),
    "processProxyChildRuleInclude": MessageLookupByLibrary.simpleMessage(
      "Only inject children matching these rules",
    ),
    "processProxyChildRules": MessageLookupByLibrary.simpleMessage(
      "Child-process path / name rules",
    ),
    "processProxyChildRulesHelp": MessageLookupByLibrary.simpleMessage(
      "One local full-path/glob or EXE name per line, at most 128 rules. Requires child-process proxying. By default matching children are excluded; switch below to include only matches. Empty means all children. The root is unaffected. Excluded children are not injected, so their descendants do not inherit proxying automatically; include intermediate launchers.",
    ),
    "processProxyChildren": MessageLookupByLibrary.simpleMessage(
      "Include child processes",
    ),
    "processProxyClient": MessageLookupByLibrary.simpleMessage(
      "Client → Server",
    ),
    "processProxyCloseReplay": MessageLookupByLibrary.simpleMessage(
      "Close replay",
    ),
    "processProxyConfirmAdvanced": m62,
    "processProxyConfirmCa": m63,
    "processProxyConfirmLaunch": m64,
    "processProxyCoreRequired": MessageLookupByLibrary.simpleMessage(
      "Start FlClash on the dashboard before launching an application.",
    ),
    "processProxyCoreSessionEnded": MessageLookupByLibrary.simpleMessage(
      "Core state or listener configuration changed; this process-proxy session is invalidated. Injected hooks can remain after the backend or core stops, so new connections may fail. Manually restart the selected apps for a clean state. Apps are never killed or restarted automatically; direct access restoration and a kill switch are not guaranteed.",
    ),
    "processProxyDataTruncated": MessageLookupByLibrary.simpleMessage(
      "Display limited to the first 48 KiB. Narrow the query or read another page for more data.",
    ),
    "processProxyDatagrams": MessageLookupByLibrary.simpleMessage(
      "Datagram boundaries",
    ),
    "processProxyDatagramsHelp": MessageLookupByLibrary.simpleMessage(
      "Only backend-provided byte offsets and lengths are shown. They describe captured payload datagrams, not IP packets or inferred boundaries. Select a nonempty datagram, then explicitly read its bounded prefix.",
    ),
    "processProxyDecryptHttps": MessageLookupByLibrary.simpleMessage(
      "Allow HTTPS decryption when monitoring is explicitly started",
    ),
    "processProxyDecryptQuic": MessageLookupByLibrary.simpleMessage(
      "Allow QUIC decryption when monitoring is explicitly started",
    ),
    "processProxyDirectMode": MessageLookupByLibrary.simpleMessage(
      "Direct mode is selected. Choose Rule or Global mode and a proxy node before launching; this page never changes your routing mode automatically.",
    ),
    "processProxyDirectory": MessageLookupByLibrary.simpleMessage(
      "Absolute local directory path",
    ),
    "processProxyDnsHelp": MessageLookupByLibrary.simpleMessage(
      "Off by default to preserve local and corporate split DNS. Local DNS queries may be visible to your network. Private DNS is never forcibly redirected.",
    ),
    "processProxyEmptyPacket": MessageLookupByLibrary.simpleMessage(
      "Zero-length datagram; no payload read.",
    ),
    "processProxyEncryptedPayload": MessageLookupByLibrary.simpleMessage(
      "Encrypted TLS/QUIC payload: plaintext is unavailable in this snapshot. Raw/Hex does not decrypt it.",
    ),
    "processProxyEndpoint": MessageLookupByLibrary.simpleMessage(
      "Current local endpoint",
    ),
    "processProxyErrorArchitecture": MessageLookupByLibrary.simpleMessage(
      "The experimental native bridge currently supports x64 root applications only. Choose a supported x64 executable; no existing process will be attached automatically.",
    ),
    "processProxyErrorAuthentication": MessageLookupByLibrary.simpleMessage(
      "The local proxy rejected authentication. Check FlClash’s proxy username and password settings. Credentials are not included in this error.",
    ),
    "processProxyErrorBackendVersion": MessageLookupByLibrary.simpleMessage(
      "Select the official ProxyLane64.exe from a complete ProxyLane v1.3.5 installation. The selected version is unsupported.",
    ),
    "processProxyErrorBridge": MessageLookupByLibrary.simpleMessage(
      "The native bridge is unavailable or rejected the operation. Verify the compatible Windows bridge build and selected backend, then start a new session.",
    ),
    "processProxyErrorBusy": MessageLookupByLibrary.simpleMessage(
      "A launch is already in progress. Wait for it to finish before trying again.",
    ),
    "processProxyErrorCaRequired": MessageLookupByLibrary.simpleMessage(
      "Decryption needs an initialized, explicitly trusted current-user CA. Review the Certificates tab; this operation never installs trust automatically.",
    ),
    "processProxyErrorChildRule": MessageLookupByLibrary.simpleMessage(
      "Invalid child-process rule. Use one local full path/glob or EXE name per line; UNC paths, traversal and command-line syntax are not allowed.",
    ),
    "processProxyErrorCidr": m65,
    "processProxyErrorComponents": MessageLookupByLibrary.simpleMessage(
      "Required ProxyLane components are missing. Extract the complete official package into one folder and select its ProxyLane64.exe again.",
    ),
    "processProxyErrorCoreChanged": MessageLookupByLibrary.simpleMessage(
      "FlClash stopped or its proxy configuration changed during launch. Check the current state, then start a new session.",
    ),
    "processProxyErrorDirectory": MessageLookupByLibrary.simpleMessage(
      "Choose an existing local directory using its absolute path. Network shares and links are not accepted.",
    ),
    "processProxyErrorExecutable": MessageLookupByLibrary.simpleMessage(
      "Select an existing local .exe file with an absolute path. Shortcuts, network paths and command strings are not supported.",
    ),
    "processProxyErrorGeneric": MessageLookupByLibrary.simpleMessage(
      "The operation could not be completed. Check the selected files and current core state, then retry. Sensitive diagnostic details are hidden.",
    ),
    "processProxyErrorHook": MessageLookupByLibrary.simpleMessage(
      "ProxyLane could not initialize proxying in the selected application. It may be incompatible or protected. Do not disable security protections; try a supported application.",
    ),
    "processProxyErrorListener": MessageLookupByLibrary.simpleMessage(
      "The configured local proxy did not answer the expected protocol handshake. Confirm that FlClash is running and its mixed, SOCKS or HTTP listener is enabled.",
    ),
    "processProxyErrorMonitoringActive": MessageLookupByLibrary.simpleMessage(
      "Stop monitoring and recording before changing capture limits, opening replay or changing certificate trust.",
    ),
    "processProxyErrorNativeRequired": MessageLookupByLibrary.simpleMessage(
      "This option requires FlClashProxyBridge.exe. The compatibility launcher cannot apply it safely.",
    ),
    "processProxyErrorPathLength": MessageLookupByLibrary.simpleMessage(
      "The current backend limits paths to 240 UTF-8 bytes. Choose a shorter local path. Unicode and staging-path compatibility still require Windows validation.",
    ),
    "processProxyErrorProcessQuery": MessageLookupByLibrary.simpleMessage(
      "Windows could not finish reading the accessible process list. Retry the search, or choose the application’s .exe file directly.",
    ),
    "processProxyErrorQuic": MessageLookupByLibrary.simpleMessage(
      "QUIC decryption requires UDP. Explicitly turn off “Block UDP” before enabling this option.",
    ),
    "processProxyErrorQuicPrepare": MessageLookupByLibrary.simpleMessage(
      "This application was not prepared for QUIC inspection. Exit it yourself, then relaunch with explicit QUIC preparation before enabling QUIC decryption.",
    ),
    "processProxyErrorQuicSocks": MessageLookupByLibrary.simpleMessage(
      "QUIC preparation requires the running core’s SOCKS5 or mixed listener, not HTTP-only mode.",
    ),
    "processProxyErrorRecordingState": MessageLookupByLibrary.simpleMessage(
      "The backend did not confirm the requested recording state. Do not assume recording has started or stopped. Stop this session, review its local recording directory, then start a new session before enabling monitoring or recording again.",
    ),
    "processProxyErrorResponseLarge": MessageLookupByLibrary.simpleMessage(
      "The request or response exceeds the safe size limit. Reduce the record limit, preview size or input length and retry.",
    ),
    "processProxyErrorRule": m66,
    "processProxyErrorRuleLimit": MessageLookupByLibrary.simpleMessage(
      "Rule lists exceed their limit: up to 512 IP/domain rules or 128 child-process rules, and 16 KiB of text per list.",
    ),
    "processProxyErrorSession": MessageLookupByLibrary.simpleMessage(
      "This backend session is no longer available. Close the target application yourself and launch a new session if needed.",
    ),
    "processProxyErrorSettings": MessageLookupByLibrary.simpleMessage(
      "Saved process-proxy settings could not be read. Re-enter the settings and save them again.",
    ),
    "processProxyErrorTrust": MessageLookupByLibrary.simpleMessage(
      "Review the backend path and explicitly confirm that you trust it.",
    ),
    "processProxyErrorWindows": MessageLookupByLibrary.simpleMessage(
      "Process proxying currently requires Windows and its standard local process-query tools.",
    ),
    "processProxyErrorWorkingDirectory": MessageLookupByLibrary.simpleMessage(
      "Use an existing absolute local working directory, without UNC paths, traversal or alternate data streams.",
    ),
    "processProxyExited": MessageLookupByLibrary.simpleMessage(
      "Backend exited",
    ),
    "processProxyExperimentalHint": MessageLookupByLibrary.simpleMessage(
      "Experimental: Windows runtime validation is still pending. Results below come from this session’s actual backend, never simulated. Refresh is manual.",
    ),
    "processProxyFailed": m67,
    "processProxyGoncUnsupported": MessageLookupByLibrary.simpleMessage(
      "The GONC TLS-PSK encrypted proxy entry is incompatible with a normal local FlClash listener. It will not switch to a remote server to bypass the selected node.",
    ),
    "processProxyHeaders": MessageLookupByLibrary.simpleMessage(
      "Headers (ordered; duplicates retained)",
    ),
    "processProxyHeadersUnavailable": MessageLookupByLibrary.simpleMessage(
      "Header metadata is unavailable in this snapshot.",
    ),
    "processProxyHex": MessageLookupByLibrary.simpleMessage("Hex"),
    "processProxyInformational": MessageLookupByLibrary.simpleMessage(
      "Informational response",
    ),
    "processProxyInitializeCa": MessageLookupByLibrary.simpleMessage(
      "Initialize CA material",
    ),
    "processProxyIntro": MessageLookupByLibrary.simpleMessage(
      "Launch only the applications you choose through the current FlClash proxy. System proxy and TUN stay off.",
    ),
    "processProxyInvalidArguments": MessageLookupByLibrary.simpleMessage(
      "Arguments must be a JSON array containing only strings.",
    ),
    "processProxyJsonObjectRequired": MessageLookupByLibrary.simpleMessage(
      "Enter a valid JSON object with the documented fields.",
    ),
    "processProxyLaunch": MessageLookupByLibrary.simpleMessage(
      "Launch through proxy",
    ),
    "processProxyMessageIncomplete": MessageLookupByLibrary.simpleMessage(
      "Message completion was not confirmed.",
    ),
    "processProxyMonitor": MessageLookupByLibrary.simpleMessage(
      "Traffic monitoring",
    ),
    "processProxyNativeWorkspace": MessageLookupByLibrary.simpleMessage(
      "Native advanced workspace",
    ),
    "processProxyNoData": MessageLookupByLibrary.simpleMessage(
      "No response loaded. Use a read or refresh action.",
    ),
    "processProxyNoPort": MessageLookupByLibrary.simpleMessage(
      "No supported local proxy port is enabled.",
    ),
    "processProxyNoProcesses": MessageLookupByLibrary.simpleMessage(
      "No matching accessible applications. You can choose an .exe file instead.",
    ),
    "processProxyOffset": MessageLookupByLibrary.simpleMessage("Byte offset"),
    "processProxyOnlyRules": MessageLookupByLibrary.simpleMessage(
      "Only proxy these IPs / domains (optional)",
    ),
    "processProxyOnlyRulesHelp": MessageLookupByLibrary.simpleMessage(
      "One IP, supported CIDR or domain pattern per line. Empty means all destinations; unmatched destinations go direct. Bypass rules always win. IP rules apply only when the application exposes the IP to the backend; add internal domain names explicitly. Changes apply to the next launch.",
    ),
    "processProxyOpenBackend": MessageLookupByLibrary.simpleMessage(
      "Advanced workspace (native ProxyLane window)",
    ),
    "processProxyOpenReplay": MessageLookupByLibrary.simpleMessage(
      "Open recording directory",
    ),
    "processProxyOverview": MessageLookupByLibrary.simpleMessage("Overview"),
    "processProxyPacketCount": m68,
    "processProxyPacketLimit": MessageLookupByLibrary.simpleMessage(
      "Only the first 128 indexed datagrams per direction are shown; additional or unindexed packets may exist.",
    ),
    "processProxyPacketMetadata": m69,
    "processProxyPacketPrefix": m70,
    "processProxyPacketsUnavailable": MessageLookupByLibrary.simpleMessage(
      "No datagram index was supplied; boundaries cannot be reconstructed here.",
    ),
    "processProxyPayloadDecode": MessageLookupByLibrary.simpleMessage(
      "Read decoded preview",
    ),
    "processProxyPayloadDns": MessageLookupByLibrary.simpleMessage(
      "Decode DNS",
    ),
    "processProxyPayloadDoh": MessageLookupByLibrary.simpleMessage(
      "Decode DoH",
    ),
    "processProxyPayloadHelp": MessageLookupByLibrary.simpleMessage(
      "Read captured or replayed data only, at most 64 KiB per request. This is payload/stream data, not raw HTTP/2 or QUIC network frames.",
    ),
    "processProxyPayloadRead": MessageLookupByLibrary.simpleMessage(
      "Read raw payload",
    ),
    "processProxyPayloadUnavailable": MessageLookupByLibrary.simpleMessage(
      "Payload is not ready, has been evicted, or is incomplete. Check the status and warnings below.",
    ),
    "processProxyPayloadViewer": MessageLookupByLibrary.simpleMessage(
      "Payload Raw / Hex preview",
    ),
    "processProxyPrepareQuic": MessageLookupByLibrary.simpleMessage(
      "Prepare this launch for QUIC inspection",
    ),
    "processProxyPrepareQuicHelp": MessageLookupByLibrary.simpleMessage(
      "Explicit opt-in before launch. Requires the native bridge, SOCKS5 and unblocked UDP. Changes browser compatibility preferences for this process tree until those applications exit. This does not start monitoring, decryption or certificate installation.",
    ),
    "processProxyPrivate": MessageLookupByLibrary.simpleMessage(
      "Bypass private networks",
    ),
    "processProxyProfiles": MessageLookupByLibrary.simpleMessage(
      "Launch profiles",
    ),
    "processProxyProfilesConflict": MessageLookupByLibrary.simpleMessage(
      "A profile name or ID is duplicated. Rename or remove the conflicting profile; nothing was overwritten.",
    ),
    "processProxyProfilesEmpty": MessageLookupByLibrary.simpleMessage(
      "No launch profiles yet.",
    ),
    "processProxyProfilesExport": MessageLookupByLibrary.simpleMessage(
      "Export profiles",
    ),
    "processProxyProfilesExportConfirm": MessageLookupByLibrary.simpleMessage(
      "Export a plaintext JSON file using the argument option shown on this page? Check paths and arguments for secrets before sharing. Backend trust, proxy credentials and sensitive-feature consent are never exported.",
    ),
    "processProxyProfilesExportHelp": MessageLookupByLibrary.simpleMessage(
      "Export omits all arguments by default. Paths, names and bypass rules remain plaintext. Enabling arguments may disclose passwords or tokens; export only to a trusted location.",
    ),
    "processProxyProfilesHelp": MessageLookupByLibrary.simpleMessage(
      "Save up to 32 launch profiles locally. Settings and backups are plaintext; arguments may contain secrets. Loading only fills the form, never launches or changes an active session. Backend trust and capture/QUIC consent are always reset.",
    ),
    "processProxyProfilesImport": MessageLookupByLibrary.simpleMessage(
      "Import profiles",
    ),
    "processProxyProfilesImportConfirm": m71,
    "processProxyProfilesIncludeArguments":
        MessageLookupByLibrary.simpleMessage(
          "Include command-line arguments in export",
        ),
    "processProxyProfilesInvalid": MessageLookupByLibrary.simpleMessage(
      "Invalid launch-profile JSON, version, name or field type. Existing profiles were not changed.",
    ),
    "processProxyProfilesLimit": MessageLookupByLibrary.simpleMessage(
      "At most 32 profiles are allowed. Remove an unused profile first.",
    ),
    "processProxyProfilesLoadConfirm": m72,
    "processProxyProfilesSaveCurrent": MessageLookupByLibrary.simpleMessage(
      "Save current form as profile",
    ),
    "processProxyProfilesStorage": MessageLookupByLibrary.simpleMessage(
      "Cannot read or save the local profile file. Check file permissions and free space, then retry.",
    ),
    "processProxyProfilesTooLarge": MessageLookupByLibrary.simpleMessage(
      "Profile files must not exceed 256 KiB. Existing profiles were not changed.",
    ),
    "processProxyReadDetails": MessageLookupByLibrary.simpleMessage(
      "Read details",
    ),
    "processProxyReadNext": MessageLookupByLibrary.simpleMessage(
      "Read next records",
    ),
    "processProxyReadQuery": MessageLookupByLibrary.simpleMessage(
      "Read-only detail query (JSON object)",
    ),
    "processProxyReadQueryHelp": MessageLookupByLibrary.simpleMessage(
      "Use backend IDs from a response. Allowed query types include poll, stats, cache_read, cache_decode, dns_read, recording_page and recording_detail. This field cannot run commands.",
    ),
    "processProxyRebuildIndex": MessageLookupByLibrary.simpleMessage(
      "Recover recording index",
    ),
    "processProxyRebuildIndexWarning": MessageLookupByLibrary.simpleMessage(
      "Rebuild the index only for the explicitly selected local recording folder. This writes index metadata but does not resend network requests. Failures and timeouts are never retried automatically. Confirm you have a backup and keep monitoring stopped.",
    ),
    "processProxyReconnect": MessageLookupByLibrary.simpleMessage(
      "Rebuild this session’s TCP connections",
    ),
    "processProxyReconnectConfirm": m73,
    "processProxyReconnectNone": MessageLookupByLibrary.simpleMessage(
      "This session has no TCP connections to rebuild.",
    ),
    "processProxyRecording": MessageLookupByLibrary.simpleMessage("Recording"),
    "processProxyRecordingAll": MessageLookupByLibrary.simpleMessage(
      "All protocols",
    ),
    "processProxyRecordingBrowser": MessageLookupByLibrary.simpleMessage(
      "Browse offline recording",
    ),
    "processProxyRecordingBrowserHelp": MessageLookupByLibrary.simpleMessage(
      "First open a local recording in the recording workspace. This browser only reads that recording; it never sends captured requests or starts monitoring. Set filters, then refresh. Pages use record offsets, not the live-traffic cursor.",
    ),
    "processProxyRecordingCapacity": MessageLookupByLibrary.simpleMessage(
      "Recording capacity (MiB)",
    ),
    "processProxyRecordingChanged": MessageLookupByLibrary.simpleMessage(
      "The opened recording changed while paging. Old rows were cleared; refresh from the first page before reading details.",
    ),
    "processProxyRecordingDetails": MessageLookupByLibrary.simpleMessage(
      "Recorded session details",
    ),
    "processProxyRecordingNext": MessageLookupByLibrary.simpleMessage(
      "Next page",
    ),
    "processProxyRecordingNoPayload": MessageLookupByLibrary.simpleMessage(
      "This connection-only record has no payload cache ID. Its metadata is shown below.",
    ),
    "processProxyRecordingPageSize": MessageLookupByLibrary.simpleMessage(
      "Records per page",
    ),
    "processProxyRecordingPageSummary": m74,
    "processProxyRecordingPrevious": MessageLookupByLibrary.simpleMessage(
      "Previous page",
    ),
    "processProxyRecordingQueryInvalid": MessageLookupByLibrary.simpleMessage(
      "Use a filter of at most 256 UTF-8 bytes without control characters, 1–64 records per page, and a nonnegative record offset.",
    ),
    "processProxyRecordingReserve": MessageLookupByLibrary.simpleMessage(
      "Minimum free disk space (MiB)",
    ),
    "processProxyRecordingStalled": MessageLookupByLibrary.simpleMessage(
      "The backend returned an empty page before the reported end. Pagination is stopped to avoid skipping records or looping. Refresh or inspect the recording status.",
    ),
    "processProxyRecordingWarnings": m75,
    "processProxyRefresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "processProxyRemoteDns": MessageLookupByLibrary.simpleMessage(
      "Resolve public names through the proxy",
    ),
    "processProxyRemoveCa": MessageLookupByLibrary.simpleMessage(
      "Remove current-user CA trust",
    ),
    "processProxyReplay": MessageLookupByLibrary.simpleMessage(
      "Offline replay",
    ),
    "processProxyRequested": MessageLookupByLibrary.simpleMessage(
      "Launch requested",
    ),
    "processProxyRules": MessageLookupByLibrary.simpleMessage(
      "Routing and exclusions",
    ),
    "processProxyRunId": MessageLookupByLibrary.simpleMessage("Run ID"),
    "processProxySafeMode": MessageLookupByLibrary.simpleMessage(
      "Launching is disabled in safe mode.",
    ),
    "processProxySearch": MessageLookupByLibrary.simpleMessage(
      "Find a running application",
    ),
    "processProxySearchHelp": MessageLookupByLibrary.simpleMessage(
      "Selecting a running process only fills its executable path for a new launch. It does not attach, stop or restart that process.",
    ),
    "processProxySearchHint": MessageLookupByLibrary.simpleMessage(
      "Search by name, PID or executable path",
    ),
    "processProxySelectFile": MessageLookupByLibrary.simpleMessage(
      "Choose executable",
    ),
    "processProxySemanticDetails": MessageLookupByLibrary.simpleMessage(
      "Protocol details",
    ),
    "processProxySemanticHelp": MessageLookupByLibrary.simpleMessage(
      "Read-only snapshot from the selected run and record. HTTP fields are semantic metadata, not original wire bytes; opening this page does not read payloads or start capture.",
    ),
    "processProxySemanticUnavailable": MessageLookupByLibrary.simpleMessage(
      "This snapshot has no supported HTTP header or datagram detail. Use the existing metadata and payload views without assuming application message boundaries.",
    ),
    "processProxyServer": MessageLookupByLibrary.simpleMessage(
      "Server → Client",
    ),
    "processProxySessionHelp": MessageLookupByLibrary.simpleMessage(
      "Status tracks the backend process, not verified application traffic. Closing this page does not stop applications. Core shutdown or port changes can interrupt proxying; close the application and start a new session.",
    ),
    "processProxySessionStopWarning": MessageLookupByLibrary.simpleMessage(
      "Stop monitoring, recording and this proxy backend? Running applications will not be terminated; their proxied connections may break. Injected hooks can remain after the backend or core stops, so new connections may fail. Manually restart the selected apps for a clean state. Apps are never killed or restarted automatically; direct access restoration and a kill switch are not guaranteed.",
    ),
    "processProxySessions": MessageLookupByLibrary.simpleMessage(
      "This window’s sessions",
    ),
    "processProxyStartMonitor": MessageLookupByLibrary.simpleMessage(
      "Start monitoring",
    ),
    "processProxyStartRecording": MessageLookupByLibrary.simpleMessage(
      "Start recording",
    ),
    "processProxyStats": MessageLookupByLibrary.simpleMessage(
      "Traffic statistics",
    ),
    "processProxyStatus": MessageLookupByLibrary.simpleMessage(
      "Backend status",
    ),
    "processProxyStopMonitor": MessageLookupByLibrary.simpleMessage(
      "Stop monitoring",
    ),
    "processProxyStopRecording": MessageLookupByLibrary.simpleMessage(
      "Stop recording and monitoring",
    ),
    "processProxyStopSession": MessageLookupByLibrary.simpleMessage(
      "Stop proxy session",
    ),
    "processProxyTakeoverOff": MessageLookupByLibrary.simpleMessage(
      "Turn off system proxy and TUN to use process-only proxying.",
    ),
    "processProxyTarget": MessageLookupByLibrary.simpleMessage(
      "Application to launch",
    ),
    "processProxyTargetPath": MessageLookupByLibrary.simpleMessage(
      "Application .exe path",
    ),
    "processProxyTrailers": MessageLookupByLibrary.simpleMessage("Trailers"),
    "processProxyTrust": MessageLookupByLibrary.simpleMessage(
      "I trust this backend and authorize it to proxy the application I launch.",
    ),
    "processProxyTrustCa": MessageLookupByLibrary.simpleMessage(
      "Trust CA for current user",
    ),
    "processProxyWorkingDirectory": MessageLookupByLibrary.simpleMessage(
      "Working directory (optional)",
    ),
    "processProxyWorkingDirectoryHelp": MessageLookupByLibrary.simpleMessage(
      "Absolute local folder; leave empty to use the target executable’s folder. Requires the native bridge when specified.",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("Please enter a valid interval"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Please enter the auto-update interval",
        ),
    "profileDaysLeft": m76,
    "profileExpiresIn": m77,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "The profile has been modified. Turn off auto update?",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter the profile name",
    ),
    "profileSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Applies to this profile only; anything not added uses its default.",
    ),
    "profileTunSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Applies to this profile only and takes precedence over the TUN override entries in the network settings.",
    ),
    "profileUpdatedAt": m78,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid profile URL",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter the profile URL",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Profiles"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Sort profiles"),
    "project": MessageLookupByLibrary.simpleMessage("Project"),
    "protocol": MessageLookupByLibrary.simpleMessage("Protocol"),
    "protocolParam": MessageLookupByLibrary.simpleMessage("Protocol parameter"),
    "protocolVersion": MessageLookupByLibrary.simpleMessage("Protocol version"),
    "providerInUse": m79,
    "providerUrlTip": MessageLookupByLibrary.simpleMessage(
      "Only remote providers are supported",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("External resources"),
    "proxies": MessageLookupByLibrary.simpleMessage("Proxies"),
    "proxiesCount": m80,
    "proxiesProfileLabel": m81,
    "proxiesRemovedTip": m82,
    "proxiesReplacedTip": m83,
    "proxyChains": MessageLookupByLibrary.simpleMessage("Proxy chain"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Proxy group"),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Proxy group is empty",
    ),
    "proxyGroupInUse": m84,
    "proxyGroupsAfterStart": MessageLookupByLibrary.simpleMessage(
      "Groups show up here once the core starts",
    ),
    "proxyGroupsCount": m85,
    "proxyProviders": MessageLookupByLibrary.simpleMessage("Proxy providers"),
    "proxyType": MessageLookupByLibrary.simpleMessage("Proxy type"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Prune cache"),
    "publicKey": MessageLookupByLibrary.simpleMessage("Public key"),
    "pureBlack": MessageLookupByLibrary.simpleMessage("Pure black"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Pure black mode"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR code"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Scan a QR code to obtain a profile",
    ),
    "qrcodeTooLongTip": MessageLookupByLibrary.simpleMessage(
      "This link is too long for a QR code. Use Copy link instead.",
    ),
    "quickActions": MessageLookupByLibrary.simpleMessage("Quick actions"),
    "quickEdit": MessageLookupByLibrary.simpleMessage("Quick edit"),
    "recentRequests": MessageLookupByLibrary.simpleMessage("Recent requests"),
    "recommendedIcons": MessageLookupByLibrary.simpleMessage("Suggested"),
    "recordType": MessageLookupByLibrary.simpleMessage("Record type"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir port"),
    "redo": MessageLookupByLibrary.simpleMessage("Redo"),
    "regex": MessageLookupByLibrary.simpleMessage("Regex"),
    "releaseMemory": MessageLookupByLibrary.simpleMessage("Release memory"),
    "releaseMemoryFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to release memory",
    ),
    "remote": MessageLookupByLibrary.simpleMessage("Remote"),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "Remote destination",
    ),
    "remoteDnsResolve": MessageLookupByLibrary.simpleMessage(
      "Remote DNS resolution",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "rename": MessageLookupByLibrary.simpleMessage("Rename"),
    "replace": MessageLookupByLibrary.simpleMessage("Replace"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("Replace all"),
    "request": MessageLookupByLibrary.simpleMessage("Request"),
    "requestHeaders": MessageLookupByLibrary.simpleMessage("Request headers"),
    "requests": MessageLookupByLibrary.simpleMessage("Requests"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage(
      "Requests and updates",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Required"),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "This page has changes. Are you sure you want to reset?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to reset?",
    ),
    "resourceUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Auto-update interval",
    ),
    "resourceUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "The auto-update interval must be greater than 0",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("Resources"),
    "respectRules": MessageLookupByLibrary.simpleMessage("Respect rules"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "Respect rules routes DNS connections by the rules and needs a Proxy Server Nameserver.",
    ),
    "responseCode": MessageLookupByLibrary.simpleMessage("Response code"),
    "restart": MessageLookupByLibrary.simpleMessage("Restart"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to restart the core?",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Restore"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("Restore all data"),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage(
      "Restore profiles only",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("Restore strategy"),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage(
      "Compatible",
    ),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage("Override"),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage(
      "Restore successful",
    ),
    "result": MessageLookupByLibrary.simpleMessage("Result"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Route addresses"),
    "routeExcludeAddress": MessageLookupByLibrary.simpleMessage(
      "Route exclude addresses",
    ),
    "routingMark": MessageLookupByLibrary.simpleMessage("Routing mark"),
    "ru": MessageLookupByLibrary.simpleMessage("Russian"),
    "rule": MessageLookupByLibrary.simpleMessage("Rule"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage(
      "Logical rule AND",
    ),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Match the full domain",
    ),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "Match a domain keyword",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Match a domain regex",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Match a domain suffix",
    ),
    "ruleActionDomainWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Wildcard match; only * and ? are supported",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "Match the DSCP mark (tproxy UDP inbound only)",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Match the destination port range",
    ),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Match the IP\'s country code",
    ),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "Match domains in Geosite",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage(
      "Match the inbound name",
    ),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage(
      "Match the inbound port",
    ),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage(
      "Match the inbound type",
    ),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "Match the inbound username; separate multiple usernames with /",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Match the IP\'s ASN",
    ),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "Match an IP address range; IP-CIDR6 is just an alias",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Match an IP address range",
    ),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Match an IP suffix range",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage(
      "Match all requests, no conditions needed",
    ),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Match TCP or UDP",
    ),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage(
      "Logical rule NOT",
    ),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage("Logical rule OR"),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "Match by process name; matches the package name on Android",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Match by process name regex; matches the package name on Android",
    ),
    "ruleActionProcessNameWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Match by process name wildcard; only * and ? are supported",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "Match by the full process path",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Match by process path regex",
    ),
    "ruleActionProcessPathWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Match by process path wildcard; only * and ? are supported",
    ),
    "ruleActionRematchNameDesc": MessageLookupByLibrary.simpleMessage(
      "Match the rematch name; separate multiple names with /",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "Reference a rule set; requires rule-providers",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Match the source IP\'s country code",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Match the source IP\'s ASN",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Match a source IP address range",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Match a source IP suffix range",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Match the source port range",
    ),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "Match into a sub-rule; mind the parentheses",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "Match the Linux user ID",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("Rule is empty"),
    "ruleListInvalid": MessageLookupByLibrary.simpleMessage(
      "The rules must be a YAML list with one rule per item, such as - DOMAIN,example.com,DIRECT",
    ),
    "rulePresetBittorrentDirect": MessageLookupByLibrary.simpleMessage(
      "BitTorrent direct",
    ),
    "rulePresetBlockDot": MessageLookupByLibrary.simpleMessage(
      "Block DNS over TLS",
    ),
    "rulePresetBlockLoopback": MessageLookupByLibrary.simpleMessage(
      "Block proxy loopback",
    ),
    "rulePresetBlockQuic": MessageLookupByLibrary.simpleMessage("Block QUIC"),
    "rulePresetBlockStun": MessageLookupByLibrary.simpleMessage("Block STUN"),
    "rulePresetLanDirect": MessageLookupByLibrary.simpleMessage("LAN direct"),
    "rulePresetSystemServicesDirect": MessageLookupByLibrary.simpleMessage(
      "Apple and Microsoft direct",
    ),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("Rule providers"),
    "ruleSet": MessageLookupByLibrary.simpleMessage("Rule set"),
    "ruleSetEmptyTip": MessageLookupByLibrary.simpleMessage(
      "The rule set has no usable entries",
    ),
    "ruleSetInvalidTip": MessageLookupByLibrary.simpleMessage(
      "This mrs file cannot be read",
    ),
    "ruleSetMixedTip": MessageLookupByLibrary.simpleMessage(
      "The rule set mixes domains and IP ranges, so its type cannot be told",
    ),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Rule target"),
    "ruleTextInvalid": MessageLookupByLibrary.simpleMessage(
      "The rule must start with a supported type, such as DOMAIN,example.com,DIRECT",
    ),
    "rules": MessageLookupByLibrary.simpleMessage("Rules"),
    "rulesCount": m86,
    "runTime": MessageLookupByLibrary.simpleMessage("Run time"),
    "running": MessageLookupByLibrary.simpleMessage("Running"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage("Runtime config"),
    "safeMode": MessageLookupByLibrary.simpleMessage("Safe mode"),
    "safeModeAppTitle": m87,
    "saturation": MessageLookupByLibrary.simpleMessage("Saturation"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Save the changes?"),
    "script": MessageLookupByLibrary.simpleMessage("Script"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Script mode: rewrites the whole profile with an extension script",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage(
      "Scroll to selected",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "seconds": MessageLookupByLibrary.simpleMessage("seconds"),
    "secondsCount": m88,
    "secretKey": MessageLookupByLibrary.simpleMessage("Key"),
    "sectionsInEffect": m89,
    "select": MessageLookupByLibrary.simpleMessage("Select"),
    "selectAll": MessageLookupByLibrary.simpleMessage("Select all"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Please select a rule set",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Please select a split strategy",
    ),
    "send": MessageLookupByLibrary.simpleMessage("Send"),
    "sendFromPhone": MessageLookupByLibrary.simpleMessage("Send from phone"),
    "sendFromPhoneConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Import the link from your phone?",
    ),
    "sendFromPhoneNoNetwork": MessageLookupByLibrary.simpleMessage(
      "This device is not connected to a local network",
    ),
    "sendFromPhonePageHint": MessageLookupByLibrary.simpleMessage(
      "Subscription link or proxy share link",
    ),
    "sendFromPhonePageSent": MessageLookupByLibrary.simpleMessage(
      "Sent. Confirm the import on the other device.",
    ),
    "sendFromPhonePageTitle": MessageLookupByLibrary.simpleMessage(
      "Send a link to FlClash",
    ),
    "sendFromPhonePermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Receiving a link from your phone needs the Nearby devices permission, which lets FlClash reach the local network. Turn it on in the app\'s settings.",
    ),
    "sendFromPhoneTip": MessageLookupByLibrary.simpleMessage(
      "Scan the code with your phone\'s camera and paste the link on the page that opens. Both devices need to be on the same network.",
    ),
    "server": MessageLookupByLibrary.simpleMessage("Server"),
    "serviceAbnormalCount": m90,
    "serviceAllAvailable": MessageLookupByLibrary.simpleMessage(
      "All available",
    ),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("Available"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("Blocked"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("Check all"),
    "serviceComingSoon": MessageLookupByLibrary.simpleMessage("Coming soon"),
    "serviceDisallowedIsp": MessageLookupByLibrary.simpleMessage(
      "Disallowed ISP",
    ),
    "serviceFailed": MessageLookupByLibrary.simpleMessage("Check failed"),
    "serviceManage": MessageLookupByLibrary.simpleMessage("Manage services"),
    "serviceOriginalsOnly": MessageLookupByLibrary.simpleMessage(
      "Originals only",
    ),
    "servicePending": MessageLookupByLibrary.simpleMessage("Not checked"),
    "serviceRestricted": MessageLookupByLibrary.simpleMessage(
      "Access restricted",
    ),
    "serviceShownOnDashboard": MessageLookupByLibrary.simpleMessage(
      "Shown on the dashboard",
    ),
    "serviceStatus": MessageLookupByLibrary.simpleMessage("Service status"),
    "serviceUnavailable": MessageLookupByLibrary.simpleMessage("Unavailable"),
    "serviceUnsupportedRegion": MessageLookupByLibrary.simpleMessage(
      "Region not supported",
    ),
    "settingEntries": MessageLookupByLibrary.simpleMessage("settings"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "settingsCount": m91,
    "shareLinkUnreadable": m92,
    "shareLinksInvalid": MessageLookupByLibrary.simpleMessage(
      "No proxy could be read from the links",
    ),
    "shareQrcodeTip": MessageLookupByLibrary.simpleMessage(
      "Scan with FlClash on another device to import this profile.",
    ),
    "show": MessageLookupByLibrary.simpleMessage("Show"),
    "showLess": MessageLookupByLibrary.simpleMessage("Collapse"),
    "showMore": MessageLookupByLibrary.simpleMessage("Expand"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "Stop button in notification",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("Show password"),
    "sidebar": MessageLookupByLibrary.simpleMessage("Sidebar"),
    "sidebarBlurDesc": MessageLookupByLibrary.simpleMessage(
      "Background blur lets the desktop behind the window show through the sidebar.",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("Silent launch"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Silent launch starts without showing the window.",
    ),
    "singleAdd": MessageLookupByLibrary.simpleMessage("Single add"),
    "singleImport": MessageLookupByLibrary.simpleMessage("Single import"),
    "singleShareLinkOnly": MessageLookupByLibrary.simpleMessage(
      "Enter one link here; edit several from the quick edit of the list",
    ),
    "singleValueTip": m93,
    "size": MessageLookupByLibrary.simpleMessage("Size"),
    "skipCertVerify": MessageLookupByLibrary.simpleMessage(
      "Skip certificate verification",
    ),
    "skipDomain": MessageLookupByLibrary.simpleMessage("Skip domains"),
    "skipDomainDesc": MessageLookupByLibrary.simpleMessage(
      "A sniffed domain on the Skip domains list is not used.",
    ),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage(
      "Skip destination addresses",
    ),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage(
      "Skip source addresses",
    ),
    "slide": MessageLookupByLibrary.simpleMessage("Slide"),
    "sliders": MessageLookupByLibrary.simpleMessage("Sliders"),
    "sniffProtocols": MessageLookupByLibrary.simpleMessage("Protocols"),
    "sniffer": MessageLookupByLibrary.simpleMessage("Sniffer"),
    "snifferStatusDesc": MessageLookupByLibrary.simpleMessage(
      "The sniffer reads the domain from TLS, HTTP and QUIC traffic so rules can match it.",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("SOCKS port"),
    "softStyle": MessageLookupByLibrary.simpleMessage("Soft"),
    "sort": MessageLookupByLibrary.simpleMessage("Sort"),
    "source": MessageLookupByLibrary.simpleMessage("Source"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("Source IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Special proxy"),
    "specialRules": MessageLookupByLibrary.simpleMessage("Special rules"),
    "spectrum": MessageLookupByLibrary.simpleMessage("Spectrum"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("Speed statistics"),
    "splitStrategy": MessageLookupByLibrary.simpleMessage("Split strategy"),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Split strategy cannot be empty",
    ),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("SSIDs are empty"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Stack mode"),
    "stackTrace": MessageLookupByLibrary.simpleMessage("Stack trace"),
    "standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "Standard mode: adds rules on top of the profile",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Start"),
    "startFromScratch": MessageLookupByLibrary.simpleMessage(
      "Start from scratch",
    ),
    "startVpn": MessageLookupByLibrary.simpleMessage("Starting VPN…"),
    "startupAndBackground": MessageLookupByLibrary.simpleMessage(
      "Startup and background",
    ),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "With DNS off, the system DNS is used.",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Stop"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Stopping VPN…"),
    "strategy": MessageLookupByLibrary.simpleMessage("Strategy"),
    "strictRoute": MessageLookupByLibrary.simpleMessage("Strict route"),
    "strictRouteDesc": MessageLookupByLibrary.simpleMessage(
      "Strict route keeps traffic such as DNS from bypassing TUN, and with IPv6 off it blocks this device\'s IPv6 connections.",
    ),
    "style": MessageLookupByLibrary.simpleMessage("Style"),
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Subscription info",
    ),
    "sudoPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Enter your password for sudo",
    ),
    "suspended": MessageLookupByLibrary.simpleMessage("Suspended…"),
    "switchProfile": MessageLookupByLibrary.simpleMessage("Switch profile"),
    "sync": MessageLookupByLibrary.simpleMessage("Sync"),
    "system": MessageLookupByLibrary.simpleMessage("System"),
    "systemApp": MessageLookupByLibrary.simpleMessage("System apps"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("System proxy"),
    "tab": MessageLookupByLibrary.simpleMessage("Tab"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Tab animation"),
    "tapIconToRetry": MessageLookupByLibrary.simpleMessage(
      "Tap the icon to retry",
    ),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage("Tap to authorize"),
    "target": MessageLookupByLibrary.simpleMessage("Target"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP concurrent"),
    "testInterval": MessageLookupByLibrary.simpleMessage("Test interval"),
    "testUrl": MessageLookupByLibrary.simpleMessage("Test URL"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage("Test when used"),
    "textScale": MessageLookupByLibrary.simpleMessage("Text scaling"),
    "textScalePreview": MessageLookupByLibrary.simpleMessage(
      "Text in the app will look like this",
    ),
    "theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Theme color"),
    "themeMode": MessageLookupByLibrary.simpleMessage("Theme mode"),
    "tight": MessageLookupByLibrary.simpleMessage("Tight"),
    "time": MessageLookupByLibrary.simpleMessage("Time"),
    "timeout": MessageLookupByLibrary.simpleMessage("Timeout"),
    "tintedStyle": MessageLookupByLibrary.simpleMessage("Tinted"),
    "tip": MessageLookupByLibrary.simpleMessage("Tip"),
    "toggle": MessageLookupByLibrary.simpleMessage("Toggle"),
    "tolerance": MessageLookupByLibrary.simpleMessage("Tolerance"),
    "tools": MessageLookupByLibrary.simpleMessage("Tools"),
    "torch": MessageLookupByLibrary.simpleMessage("Flashlight"),
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("Downloaded"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Total traffic"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("Uploaded"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("TProxy port"),
    "traffic": MessageLookupByLibrary.simpleMessage("Traffic"),
    "trafficPeak": m94,
    "trafficTotal": m95,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Traffic usage"),
    "transport": MessageLookupByLibrary.simpleMessage("Transport"),
    "transportHeaders": m96,
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunAuthorizationFailed": MessageLookupByLibrary.simpleMessage(
      "TUN could not be authorized, so it was turned off.",
    ),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "TUN works only in administrator mode.",
    ),
    "tunOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Entries added here replace the TUN settings of every profile; anything not added keeps the profile\'s own setting. Entries a custom profile adds itself take precedence.",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("Turn off"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Turn on"),
    "udpRelayMode": MessageLookupByLibrary.simpleMessage("UDP relay mode"),
    "udpTimeout": MessageLookupByLibrary.simpleMessage("UDP timeout"),
    "udpTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "The UDP timeout is in seconds and works only with the gvisor, system and mixed stacks.",
    ),
    "ultra": MessageLookupByLibrary.simpleMessage("Ultra"),
    "undo": MessageLookupByLibrary.simpleMessage("Undo"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("Unified delay"),
    "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Unknown network error",
    ),
    "unmaximize": MessageLookupByLibrary.simpleMessage("Restore down"),
    "unnamed": MessageLookupByLibrary.simpleMessage("Unnamed"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("Unpin window"),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "upload": MessageLookupByLibrary.simpleMessage("Upload"),
    "uploadBandwidth": MessageLookupByLibrary.simpleMessage("Upload bandwidth"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlTip": m97,
    "useHosts": MessageLookupByLibrary.simpleMessage("Use hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("Use system hosts"),
    "usedShort": MessageLookupByLibrary.simpleMessage("used"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("Used traffic"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "value": MessageLookupByLibrary.simpleMessage("Value"),
    "view": MessageLookupByLibrary.simpleMessage("View"),
    "virtualIpv4": MessageLookupByLibrary.simpleMessage("Virtual IPv4"),
    "vividStyle": MessageLookupByLibrary.simpleMessage("Vivid"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "VPN-related configuration change detected",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "VPN routes all system traffic through VpnService automatically.",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "WebDAV configuration",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Whitelist mode"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("Write to system"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "Write to system also sets the system clock; Android ignores it.",
    ),
    "yearsAgo": m98,
    "yearsAgoShort": m99,
    "yes": MessageLookupByLibrary.simpleMessage("Yes"),
    "zhCN": MessageLookupByLibrary.simpleMessage("Simplified Chinese"),
  };
}
