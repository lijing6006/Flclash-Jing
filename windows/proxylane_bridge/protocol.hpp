#pragma once

#include <algorithm>
#include <cstdint>
#include <cctype>
#include <initializer_list>
#include <map>
#include <set>
#include <stdexcept>
#include <string>
#include <vector>
#include <nlohmann/json.hpp>

namespace flclash_bridge {
using Json = nlohmann::json;
constexpr std::size_t kMaxRequest = 65536;
constexpr std::size_t kMaxResponse = 1024 * 1024 - 4096;
constexpr std::uint64_t kMaxId = 9007199254740991ULL;

class Error : public std::runtime_error {
 public:
  std::string code;
  Error(std::string value, const std::string& message)
      : std::runtime_error(message), code(std::move(value)) {}
};

inline void Require(bool value, const char* message) {
  if (!value) throw Error("invalid_request", message);
}

inline bool PlainText(const std::string& text, std::size_t max) {
  return text.size() <= max &&
         std::none_of(text.begin(), text.end(), [](unsigned char c) {
           return c < 32 || c == 127;
         });
}

inline bool LocalPath(const std::string& path, bool allow_root = false) {
  if (path.size() < (allow_root ? 3u : 4u) || path.size() > 240 || !PlainText(path, 240)) return false;
  const auto first = path[0];
  if (!((first >= 'A' && first <= 'Z') || (first >= 'a' && first <= 'z')) ||
      path[1] != ':' || (path[2] != '\\' && path[2] != '/')) return false;
  if (path.find_first_of(":\"<>|*?", 2) != std::string::npos) return false;
  std::string normalized = path;
  std::replace(normalized.begin(), normalized.end(), '/', '\\');
  return normalized.find("\\..\\") == std::string::npos &&
         normalized.find("\\.\\") == std::string::npos &&
         normalized.substr(normalized.size() - 3) != "\\..";
}

inline void Keys(const Json& object, std::initializer_list<const char*> allowed) {
  Require(object.is_object(), "Expected an object");
  for (auto it = object.begin(); it != object.end(); ++it) {
    Require(std::find(allowed.begin(), allowed.end(), it.key()) != allowed.end(),
            "Unknown field");
  }
}

inline std::string Text(const Json& object, const char* key, std::size_t max,
                        bool required = false) {
  if (!object.contains(key)) {
    Require(!required, "Missing text field");
    return {};
  }
  Require(object[key].is_string(), "Expected text");
  const auto text = object[key].get<std::string>();
  Require(PlainText(text, max) && (!required || !text.empty()), "Invalid text");
  return text;
}

inline std::uint64_t Number(const Json& object, const char* key,
                            std::uint64_t minimum, std::uint64_t maximum,
                            std::uint64_t fallback = 0) {
  if (!object.contains(key)) return fallback;
  const auto& value = object[key];
  Require(value.is_number_integer() &&
              (value.is_number_unsigned() || value.get<std::int64_t>() >= 0),
          "Expected an unsigned integer");
  const auto n = value.get<std::uint64_t>();
  Require(n >= minimum && n <= maximum, "Integer outside permitted bounds");
  return n;
}

inline bool Flag(const Json& object, const char* key, bool fallback = false) {
  if (!object.contains(key)) return fallback;
  Require(object[key].is_boolean(), "Expected a boolean");
  return object[key].get<bool>();
}

inline std::uint64_t PreparationId(const Json& args) {
  const auto text = Text(args, "preparation_id", 16, true);
  Require(text.front() != '0' && std::all_of(text.begin(), text.end(), [](unsigned char c) {
    return c >= '0' && c <= '9';
  }), "Invalid reconnect preparation identity");
  const auto id = std::stoull(text);
  Require(id <= kMaxId, "Reconnect preparation identity is too large");
  return id;
}

inline void Confirmed(const Json& args) {
  if (!Flag(args, "confirm")) {
    throw Error("confirmation_required", "Explicit confirmation is required");
  }
}

inline Json Parse(const std::string& input) {
  Require(input.size() <= kMaxRequest, "Request exceeds 64 KiB");
  std::vector<std::set<std::string>> keys;
  auto callback = [&](int depth, Json::parse_event_t event, Json& parsed) {
    Require(depth <= 20, "JSON nesting is too deep");
    if (event == Json::parse_event_t::object_start) keys.emplace_back();
    if (event == Json::parse_event_t::key) {
      Require(!keys.empty() && keys.back().insert(parsed.get<std::string>()).second,
              "Duplicate JSON field");
    }
    if (event == Json::parse_event_t::object_end) keys.pop_back();
    return true;
  };
  return Json::parse(input, callback);
}

inline void ValidateSettings(const Json& settings) {
  Keys(settings, {"entry_mib", "total_mib", "history_rows", "preview_kib",
                  "decode_mib", "connections", "pending_requests", "udp_packets",
                  "handshake_seconds"});
  const auto entry = Number(settings, "entry_mib", 1, 1024, 32);
  const auto total = Number(settings, "total_mib", 16, 8192, 512);
  Require(entry <= total, "Single payload limit exceeds total cache limit");
  Number(settings, "history_rows", 128, 10000, 512);
  Number(settings, "preview_kib", 16, 1024, 64);
  Number(settings, "decode_mib", 1, 64, 4);
  Number(settings, "connections", 1, 256, 128);
  Number(settings, "pending_requests", 1, 256, 8);
  Number(settings, "udp_packets", 16, 4096, 256);
  Number(settings, "handshake_seconds", 5, 120, 15);
}

inline void ValidateQuery(const Json& args) {
  Keys(args, {"type", "run_id", "after", "limit", "cache_id", "connection_id",
              "direction", "offset", "length", "preview_bytes", "filter",
              "protocol", "live_preview"});
  const auto type = Text(args, "type", 32, true);
  static const std::set<std::string> supported = {
      "stats", "poll", "cache_status", "cache_read", "cache_decode", "dns_read",
      "doh_read", "recording_status", "recording_page", "recording_detail",
      "monitor_status", "monitor_stop_status"};
  if (!supported.count(type)) throw Error("unsupported_operation", "Query is not allowlisted");
  Text(args, "run_id", 256);
  Text(args, "connection_id", 256);
  Text(args, "filter", 256);
  if (args.contains("direction")) {
    const auto direction = Text(args, "direction", 6);
    Require(direction == "client" || direction == "server", "Invalid direction");
  }
  Number(args, "after", 0, kMaxId);
  Number(args, "cache_id", 0, kMaxId);
  Number(args, "offset", 0, kMaxId);
  Number(args, "limit", 1, 64, 16);
  Number(args, "length", 1, 65536, 65536);
  Number(args, "preview_bytes", 1, 65536, 65536);
  Number(args, "protocol", 0, 6);
  Flag(args, "live_preview");
  Require(args.dump().size() <= 4096, "Backend query exceeds 4 KiB");
}

inline void ValidateTargetPatterns(const Json& patterns) {
  Require(patterns.is_array() && patterns.size() <= 512, "Too many target patterns");
  for (const auto& value : patterns) {
    Require(value.is_string(), "Invalid target pattern");
    const auto pattern = value.get<std::string>();
    const auto colon = pattern.find_last_of(':');
    const auto host = pattern.substr(0, colon);
    Require(std::any_of(host.begin(), host.end(), [](unsigned char c) { return std::isalnum(c); }),
            "A target pattern needs a specific host or network");
    Require(PlainText(pattern, 255) && !pattern.empty() &&
                pattern.find_first_of(";|=\\ \t") == std::string::npos &&
                pattern != "*" && pattern != "*:*" && pattern.find(':') != std::string::npos,
            "Invalid target pattern");
  }
}

inline bool CompiledChildPattern(const std::string& pattern) {
  if (!PlainText(pattern, 240) || pattern.size() < 3 || pattern.find_first_of(";|\"<>/") != std::string::npos) return false;
  std::size_t start = 0;
  if (pattern.rfind("*\\", 0) == 0) {
    start = 2;
    if (pattern.find('\\', start) != std::string::npos || pattern.find(':') != std::string::npos) return false;
  } else {
    if (pattern.size() < 4 || !((pattern[0] >= 'A' && pattern[0] <= 'Z') ||
        (pattern[0] >= 'a' && pattern[0] <= 'z')) || pattern[1] != ':' || pattern[2] != '\\' ||
        pattern.find(':', 2) != std::string::npos) return false;
    start = 3;
  }
  while (start <= pattern.size()) {
    auto end = pattern.find('\\', start);
    if (end == std::string::npos) end = pattern.size();
    const auto component = pattern.substr(start, end - start);
    if (component.empty() || component == "." || component == "..") return false;
    if (end == pattern.size()) break;
    start = end + 1;
  }
  return true;
}

inline bool ProxyTargetAllowed(bool bypass_match, bool has_include_rules, bool include_match) {
  return !bypass_match && (!has_include_rules || include_match);
}

inline bool ProxyChildAllowed(bool has_rules, bool include_mode, bool match) {
  return !has_rules || (include_mode ? match : !match);
}

inline void ValidateArgs(const std::string& op, const Json& args) {
  if (op == "hello" || op == "status" || op == "monitor.stop" ||
      op == "recording.stop" || op == "replay.close" || op == "ca.query" ||
      op == "connections.prepare_reconnect") {
    Keys(args, {});
  } else if (op == "configure") {
    Keys(args, {"backend_directory", "port", "proxy_type", "username", "password",
                "children", "block_udp", "remote_dns", "bypass", "prepare_quic",
                "confirm_quic", "include_targets", "child_filter", "child_filter_mode"});
    Require(LocalPath(Text(args, "backend_directory", 240, true)), "Expected a local directory");
    Require(args.contains("port"), "Missing proxy port");
    Number(args, "port", 1, 65535);
    const auto type = Text(args, "proxy_type", 8, true);
    Require(type == "SOCKS5" || type == "HTTP11", "Unsupported proxy protocol");
    Text(args, "username", 127);
    Text(args, "password", 127);
    Flag(args, "children", true);
    Flag(args, "block_udp", true);
    Flag(args, "remote_dns");
    const bool prepare_quic = Flag(args, "prepare_quic");
    const bool confirm_quic = Flag(args, "confirm_quic");
    if (prepare_quic) {
      if (!confirm_quic) throw Error("confirmation_required", "QUIC compatibility requires separate confirmation");
      Require(type == "SOCKS5" && !Flag(args, "block_udp", true),
              "QUIC compatibility requires SOCKS5 with UDP enabled");
    }
    if (args.contains("bypass")) ValidateTargetPatterns(args["bypass"]);
    if (args.contains("include_targets")) ValidateTargetPatterns(args["include_targets"]);
    if (args.contains("child_filter_mode")) {
      const auto mode = Text(args, "child_filter_mode", 7, true);
      Require(mode == "include" || mode == "exclude", "Invalid child filter mode");
    }
    if (args.contains("child_filter")) {
      Require(args["child_filter"].is_array() && args["child_filter"].size() <= 128, "Too many child patterns");
      for (const auto& value : args["child_filter"]) {
        Require(value.is_string() && CompiledChildPattern(value.get<std::string>()), "Invalid compiled child pattern");
      }
    }
  } else if (op == "launch") {
    Keys(args, {"executable", "arguments", "working_directory", "confirm"});
    Confirmed(args);
    const auto working_directory = Text(args, "working_directory", 240);
    Require(working_directory.empty() || LocalPath(working_directory, true), "Invalid working directory");
    const auto path = Text(args, "executable", 240, true);
    Require(LocalPath(path) && path.size() > 4, "Invalid executable path");
    auto suffix = path.substr(path.size() - 4);
    std::transform(suffix.begin(), suffix.end(), suffix.begin(), [](unsigned char c) {
      return static_cast<char>(std::tolower(c));
    });
    Require(suffix == ".exe", "Only explicit executable paths are accepted");
    if (args.contains("arguments")) {
      Require(args["arguments"].is_array() && args["arguments"].size() <= 128,
              "Invalid arguments array");
      std::size_t total = 0;
      for (const auto& item : args["arguments"]) {
        Require(item.is_string(), "Arguments must be strings");
        const auto argument = item.get<std::string>();
        Require(argument.find('\0') == std::string::npos, "NUL in argument");
        total += argument.size();
      }
      Require(total <= 16000, "Command line is too long");
    }
  } else if (op == "logs") {
    Keys(args, {"after", "limit"});
    Number(args, "after", 0, kMaxId);
    Number(args, "limit", 1, 128, 64);
  } else if (op == "monitor.start") {
    Keys(args, {"decrypt_https", "decrypt_quic", "confirm"});
    Confirmed(args);
    Flag(args, "decrypt_https");
    Flag(args, "decrypt_quic");
  } else if (op == "capture.options") {
    Keys(args, {"settings", "confirm"});
    Confirmed(args);
    Require(args.contains("settings"), "Missing settings");
    ValidateSettings(args["settings"]);
  } else if (op == "recording.start") {
    Keys(args, {"directory", "capacity_mib", "reserve_mib", "decrypt_https",
                "decrypt_quic", "confirm"});
    Confirmed(args);
    Require(LocalPath(Text(args, "directory", 240, true)), "Recording requires a local directory");
    Number(args, "capacity_mib", 16, 1048576, 8192);
    Number(args, "reserve_mib", 16, 1048576, 512);
    Flag(args, "decrypt_https");
    Flag(args, "decrypt_quic");
  } else if (op == "replay.open" || op == "replay.rebuild_index") {
    Keys(args, {"directory", "confirm"});
    Confirmed(args);
    Require(LocalPath(Text(args, "directory", 240, true)), "Replay requires a local directory");
  } else if (op == "connections.reconnect" || op == "connections.cancel_reconnect") {
    if (op == "connections.reconnect") {
      Keys(args, {"preparation_id", "confirm"});
      Confirmed(args);
    } else {
      Keys(args, {"preparation_id"});
    }
    PreparationId(args);
  } else if (op == "query") {
    ValidateQuery(args);
  } else if (op == "ca.initialize" || op == "ca.trust" || op == "ca.remove") {
    Keys(args, {"scope", "confirm"});
    Confirmed(args);
    Require(Text(args, "scope", 16, true) == "current-user", "Only current-user certificate scope is supported");
  } else if (op == "stop" || op == "shutdown") {
    Keys(args, {"confirm"});
    Confirmed(args);
  } else {
    throw Error("unsupported_operation", "Operation is not implemented");
  }
}

using ProcessIdentityMap = std::map<std::uint32_t, std::uint64_t>;

inline bool OwnsIdentity(const ProcessIdentityMap& identities, std::uint32_t pid, std::uint64_t birth) {
  const auto found = identities.find(pid);
  return pid != 0 && birth != 0 && found != identities.end() && found->second == birth;
}

class ReconnectPreparation {
 public:
  static constexpr std::uint64_t kLifetimeMs = 60000;

