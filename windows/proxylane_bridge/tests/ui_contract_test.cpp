#include "../protocol.hpp"
#include <iostream>

using namespace flclash_bridge;

int main() {
  // Mirror advanced.dart's requests without loading a DLL or starting a process.
  const Json accepted = Json::parse(R"JSON([
    ["configure", {
      "backend_directory": "C:\\Private\\Backend", "port": 9527,
      "proxy_type": "SOCKS5", "prepare_quic": false, "confirm_quic": false
    }],
    ["configure", {
      "backend_directory": "C:\\Private\\Backend", "port": 9527,
      "proxy_type": "SOCKS5", "block_udp": false,
      "prepare_quic": true, "confirm_quic": true
    }],
    ["launch", {
      "executable": "C:\\Tools\\App.exe", "arguments": [],
      "working_directory": "", "confirm": true
    }],
    ["launch", {
      "executable": "C:\\Tools\\App.exe", "arguments": ["argument with spaces"],
      "working_directory": "C:\\Work", "confirm": true
    }],
    ["status", {}],
    ["logs", {"after": 0, "limit": 64}],
    ["query", {"type": "stats"}],
    ["monitor.start", {
      "decrypt_https": false, "decrypt_quic": false, "confirm": true
    }],
    ["monitor.stop", {}],
    ["query", {"type": "poll", "after": 0, "limit": 16, "live_preview": true}],
    ["query", {"type": "monitor_status"}],
    ["capture.options", {
      "settings": {
        "entry_mib": 32, "total_mib": 512, "history_rows": 512,
        "preview_kib": 64, "decode_mib": 4, "connections": 128,
        "pending_requests": 8, "udp_packets": 256, "handshake_seconds": 15
      },
      "confirm": true
    }],
    ["recording.start", {
      "directory": "C:\\Private\\Recordings", "capacity_mib": 8192,
      "reserve_mib": 512, "decrypt_https": false, "decrypt_quic": false,
      "confirm": true
    }],
    ["recording.stop", {}],
    ["query", {"type": "recording_status"}],
    ["replay.open", {"directory": "C:\\Private\\Recordings", "confirm": true}],
    ["replay.close", {}],
    ["replay.rebuild_index", {"directory": "C:\\Private\\Recordings", "confirm": true}],
    ["connections.prepare_reconnect", {}],
    ["connections.reconnect", {"preparation_id": "1", "confirm": true}],
    ["connections.cancel_reconnect", {"preparation_id": "1"}],
    ["query", {"type": "recording_page", "offset": 0, "limit": 16}],
    ["ca.query", {}],
    ["ca.initialize", {"scope": "current-user", "confirm": true}],
    ["ca.trust", {"scope": "current-user", "confirm": true}],
    ["ca.remove", {"scope": "current-user", "confirm": true}]
  ])JSON");

  for (const auto& request : accepted) {
    const auto operation = request[0].get<std::string>();
    try {
      ValidateArgs(operation, request[1]);
    } catch (const std::exception& error) {
      std::cerr << "UI request rejected: " << operation << ": "
                << error.what() << '\n';
      return 1;
    }
  }

  const Json rejected = Json::parse(R"JSON([
    ["configure", {
      "backend_directory": "C:\\Private\\Backend", "port": 9527,
      "proxy_type": "SOCKS5", "block_udp": false,
      "prepare_quic": true, "confirm_quic": false
    }, "confirmation_required"],
    ["configure", {
      "backend_directory": "C:\\Private\\Backend", "port": 9527,
      "proxy_type": "SOCKS5", "block_udp": true,
      "prepare_quic": true, "confirm_quic": true
    }, "invalid_request"],
    ["configure", {
      "backend_directory": "C:\\Private\\Backend", "port": 9527,
      "proxy_type": "HTTP11", "block_udp": false,
      "prepare_quic": true, "confirm_quic": true
    }, "invalid_request"],
    ["launch", {
      "executable": "C:\\Tools\\App.exe", "arguments": [],
      "working_directory": "\\\\server\\share", "confirm": true
    }, "invalid_request"],
    ["launch", {
      "executable": "C:\\Tools\\App.exe", "arguments": [],
      "working_directory": "..\\Work", "confirm": true
    }, "invalid_request"],
    ["replay.rebuild_index", {"directory": "C:\\Private\\Recordings", "confirm": false}, "confirmation_required"],
    ["connections.reconnect", {"preparation_id": "1", "confirm": false}, "confirmation_required"],
    ["connections.reconnect", {"preparation_id": 1, "confirm": true}, "invalid_request"],
    ["connections.reconnect", {"preparation_id": "1", "confirm": true, "pid": 42}, "invalid_request"],
    ["query", {"type": "ca.trust"}, "unsupported_operation"],
    ["ca.trust", {"scope": "machine", "confirm": true}, "invalid_request"],
    ["monitor.start", {
      "decrypt_https": true, "decrypt_quic": true, "confirm": false
    }, "confirmation_required"]
  ])JSON");

  for (const auto& request : rejected) {
    const auto operation = request[0].get<std::string>();
    try {
      ValidateArgs(operation, request[1]);
    } catch (const Error& error) {
      if (error.code == request[2].get<std::string>()) continue;
      std::cerr << "Wrong rejection for " << operation << ": "
                << error.code << '\n';
      return 1;
    } catch (const std::exception& error) {
      std::cerr << "Unexpected validation failure for " << operation << ": "
                << error.what() << '\n';
      return 1;
    }
    std::cerr << "Unsafe UI request accepted: " << operation << '\n';
    return 1;
  }

  std::cout << accepted.size() << " UI request shapes accepted; "
            << rejected.size() << " unsafe shapes rejected. "
            << "Protocol validation only; no backend process started.\n";
}
