#include "../protocol.hpp"
#include <iostream>
#include <functional>

using namespace flclash_bridge;

int main() {
  std::size_t tests = 0;
  auto check = [&](bool value) {
    if (!value) throw std::runtime_error("check failed");
    ++tests;
  };
  auto rejects = [&](const std::function<void()>& operation) {
    try { operation(); } catch (const std::exception&) { ++tests; return; }
    throw std::runtime_error("unsafe request accepted");
  };
  const std::string token(64, 'a');
  SessionProtocol protocol(token);
  rejects([&] { protocol.Accept(R"({"v":1,"id":1,"op":"status"})"); });
  const auto hello = protocol.Accept(R"({"v":1,"id":1,"op":"hello"})");
  check(hello["args"].is_object());
  rejects([&] { protocol.Accept(R"({"v":1,"id":2,"op":"status"})"); });
  auto request = [&](int id, const std::string& op, const Json& args) {
    return Json{{"v",1},{"id",id},{"op",op},{"token",token},{"args",args}}.dump();
  };
  protocol.Accept(request(2,"status",Json::object()));
  ++tests;
  rejects([&] { protocol.Accept(request(2,"status",Json::object())); });
  rejects([&] { protocol.Accept(request(3,"shell",{{"command","whoami"}})); });
  rejects([&] { Parse(R"({"confirm":false,"confirm":true})"); });
  rejects([&] { Parse(std::string(kMaxRequest + 1, ' ')); });
  rejects([&] { Parse(std::string(30, '[') + "1" + std::string(30, ']')); });
  check(QuoteArgument(L"") == L"\"\"");
  check(QuoteArgument(L"a b") == L"\"a b\"");
  check(QuoteArgument(L"a\"b") == L"\"a\\\"b\"");
  check(QuoteArgument(L"path\\") == L"\"path\\\\\"");
  check(QuoteArgument(L"&whoami") == L"\"&whoami\"");
  check(LocalPath(R"(C:\Tools\app.exe)"));
  check(!LocalPath(R"(\\server\share\app.exe)"));
  check(!LocalPath(R"(C:\dir\..\app.exe)"));
  check(!LocalPath(R"(C:\app.exe:payload)"));
  Json config = {{"backend_directory",R"(C:\session)"},{"port",9527},{"proxy_type","SOCKS5"},
                 {"bypass",Json::array({"127.*:*","*.example.com:*"})}};
  ValidateArgs("configure",config); ++tests;
  auto bad = config; bad["host"]="example.com";
  rejects([&] { ValidateArgs("configure",bad); });
  bad = config; bad["port"]=0;
  rejects([&] { ValidateArgs("configure",bad); });
  bad = config; bad["bypass"]=Json::array({"*:*"});
  rejects([&] { ValidateArgs("configure",bad); });
  bad = config; bad["bypass"]=Json::array({"foo|bar:*"});
  rejects([&] { ValidateArgs("configure",bad); });
  bad = config; bad["bypass"]=Json::array();
  for (int i=0;i<513;++i) bad["bypass"].push_back("example.com:*");
  rejects([&] { ValidateArgs("configure",bad); });
  Json launch={{"executable",R"(C:\Program Files\app.exe)"},{"arguments",Json::array({"a b","&whoami",""})},{"confirm",true}};
  ValidateArgs("launch",launch); ++tests;
  launch["confirm"]=false;
  rejects([&] { ValidateArgs("launch",launch); });
  launch["confirm"]=true; launch["executable"]=R"(C:\app.cmd)";
  rejects([&] { ValidateArgs("launch",launch); });
  ValidateArgs("monitor.start",{{"decrypt_https",false},{"decrypt_quic",false},{"confirm",true}}); ++tests;
  rejects([&] { ValidateArgs("monitor.start",{{"decrypt_https",true}}); });
  ValidateArgs("query",{{"type","poll"},{"limit",64}}); ++tests;
  rejects([&] { ValidateArgs("query",{{"type","poll"},{"limit",65}}); });
  rejects([&] { ValidateArgs("query",{{"type","monitor_start"}}); });
  rejects([&] { ValidateArgs("query",{{"type","shutdown"}}); });
  rejects([&] { ValidateArgs("query",{{"type","recording_open"},{"path",R"(C:\files)"}}); });
  rejects([&] { ValidateArgs("query",{{"type","cache_read"},{"length",65537}}); });
  rejects([&] { ValidateArgs("ca.trust",{{"scope","local-machine"},{"confirm",true}}); });
  rejects([&] { ValidateArgs("ca.trust",{{"scope","current-user"},{"confirm",false}}); });
  ValidateArgs("ca.trust",{{"scope","current-user"},{"confirm",true}}); ++tests;
  rejects([&] { ValidateArgs("capture.options",{{"settings",{{"entry_mib",1024},{"total_mib",512}}},{"confirm",true}}); });
  rejects([&] { ValidateArgs("capture.options",{{"settings",{{"skip_upstream_verify",true}}},{"confirm",true}}); });
  ValidateArgs("recording.start",{{"directory",R"(C:\captures)"},{"confirm",true}}); ++tests;
  rejects([&] { ValidateArgs("recording.start",{{"directory",R"(\\host\captures)"},{"confirm",true}}); });
  rejects([&] { protocol.Accept(request(3,"hello",Json::object())); });
  auto wrong_token = Json::parse(request(3,"status",Json::object()));
  wrong_token["token"] = std::string(64,'b');
  rejects([&] { protocol.Accept(wrong_token.dump()); });
  auto unexpected = Json::parse(request(3,"status",Json::object()));
  unexpected["command"] = "whoami";
  rejects([&] { protocol.Accept(unexpected.dump()); });
  unexpected = Json::parse(request(3,"status",Json::object())); unexpected["id"] = -1;
  rejects([&] { protocol.Accept(unexpected.dump()); });
  unexpected["id"] = 3.5;
  rejects([&] { protocol.Accept(unexpected.dump()); });
  unexpected["id"] = kMaxId + 1;
  rejects([&] { protocol.Accept(unexpected.dump()); });
  unexpected["id"] = 3; unexpected["v"] = 2;
  rejects([&] { protocol.Accept(unexpected.dump()); });
  bad = config; bad["password"] = std::string(128,'a');
  rejects([&] { ValidateArgs("configure",bad); });
  bad = config; bad["password"] = "secret\n[options]";
  rejects([&] { ValidateArgs("configure",bad); });
  bad = config; bad["bypass"] = Json::array({"**:*"});
  rejects([&] { ValidateArgs("configure",bad); });
  bad = config; bad["children"] = "true";
  rejects([&] { ValidateArgs("configure",bad); });
  rejects([&] { ValidateArgs("query",{{"type","cache_read"},{"direction","both"}}); });
  rejects([&] { ValidateArgs("query",{{"type","poll"},{"after",-1}}); });
  rejects([&] { ValidateArgs("replay.open",{{"directory",R"(C:\captures)"},{"confirm",true},{"rebuild_index",true}}); });
  rejects([&] { ValidateArgs("recording.start",{{"directory",R"(C:\captures)"},{"confirm",true},{"capacity_mib",15}}); });
  rejects([&] { ValidateArgs("stop",Json::object()); });
  ValidateArgs("stop",{{"confirm",true}}); ++tests;
  check(!Flag(config, "prepare_quic"));
  bad = config; bad["prepare_quic"] = true;
  rejects([&] { ValidateArgs("configure",bad); });
  bad["confirm_quic"] = true;
  rejects([&] { ValidateArgs("configure",bad); });
  bad["block_udp"] = false;
  ValidateArgs("configure",bad); ++tests;
  bad["proxy_type"] = "HTTP11";
  rejects([&] { ValidateArgs("configure",bad); });
  bad = config; bad["prepare_quic"] = "true";
  rejects([&] { ValidateArgs("configure",bad); });
  bad = config; bad["confirm_quic"] = "true";
  rejects([&] { ValidateArgs("configure",bad); });
  bad = config; bad["prepare_quic"] = false; bad["confirm_quic"] = false;
  ValidateArgs("configure",bad); ++tests;
  bad = config; bad["prepare_quic"] = true; bad["confirm_quic"] = false; bad["block_udp"] = false;
  rejects([&] { ValidateArgs("configure",bad); });
  check(ParentDirectory(L"C:\\app.exe") == L"C:\\");
  check(ParentDirectory(L"C:\\Tools\\app.exe") == L"C:\\Tools");
  check(LocalPath(R"(C:\)", true));
  check(!LocalPath(R"(C:\)"));
  launch["executable"] = R"(C:\Tools\app.exe)";
  launch["working_directory"] = R"(C:\Work)";
  ValidateArgs("launch",launch); ++tests;
  launch["working_directory"] = "";
  ValidateArgs("launch",launch); ++tests;
  launch["working_directory"] = R"(C:\)";
  ValidateArgs("launch",launch); ++tests;
  for (const auto& invalid : {R"(\\server\share)", R"(relative)", R"(C:\dir\..\Work)", R"(C:\Work:stream)", R"(\\?\C:\Work)"}) {
    launch["working_directory"] = invalid;
    rejects([&] { ValidateArgs("launch",launch); });
  }
  launch["working_directory"] = 7;
  rejects([&] { ValidateArgs("launch",launch); });
  ValidateMonitorConfiguration(config, {{"decrypt_https", true}, {"decrypt_quic", false}}); ++tests;
  rejects([&] { ValidateMonitorConfiguration(config, {{"decrypt_quic", true}}); });
  bad = config; bad["prepare_quic"] = true; bad["block_udp"] = false;
  ValidateMonitorConfiguration(bad, {{"decrypt_quic", true}}); ++tests;
  bad["block_udp"] = true;
  rejects([&] { ValidateMonitorConfiguration(bad, {{"decrypt_quic", true}}); });
  bad["block_udp"] = false; bad["proxy_type"] = "HTTP11";
  rejects([&] { ValidateMonitorConfiguration(bad, {{"decrypt_quic", true}}); });
  ValidateArgs("replay.rebuild_index", {{"directory", R"(C:\Recordings)"}, {"confirm", true}}); ++tests;
  rejects([&] { ValidateArgs("replay.rebuild_index", {{"directory", R"(C:\Recordings)"}}); });
  rejects([&] { ValidateArgs("replay.rebuild_index", {{"directory", R"(\\host\recording)"}, {"confirm", true}}); });
  rejects([&] { ValidateArgs("query", {{"type", "recording_open"}, {"rebuild_index", true}}); });
  ValidateArgs("connections.prepare_reconnect", Json::object()); ++tests;
  ValidateArgs("connections.reconnect", {{"preparation_id", "1"}, {"confirm", true}}); ++tests;
  ValidateArgs("connections.cancel_reconnect", {{"preparation_id", "1"}}); ++tests;
  rejects([&] { ValidateArgs("connections.prepare_reconnect", {{"pid", 123}}); });
  rejects([&] { ValidateArgs("connections.reconnect", {{"preparation_id", "1"}}); });
  rejects([&] { ValidateArgs("connections.reconnect", {{"preparation_id", 1}, {"confirm", true}}); });
  rejects([&] { ValidateArgs("connections.reconnect", {{"preparation_id", "1"}, {"confirm", false}}); });
  rejects([&] { ValidateArgs("connections.cancel_reconnect", Json::object()); });
  for (const auto& invalid : {"0", "01", "-1", "1.5", "abc", "9007199254740992", "12345678901234567"}) {
    rejects([&] { PreparationId({{"preparation_id", invalid}}); });
  }
  check(PreparationId({{"preparation_id", "9007199254740991"}}) == kMaxId);
  ProcessIdentityMap identities = {{123, 456}, {7, 89}};
  check(OwnsIdentity(identities, 123, 456));
  check(!OwnsIdentity(identities, 123, 457));
  check(!OwnsIdentity(identities, 124, 456));
  check(!OwnsIdentity(identities, 0, 0));
  check(!OwnsIdentity(identities, 123, 0));
  ReconnectPreparation reconnect;
  rejects([&] { reconnect.Check(1, 0); });
  auto preparation = reconnect.Issue(3, 1000);
  check(preparation == 1 && reconnect.count() == 3);
  check(reconnect.Check(preparation, 1001) == 3);
  check(reconnect.remaining(1001) == 59999);
  rejects([&] { reconnect.Check(preparation + 1, 1001); });
  check(reconnect.Consume(preparation, 1002) == 3 && reconnect.id() == 0);
  rejects([&] { reconnect.Consume(preparation, 1003); });
  preparation = reconnect.Issue(4, 2000);
  check(preparation == 2);
  rejects([&] { reconnect.Check(preparation, 62000); });
  check(reconnect.remaining(62001) == 0);
  reconnect.Clear();
  rejects([&] { reconnect.Check(preparation, 2001); });
  preparation = reconnect.Issue(0, 3000);
  check(reconnect.Consume(preparation, 3001) == 0);
  auto previous = reconnect.Issue(2, 4000);
  preparation = reconnect.Issue(1, 4001);
  rejects([&] { reconnect.Check(previous, 4002); });
  check(reconnect.Consume(preparation, 4002) == 1);
  rejects([&] { reconnect.Issue(1, UINT64_MAX); });
  bad = config;
  bad["include_targets"] = Json::array({"*.example.com:*", "10.*:*"});
  bad["child_filter"] = Json::array({R"(*\helper*.exe)", R"(C:\Tools\*)"});
  bad["child_filter_mode"] = "exclude";
  ValidateArgs("configure", bad); ++tests;
  bad["child_filter_mode"] = "include";
  ValidateArgs("configure", bad); ++tests;
  bad["child_filter"] = Json::array();
  ValidateArgs("configure", bad); ++tests;
  bad["child_filter_mode"] = "other";
  rejects([&] { ValidateArgs("configure", bad); });
  for (const auto& pattern : {R"(*\helper?.exe)", R"(C:\Program Files\*\app.exe)", R"(D:\Tools\*)", R"(*\*.exe)"}) {
    check(CompiledChildPattern(pattern));
  }
  for (const auto& pattern : {R"(helper.exe)", R"(\\host\share\*.exe)", R"(\\?\C:\Tools\*)",
      R"(C:\Tools\..\*)", R"(C:\Tools\.\*)", R"(*\dir\*.exe)", R"(*\..)",
      R"(C:\Tools\a.exe;*)", R"(C:\Tools\a.exe|b.exe)", R"(C:/Tools/*.exe)", R"(C:\Tools\)",
      R"(C:\Tools\file:stream)", R"(*\)", "C:\\Tools\\bad\n.exe"}) {
    check(!CompiledChildPattern(pattern));
  }
  check(!CompiledChildPattern(std::string("C:\\") + std::string(238, 'a')));
  bad = config; bad["child_filter"] = Json::array();
  for (int i=0;i<129;++i) bad["child_filter"].push_back(R"(*\a.exe)");
  rejects([&] { ValidateArgs("configure", bad); });
  bad = config; bad["child_filter"] = Json::array({42});
  rejects([&] { ValidateArgs("configure", bad); });
  bad = config; bad["include_targets"] = Json::array({"*:*"});
  rejects([&] { ValidateArgs("configure", bad); });
  bad["include_targets"] = Json::array({"example.com:*;evil:*"});
  rejects([&] { ValidateArgs("configure", bad); });
  bad["include_targets"] = Json::array();
  for (int i=0;i<513;++i) bad["include_targets"].push_back("example.com:*");
  rejects([&] { ValidateArgs("configure", bad); });
  check(ProxyTargetAllowed(false, false, false));
  check(ProxyTargetAllowed(false, true, true));
  check(!ProxyTargetAllowed(false, true, false));
  check(!ProxyTargetAllowed(true, true, true));
  check(!ProxyTargetAllowed(true, false, false));
  check(ProxyChildAllowed(false, true, false));
  check(ProxyChildAllowed(false, false, true));
  check(ProxyChildAllowed(true, true, true));
  check(!ProxyChildAllowed(true, true, false));
  check(ProxyChildAllowed(true, false, false));
  check(!ProxyChildAllowed(true, false, true));
  std::cout << tests << " portable bridge protocol checks passed\n";
}