  std::uint64_t Issue(std::uint64_t count, std::uint64_t now) {
    Require(sequence_ < kMaxId && now <= UINT64_MAX - kLifetimeMs, "Reconnect sequence is exhausted");
    id_ = ++sequence_;
    count_ = count;
    expires_at_ = now + kLifetimeMs;
    return id_;
  }

  std::uint64_t Check(std::uint64_t id, std::uint64_t now) const {
    if (!id_ || id_ != id) throw Error("reconnect_preparation_stale", "Prepare connections again before confirming");
    if (now >= expires_at_) throw Error("reconnect_preparation_expired", "Reconnect confirmation expired; prepare again");
    return count_;
  }

  std::uint64_t Consume(std::uint64_t id, std::uint64_t now) {
    const auto count = Check(id, now);
    Clear();
    return count;
  }

  void Clear() { id_ = 0; count_ = 0; expires_at_ = 0; }
  std::uint64_t id() const { return id_; }
  std::uint64_t count() const { return count_; }
  std::uint64_t remaining(std::uint64_t now) const { return now < expires_at_ ? expires_at_ - now : 0; }

 private:
  std::uint64_t sequence_ = 0;
  std::uint64_t id_ = 0;
  std::uint64_t count_ = 0;
  std::uint64_t expires_at_ = 0;
};

inline void ValidateMonitorConfiguration(const Json& configuration, const Json& args) {
  if (!Flag(args, "decrypt_quic")) return;
  if (!Flag(configuration, "prepare_quic")) {
    throw Error("quic_preparation_required", "Start a new explicitly QUIC-prepared session; existing targets are not modified");
  }
  if (Flag(configuration, "block_udp", true) || configuration["proxy_type"] != "SOCKS5") {
    throw Error("quic_requires_udp", "QUIC decryption requires SOCKS5 UDP and UDP enabled");
  }
}

inline std::wstring ParentDirectory(const std::wstring& executable) {
  const auto separator = executable.find_last_of(L"\\/");
  Require(separator != std::wstring::npos, "Executable has no parent directory");
  return executable.substr(0, separator == 2 ? 3 : separator);
}

inline std::wstring QuoteArgument(const std::wstring& value) {
  std::wstring result = L"\"";
  std::size_t slashes = 0;
  for (const auto ch : value) {
    if (ch == L'\\') { ++slashes; continue; }
    if (ch == L'\"') {
      result.append(slashes * 2 + 1, L'\\');
    } else {
      result.append(slashes, L'\\');
    }
    slashes = 0;
    result += ch;
  }
  result.append(slashes * 2, L'\\');
  return result + L'\"';
}

class SessionProtocol {
 public:
  explicit SessionProtocol(std::string token) : token_(std::move(token)) {}

