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
  std::cout << tests << " portable bridge protocol checks passed\n";
}