  Json Accept(const std::string& line) {
    auto request = Parse(line);
    Keys(request, {"v", "id", "token", "op", "args"});
    Require(Number(request, "v", 1, 1) == 1, "Unsupported protocol version");
    const auto id = Number(request, "id", 1, kMaxId);
    Require(id > last_id_, "Request IDs must increase monotonically");
    const auto op = Text(request, "op", 64, true);
    if (!hello_) {
      Require(op == "hello", "First request must be hello");
    } else {
      if (op == "hello") throw Error("already_initialized", "Handshake already completed");
      const auto candidate = Text(request, "token", 64, true);
      unsigned difference = static_cast<unsigned>(candidate.size() ^ token_.size());
      for (std::size_t i = 0; i < token_.size(); ++i) {
        difference |= static_cast<unsigned char>(token_[i]) ^
                      static_cast<unsigned char>(i < candidate.size() ? candidate[i] : 0);
      }
      if (difference) throw Error("authentication_failed", "Invalid session token");
    }
    if (!request.contains("args")) request["args"] = Json::object();
    ValidateArgs(op, request["args"]);
    last_id_ = id;
    hello_ = true;
    return request;
  }

 private:
  std::string token_;
  std::uint64_t last_id_ = 0;
  bool hello_ = false;
};
}  // namespace flclash_bridge
