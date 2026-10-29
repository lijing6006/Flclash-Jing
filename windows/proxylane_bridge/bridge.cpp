#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <winsock2.h>
#include <windows.h>
#include <bcrypt.h>
#include <shlwapi.h>
#include <tlhelp32.h>
#include <tchar.h>
#include <fcntl.h>
#include <io.h>
#include <deque>
#include <exception>
#include <iostream>
#include <map>
#include <memory>
#include <mutex>
#include <string>
#include <vector>

#include "ProxyModule.h"
#include "protocol.hpp"

namespace flclash_bridge {

class Handle {
 public:
  HANDLE value = nullptr;
  explicit Handle(HANDLE handle = nullptr) : value(handle) {}
  ~Handle() { if (value && value != INVALID_HANDLE_VALUE) CloseHandle(value); }
  Handle(const Handle&) = delete;
  Handle& operator=(const Handle&) = delete;
  Handle(Handle&& other) noexcept : value(other.value) { other.value = nullptr; }
};

class StartupJob {
 public:
  Handle job{CreateJobObjectW(nullptr, nullptr)};
  STARTUPINFOEXW startup = {};

  StartupJob() {
    if (!job.value) throw Error("startup_job", "Cannot create an owned startup job");
    JOBOBJECT_EXTENDED_LIMIT_INFORMATION limits = {};
    limits.BasicLimitInformation.LimitFlags = JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE;
    if (!SetInformationJobObject(job.value, JobObjectExtendedLimitInformation, &limits, sizeof(limits))) {
      throw Error("startup_job", "Cannot protect a suspended launch");
    }
    SIZE_T size = 0;
    InitializeProcThreadAttributeList(nullptr, 1, 0, &size);
    if (!size || size > 65536) throw Error("startup_job", "Job-list launch attributes are unavailable");
    attributes_.resize(size);
    startup.lpAttributeList = reinterpret_cast<LPPROC_THREAD_ATTRIBUTE_LIST>(attributes_.data());
    if (!InitializeProcThreadAttributeList(startup.lpAttributeList, 1, 0, &size)) {
      throw Error("startup_job", "Cannot initialize launch attributes");
    }
    initialized_ = true;
    if (!UpdateProcThreadAttribute(startup.lpAttributeList, 0, PROC_THREAD_ATTRIBUTE_JOB_LIST,
                                   &job.value, sizeof(job.value), nullptr, nullptr)) {
      DeleteProcThreadAttributeList(startup.lpAttributeList);
      initialized_ = false;
      throw Error("startup_job", "Atomic owned-process job assignment is unavailable");
    }
    startup.StartupInfo.cb = sizeof(startup);
  }

  ~StartupJob() {
    if (initialized_) DeleteProcThreadAttributeList(startup.lpAttributeList);
  }

  void ReleaseRunningTarget() {
    JOBOBJECT_EXTENDED_LIMIT_INFORMATION limits = {};
    limits.BasicLimitInformation.LimitFlags = JOB_OBJECT_LIMIT_BREAKAWAY_OK;
    if (!SetInformationJobObject(job.value, JobObjectExtendedLimitInformation, &limits, sizeof(limits))) {
      throw Error("startup_job", "Cannot release the completed startup job");
    }
  }

 private:
  bool initialized_ = false;
  std::vector<BYTE> attributes_;
};

std::wstring Wide(const std::string& value) {
  if (value.empty()) return {};
  const auto length = MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS,
                                        value.data(), static_cast<int>(value.size()), nullptr, 0);
  Require(length > 0, "Invalid UTF-8");
  std::wstring result(length, L'\0');
  MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, value.data(),
                      static_cast<int>(value.size()), result.data(), length);
  return result;
}

std::string Utf8(const std::wstring& value) {
  if (value.empty()) return {};
  const auto length = WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS,
                                         value.data(), static_cast<int>(value.size()), nullptr, 0,
                                         nullptr, nullptr);
  if (!length) return "[invalid Unicode]";
  std::string result(length, '\0');
  WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, value.data(),
                      static_cast<int>(value.size()), result.data(), length, nullptr, nullptr);
  return result;
}

std::wstring Canonical(const std::wstring& input) {
  wchar_t output[32768] = {};
  const auto length = GetFullPathNameW(input.c_str(), 32768, output, nullptr);
  if (!length || length >= 32768) throw Error("invalid_path", "Cannot resolve local path");
  std::wstring result(output, length);
  while (result.size() > 3 && result.back() == L'\\') result.pop_back();
  Require(LocalPath(Utf8(result)), "Path must be local and absolute");
  return result;
}

std::wstring ExecutableDirectory() {
  wchar_t path[MAX_PATH] = {};
  const auto length = GetModuleFileNameW(nullptr, path, MAX_PATH);
  if (!length || length >= MAX_PATH) throw Error("invalid_path", "Bridge path is too long");
  std::wstring result(path, length);
  return Canonical(result.substr(0, result.find_last_of(L"\\/")));
}

Handle OpenLocalFile(const std::wstring& path) {
  const auto attributes = GetFileAttributesW(path.c_str());
  if (attributes == INVALID_FILE_ATTRIBUTES ||
      (attributes & (FILE_ATTRIBUTE_DIRECTORY | FILE_ATTRIBUTE_REPARSE_POINT))) {
    throw Error("invalid_file", "Expected an ordinary local file");
  }
  Handle file(CreateFileW(path.c_str(), GENERIC_READ, FILE_SHARE_READ, nullptr,
                          OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr));
  if (file.value == INVALID_HANDLE_VALUE) throw Error("file_unavailable", "Cannot lock selected file");
  wchar_t final_path[32768] = {};
  const auto length = GetFinalPathNameByHandleW(file.value, final_path, 32768, FILE_NAME_NORMALIZED);
  if (!length || length >= 32768) throw Error("invalid_file", "Cannot verify selected path");
  std::wstring resolved(final_path, length);
  if (resolved.rfind(L"\\\\?\\", 0) == 0) resolved.erase(0, 4);
  Require(LocalPath(Utf8(resolved)), "Network and device paths are not accepted");
  return file;
}

std::wstring LocalDirectory(const std::string& input) {
  const auto path = Canonical(Wide(input));
  const auto attributes = GetFileAttributesW(path.c_str());
  if (attributes == INVALID_FILE_ATTRIBUTES || !(attributes & FILE_ATTRIBUTE_DIRECTORY) ||
      (attributes & FILE_ATTRIBUTE_REPARSE_POINT)) {
    throw Error("invalid_directory", "Choose an existing ordinary local directory");
  }
  Handle handle(CreateFileW(path.c_str(), FILE_READ_ATTRIBUTES,
                            FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
                            nullptr, OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, nullptr));
  if (handle.value == INVALID_HANDLE_VALUE) throw Error("invalid_directory", "Cannot inspect selected directory");
  wchar_t resolved[32768] = {};
  const auto length = GetFinalPathNameByHandleW(handle.value, resolved, 32768, FILE_NAME_NORMALIZED);
  if (!length || length >= 32768) throw Error("invalid_directory", "Cannot resolve selected directory");
  std::wstring final_path(resolved, length);
  if (final_path.rfind(L"\\\\?\\", 0) == 0) final_path.erase(0, 4);
  Require(LocalPath(Utf8(final_path)), "Remote and device directories are not accepted");
  return path;
}

void CheckVersion(const std::wstring& path) {
  DWORD ignored = 0;
  const auto size = GetFileVersionInfoSizeW(path.c_str(), &ignored);
  if (!size || size > 1024 * 1024) throw Error("backend_version", "Missing backend version resource");
  std::vector<BYTE> bytes(size);
  if (!GetFileVersionInfoW(path.c_str(), 0, size, bytes.data())) {
    throw Error("backend_version", "Cannot inspect backend version");
  }
  VS_FIXEDFILEINFO* version = nullptr;
  UINT length = 0;
  if (!VerQueryValueW(bytes.data(), L"\\", reinterpret_cast<void**>(&version), &length) ||
      length < sizeof(*version) || version->dwSignature != 0xfeef04bd ||
      HIWORD(version->dwFileVersionMS) != 1 || LOWORD(version->dwFileVersionMS) != 3 ||
      HIWORD(version->dwFileVersionLS) != 5) {
    throw Error("backend_version", "Only the audited ProxyLane 1.3.5 ABI is accepted");
  }
}

void CheckX64Executable(HANDLE file) {
  IMAGE_DOS_HEADER dos = {};
  DWORD count = 0;
  if (!ReadFile(file, &dos, sizeof(dos), &count, nullptr) || count != sizeof(dos) ||
      dos.e_magic != IMAGE_DOS_SIGNATURE || dos.e_lfanew < 64 || dos.e_lfanew > 1024 * 1024) {
    throw Error("invalid_executable", "Invalid PE image");
  }
  LARGE_INTEGER offset = {};
  offset.QuadPart = dos.e_lfanew;
  if (!SetFilePointerEx(file, offset, nullptr, FILE_BEGIN)) {
    throw Error("invalid_executable", "Cannot inspect PE image");
  }
  DWORD signature = 0;
  IMAGE_FILE_HEADER header = {};
  if (!ReadFile(file, &signature, sizeof(signature), &count, nullptr) || count != sizeof(signature) ||
      signature != IMAGE_NT_SIGNATURE ||
      !ReadFile(file, &header, sizeof(header), &count, nullptr) || count != sizeof(header) ||
      header.Machine != IMAGE_FILE_MACHINE_AMD64) {
    throw Error("target_architecture", "Experimental native bridge accepts x64 root executables only");
  }
}

ULONGLONG ProcessTime(HANDLE process) {
  FILETIME created = {}, exited = {}, kernel = {}, user = {};
  if (!GetProcessTimes(process, &created, &exited, &kernel, &user)) return 0;
  return (static_cast<ULONGLONG>(created.dwHighDateTime) << 32) | created.dwLowDateTime;
}

std::string SessionToken() {
  BYTE bytes[32] = {};
  if (BCryptGenRandom(nullptr, bytes, sizeof(bytes), BCRYPT_USE_SYSTEM_PREFERRED_RNG) < 0) {
    throw Error("random_unavailable", "Cannot initialize session authentication");
  }
  const char digits[] = "0123456789abcdef";
  std::string result;
  for (const auto byte : bytes) { result += digits[byte >> 4]; result += digits[byte & 15]; }
  return result;
}

class Runtime final : public IProxySettings, public IProxyLog {
 public:
  ~Runtime() override {
    try { Stop(); } catch (...) { ExitProcess(ERROR_PROCESS_ABORTED); }
    IProxySettings::Detach();
    IProxyLog::Detach();
    if (proxy_ && release_) release_();
    if (winsock_started_) WSACleanup();
  }

  Json Configure(const Json& args) {
    if (proxy_) throw Error("already_configured", "A broker owns exactly one configuration");
    const auto directory = LocalDirectory(args["backend_directory"].get<std::string>());
    if (_wcsicmp(directory.c_str(), ExecutableDirectory().c_str())) {
      throw Error("backend_location", "Stage the bridge beside the selected backend components");
    }
    for (const auto name : {L"ProxyLane.exe", L"ProxyLane64.exe", L"ProxyLaneHook32.dll", L"ProxyLaneHook64.dll"}) {
      const auto path = directory + L"\\" + name;
      file_locks_.push_back(OpenLocalFile(path));
      CheckVersion(path);
    }
    for (const auto name : {L"ProxyLaneMitm64.dll", L"ProxyLaneSecureTransport64.dll"}) {
      const auto path = directory + L"\\" + name;
      if (GetFileAttributesW(path.c_str()) != INVALID_FILE_ATTRIBUTES) file_locks_.push_back(OpenLocalFile(path));
    }
    if (!SetDefaultDllDirectories(LOAD_LIBRARY_SEARCH_DEFAULT_DIRS)) {
      throw Error("dll_policy", "Secure DLL search policy is unavailable");
    }
    const auto hook = directory + L"\\ProxyLaneHook64.dll";
    module_ = LoadLibraryExW(hook.c_str(), nullptr,
                            LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR | LOAD_LIBRARY_SEARCH_SYSTEM32);
    if (!module_) throw Error("backend_load", "Cannot load the selected backend");
    auto create = reinterpret_cast<IGlobalProxy* (WINAPI*)()>(GetProcAddress(module_, "GetGlobalProxyInstance"));
    release_ = reinterpret_cast<BOOL (WINAPI*)()>(GetProcAddress(module_, "ReleaseGlobalProxyInstance"));
    attach_ = reinterpret_cast<DWORD (WINAPI*)(DWORD, DWORD, LPCSTR)>(GetProcAddress(module_, "AttachToI"));
    if (!create || !release_ || !attach_) throw Error("backend_abi", "Missing required backend exports");
    configuration_ = args;
    WSADATA winsock = {};
    if (WSAStartup(MAKEWORD(2, 2), &winsock)) {
      throw Error("winsock_unavailable", "Cannot initialize Winsock");
    }
    winsock_started_ = true;
    proxy_ = create();
    if (!proxy_) throw Error("backend_initialize", "Backend initialization failed");
    proxy_->GetSettingsInstance()->AddInstance(this);
    proxy_->GetLogInstance()->AddInstance(this);
    proxy_->GetMonitorInstance()->SetEnabled(FALSE);
    proxy_->GetTlsControl()->SetEnabled(FALSE, nullptr, 0);
    Query({{"type", "quic_injection_policy"}, {"enabled", false}});
    return Status();
  }

  Json Launch(const Json& args) {
    EnsureConfigured();
    if (root_pid_) throw Error("already_launched", "Each broker owns one root process tree");
    const auto executable = Canonical(Wide(args["executable"].get<std::string>()));
    auto file = OpenLocalFile(executable);
    CheckX64Executable(file.value);
    if (_wcsicmp(executable.c_str(), (ExecutableDirectory() + L"\\FlClashProxyBridge.exe").c_str()) == 0) {
      throw Error("invalid_target", "The broker cannot proxy itself");
    }
    ProbeListener();
    if (!proxy_->EnableProxy()) throw Error("proxy_start", "Backend refused to start");
    std::string pipe(MAX_PATH, '\0');
    if (!proxy_->GetPRCInstance()->GetPRCPipeName(pipe.data(), static_cast<int>(pipe.size()))) {
      throw Error("proxy_pipe", "Backend pipe is unavailable");
    }
    std::wstring command = QuoteArgument(executable);
    for (const auto& argument : args.value("arguments", Json::array())) {
      command += L" " + QuoteArgument(Wide(argument.get<std::string>()));
    }
    if (command.size() >= 32767) throw Error("invalid_arguments", "Windows command line is too long");
    StartupJob startup;
    PROCESS_INFORMATION child = {};
    const auto working = executable.substr(0, executable.find_last_of(L"\\/"));
    if (!CreateProcessW(executable.c_str(), command.data(), nullptr, nullptr, FALSE,
                        CREATE_SUSPENDED | CREATE_UNICODE_ENVIRONMENT | EXTENDED_STARTUPINFO_PRESENT,
                        nullptr, working.c_str(), &startup.startup.StartupInfo, &child)) {
      throw Error("target_start", "Cannot start selected executable without elevation");
    }
    Handle process(child.hProcess), thread(child.hThread);
    bool resumed = false;
    try {
      const auto identity = ProcessTime(process.value);
      if (!identity) throw Error("target_identity", "Cannot establish target process identity");
      {
        std::lock_guard<std::mutex> lock(ownership_lock_);
        owned_[child.dwProcessId] = identity;
      }
      if (!proxy_->GetPRCInstance()->AuthorizeProcessPipeAccess(process.value) ||
          attach_(child.dwProcessId, child.dwThreadId, pipe.c_str()) != 0xff01) {
        throw Error("target_hook", "The selected new process could not be proxied");
      }
      if (ResumeThread(thread.value) == static_cast<DWORD>(-1)) {
        throw Error("target_resume", "Cannot resume the selected process");
      }
      startup.ReleaseRunningTarget();
      resumed = true;
      root_pid_ = child.dwProcessId;
      root_time_ = identity;
      root_handle_ = std::make_unique<Handle>(std::move(process));
      AddLog("launch", "Selected new process started; hook readiness is reported separately", root_pid_);
      return {{"target_pid", root_pid_}, {"creation_time", std::to_string(identity)},
              {"hook_verified", false}, {"status", "started"}};
    } catch (...) {
      if (!resumed) {
        TerminateProcess(process.value, ERROR_CANCELLED);
        WaitForSingleObject(process.value, 5000);
        std::lock_guard<std::mutex> lock(ownership_lock_);
        owned_.erase(child.dwProcessId);
      }
      throw;
    }
  }

  Json Status() {
    Json result = {{"configured", proxy_ != nullptr}, {"pid", GetCurrentProcessId()},
                   {"proxy_running", proxy_ && proxy_->IsProxyEnabled()},
                   {"root_pid", root_pid_}, {"monitoring", monitoring_},
                   {"recording", recording_}, {"replay_open", replay_open_},
                   {"upload_bytes", 0}, {"download_bytes", 0}};
    if (!proxy_) return result;
    ULONGLONG upload = 0, download = 0;
    if (proxy_->IsProxyEnabled()) proxy_->GetPRCInstance()->GetTrafficTotals(upload, download);
    result["upload_bytes"] = upload;
    result["download_bytes"] = download;
    if (root_handle_) {
      DWORD exit_code = STILL_ACTIVE;
      if (GetExitCodeProcess(root_handle_->value, &exit_code)) {
        result["target_running"] = exit_code == STILL_ACTIVE;
        if (exit_code != STILL_ACTIVE) result["target_exit_code"] = exit_code;
      }
      if (proxy_->IsProxyEnabled()) {
        DWORD state = 0, error = 0;
        if (proxy_->GetPRCInstance()->GetProcessHookState(root_pid_, root_time_, &state, &error)) {
          result["hook_state"] = state;
          result["hook_error"] = error;
          result["hook_verified"] = state == PROCESS_HOOK_STATE_SUCCEEDED;
        }
      }
    }
    if (monitoring_) {
      const auto actual = Query({{"type", "monitor_status"}});
      result["monitoring"] = actual.value("monitoring", false);
    }
    return result;
  }

  Json Logs(const Json& args) {
    const auto after = Number(args, "after", 0, kMaxId);
    const auto limit = Number(args, "limit", 1, 128, 64);
    Json records = Json::array();
    auto next = after;
    std::lock_guard<std::mutex> lock(log_lock_);
    for (const auto& log : logs_) {
      const auto sequence = log["sequence"].get<std::uint64_t>();
      if (sequence <= after) continue;
      records.push_back(log);
      next = sequence;
      if (records.size() == limit) break;
    }
    return {{"records", records}, {"next", next},
            {"lost_before", logs_.empty() ? 0 : logs_.front()["sequence"].get<std::uint64_t>() - 1}};
  }

  Json MonitorStart(const Json& args) {
    EnsureRunning();
    const auto https = Flag(args, "decrypt_https");
    const auto quic = Flag(args, "decrypt_quic");
    if (quic && (Flag(configuration_, "block_udp", true) || configuration_["proxy_type"] != "SOCKS5")) {
      throw Error("quic_requires_udp", "QUIC decryption requires SOCKS5 UDP and UDP enabled");
    }
    if (https || quic) {
      const auto ca = Certificate("ca.query");
      if (!ca["initialized"].get<bool>() || !ca["trusted"].get<bool>()) {
        throw Error("certificate_required", "Initialize and trust the current-user CA explicitly first");
      }
    }
    Query({{"type", "quic_injection_policy"}, {"enabled", quic}});
    auto result = Query({{"type", "monitor_start"}, {"decrypt", https}, {"quic", quic}});
    monitoring_ = true;
    return result;
  }

  Json MonitorStop() {
    EnsureConfigured();
    auto result = Query({{"type", "monitor_stop"}});
    const bool was_recording = recording_;
    monitoring_ = false;
    recording_ = false;
    if (was_recording) {
      auto settings = settings_;
      settings["recording"] = {{"enabled", false}};
      Query({{"type", "mitm_options"}, {"settings", settings}});
    }
    return result;
  }

  Json CaptureOptions(const Json& args) {
    EnsureConfigured();
    if (monitoring_) throw Error("monitor_active", "Stop monitoring before changing capture limits");
    auto settings = args["settings"];
    settings["recording"] = {{"enabled", false}};
    const auto result = Query({{"type", "mitm_options"}, {"skip_upstream_verify", false}, {"settings", settings}});
    if (!result.contains("settings")) throw Error("advanced_module_unavailable", "The optional capture module is unavailable");
    settings_ = std::move(settings);
    return result;
  }

  Json RecordingStart(const Json& args) {
    EnsureRunning();
    if (monitoring_) throw Error("monitor_active", "Stop monitoring before starting a recording");
    const auto path = LocalDirectory(args["directory"].get<std::string>());
    auto settings = settings_;
    settings["recording"] = {{"enabled", true}, {"directory", Utf8(path)},
                             {"capacity_mib", Number(args, "capacity_mib", 16, 1048576, 8192)},
                             {"reserve_mib", Number(args, "reserve_mib", 16, 1048576, 512)}};
    Query({{"type", "mitm_options"}, {"skip_upstream_verify", false}, {"settings", settings}});
    try {
      MonitorStart(args);
      const auto status = Query({{"type", "recording_status"}});
      if (!status.value("enabled", false)) throw Error("recording_start", "Recording did not become active");
      recording_ = true;
      return status;
    } catch (...) {
      try { MonitorStop(); } catch (...) {}
      settings["recording"]["enabled"] = false;
      try { Query({{"type", "mitm_options"}, {"settings", settings}}); } catch (...) {}
      throw;
    }
  }

  Json ReplayOpen(const Json& args) {
    EnsureConfigured();
    if (monitoring_) throw Error("monitor_active", "Stop monitoring before opening a recording");
    const auto path = LocalDirectory(args["directory"].get<std::string>());
    const auto result = Query({{"type", "recording_open"}, {"path", Utf8(path)}, {"rebuild_index", false}});
    if (!result.contains("run_id")) throw Error("advanced_module_unavailable", "The optional recording reader is unavailable");
    replay_open_ = true;
    return result;
  }

  Json ReplayClose() {
    EnsureConfigured();
    const auto result = Query({{"type", "recording_close"}});
    replay_open_ = false;
    return result;
  }

  Json Certificate(const std::string& op) {
    EnsureConfigured();
    if (op != "ca.query" && monitoring_) {
      throw Error("monitor_active", "Stop monitoring before changing certificate trust");
    }
    auto action = IProxyTlsControl::QueryCA;
    if (op == "ca.initialize") action = IProxyTlsControl::InitializeCA;
    if (op == "ca.trust") action = IProxyTlsControl::TrustCA;
    if (op == "ca.remove") action = IProxyTlsControl::RemoveCATrust;
    if (op == "ca.trust") {
      const auto status = Certificate("ca.query");
      if (!status["initialized"].get<bool>()) {
        throw Error("certificate_required", "Initialize the CA explicitly before installing trust");
      }
    }
    char output[8192] = {};
    const auto flags = proxy_->GetTlsControl()->ManageCA(action, output, sizeof(output));
    if (flags < 0) throw Error("certificate_operation", Redact(output));
    return {{"flags", flags}, {"initialized", (flags & 1) != 0},
            {"trusted", (flags & 2) != 0}, {"details", std::string(output)}};
  }

  Json Query(const Json& request) {
    EnsureConfigured();
    const auto text = request.dump();
    Require(text.size() <= 4096, "Backend query exceeds 4 KiB");
    std::vector<char> output(kMaxResponse, 0);
    const auto size = proxy_->GetTlsControl()->QueryProtocol(text.c_str(), output.data(), output.size());
    if (size < 0) throw Error("backend_query", Redact(output.data()));
    if (size < 1 || static_cast<std::size_t>(size) > output.size()) {
      throw Error("response_too_large", "Reduce the requested page size; the operation was not retried");
    }
    if (output[static_cast<std::size_t>(size) - 1] != '\0') {
      throw Error("backend_protocol", "Backend response was not terminated");
    }
    auto result = Json::parse(output.data());
    return result.is_object() ? result : Json{{"records", result}};
  }

  void Stop() {
    if (!proxy_) return;
    std::exception_ptr monitor_error;
    if (monitoring_) {
      try { MonitorStop(); } catch (...) { monitor_error = std::current_exception(); }
    }
    if (proxy_->IsProxyEnabled() && !proxy_->DisableProxy()) {
      throw Error("proxy_stop", "Backend did not confirm stop");
    }
    if (monitor_error) std::rethrow_exception(monitor_error);
  }

  BOOL GetProxySettings(LPProxySettingsInfo settings) override try {
    ZeroMemory(settings, sizeof(*settings));
    settings->bHookTCP = TRUE;
    settings->bHookUDP = !Flag(configuration_, "block_udp", true) && configuration_["proxy_type"] == "SOCKS5";
    settings->bBlockUDP = !settings->bHookUDP;
    settings->bHookCreateProcess = Flag(configuration_, "children", true);
    settings->bHookLanIP = TRUE;
    settings->nDNSOption = Flag(configuration_, "remote_dns") ? PSI_DNSOPT_REMOTE : PSI_DNSOPT_LOCAL;
    settings->bRedirectPrivateDNS = FALSE;
    return TRUE;
  } catch (...) { return FALSE; }

  BOOL GetProxyInfo(const LPPRCClient client, LPProxyInfo info) override try {
    {
      std::lock_guard<std::mutex> lock(ownership_lock_);
      const auto found = owned_.find(client->dwPid);
      if (found == owned_.end() || found->second != client->processCreateTime) return FALSE;
    }
    ZeroMemory(info, sizeof(*info));
    info->strProxyType = Wide(configuration_["proxy_type"].get<std::string>()).c_str();
    info->strProxyHost = L"127.0.0.1";
    info->nProxyPort = static_cast<int>(configuration_["port"].get<unsigned>());
    const auto username = Text(configuration_, "username", 127);
    const auto password = Text(configuration_, "password", 127);
    memcpy(info->strProxyUser.szbuf, username.data(), username.size());
    memcpy(info->strProxyPass.szbuf, password.data(), password.size());
    if (client->sType == SOCK_DGRAM) {
      client->uaFlag = UAF_SET_ADDR | UAF_SET_PORT;
      client->udpAddr.SetIPLong(0);
      client->udpAddr.SetPort(0);
    }
    const auto address = Destination(client);
    for (const auto& rule : configuration_.value("bypass", Json::array())) {
      if (PathMatchSpecW(Wide(address).c_str(), Wide(rule.get<std::string>()).c_str())) {
        info->strProxyType = L"NOPROXY";
        info->strProxyUser.szbuf[0] = 0;
        info->strProxyPass.szbuf[0] = 0;
        break;
      }
    }
    return TRUE;
  } catch (...) { return FALSE; }

  void LogText(LPCWSTR text) override try { AddLog("backend", Utf8(std::wstring(text, wcsnlen(text, 2048)))); } catch (...) {  }
  void LogNewProxyTask(const LPPRCClient client) override try { AddLog("connection", Destination(client), client->dwPid); } catch (...) {  }
  void OnHookWsock(LPHookWSockResult result) override try { AddLog("hook", "Hook initialization result", result->dwProcessId, result->err); } catch (...) {  }
  void OnHookLogtext(LPHookLogtext log) override try {
    const auto count = log->len > 0 ? std::min<std::size_t>(static_cast<std::size_t>(log->len), 2048) : 0;
    AddLog("hook_log", Utf8(std::wstring(log->str, wcsnlen(log->str, count))), log->dwProcessId);
  } catch (...) {  }
  void OnChildInjectionResult(LPHookNewProcessInfo child, BOOL succeeded) override try {
    AddLog("child_hook", succeeded ? "Child hook accepted" : "Child hook failed", child->dwProcessId);
    if (!succeeded) {
      std::lock_guard<std::mutex> lock(ownership_lock_);
      owned_.erase(child->dwProcessId);
    }
  } catch (...) {  }
  void OnConnectionEvent(ConnectionEvent event, const LPPRCClient client, LPCWSTR) override try {
    AddLog("route", Destination(client), client->dwPid, static_cast<DWORD>(event));
  } catch (...) {  }
  void OnConnectionFailure(const LPPRCClient client, LPCWSTR, ConnectionStage, DWORD error) override try {
    AddLog("connection_failure", Destination(client), client->dwPid, error);
  } catch (...) {  }

  BOOL ShouldInjectNewProcess(LPHookNewProcessInfo child) override try {
    if (!Flag(configuration_, "children", true) || !child->dwProcessId || !child->processCreateTime) return FALSE;
    Handle snapshot(CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0));
    if (snapshot.value == INVALID_HANDLE_VALUE) return FALSE;
    PROCESSENTRY32W entry = {};
    entry.dwSize = sizeof(entry);
    DWORD parent = 0;
    if (Process32FirstW(snapshot.value, &entry)) {
      do {
        if (entry.th32ProcessID == child->dwProcessId) { parent = entry.th32ParentProcessID; break; }
      } while (Process32NextW(snapshot.value, &entry));
    }
    if (!parent) return FALSE;
    Handle parent_handle(OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, parent));
    Handle child_handle(OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, child->dwProcessId));
    if (!parent_handle.value || !child_handle.value) return FALSE;
    const auto parent_time = ProcessTime(parent_handle.value);
    if (ProcessTime(child_handle.value) != child->processCreateTime) return FALSE;
    std::lock_guard<std::mutex> lock(ownership_lock_);
    const auto owned = owned_.find(parent);
    if (owned == owned_.end() || owned->second != parent_time || owned_.size() >= 4096) return FALSE;
    owned_[child->dwProcessId] = child->processCreateTime;
    return TRUE;
  } catch (...) { return FALSE; }

 private:
  void EnsureConfigured() const {
    if (!proxy_) throw Error("not_configured", "Configure this session before using its backend");
  }
  void EnsureRunning() const {
    EnsureConfigured();
    if (!proxy_->IsProxyEnabled()) throw Error("proxy_not_running", "Launch the selected application first");
  }
  void ProbeListener() {
    SOCKET socket = ::socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (socket == INVALID_SOCKET) throw Error("listener_unavailable", "Cannot probe loopback listener");
    sockaddr_in address = {};
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    address.sin_port = htons(static_cast<u_short>(configuration_["port"].get<unsigned>()));
    u_long nonblocking = 1;
    bool connected = false;
    if (ioctlsocket(socket, FIONBIO, &nonblocking) == 0) {
      if (connect(socket, reinterpret_cast<sockaddr*>(&address), sizeof(address)) == 0) {
        connected = true;
      } else if (WSAGetLastError() == WSAEWOULDBLOCK) {
        fd_set writable, failed;
        FD_ZERO(&writable); FD_ZERO(&failed);
        FD_SET(socket, &writable); FD_SET(socket, &failed);
        timeval timeout = {3, 0};
        if (select(0, nullptr, &writable, &failed, &timeout) > 0 && FD_ISSET(socket, &writable)) {
          int error = 0, length = sizeof(error);
          connected = getsockopt(socket, SOL_SOCKET, SO_ERROR, reinterpret_cast<char*>(&error), &length) == 0 && error == 0;
        }
      }
    }
    closesocket(socket);
    if (!connected) throw Error("listener_unavailable", "Configured loopback listener is not running");
  }
  std::string Destination(const LPPRCClient client) const {
    const auto port = client->dstAddr.GetPort();
    if (client->szDomainName[0]) {
      return std::string(client->szDomainName, strnlen(client->szDomainName, 256)) + ":" + std::to_string(port);
    }
    char address[INET6_ADDRSTRLEN] = {};
    if (client->dstAddr.IsIPv6()) {
      ProxyInetNtopA(AF_INET6, client->dstAddr.GetAddr6(), address, sizeof(address));
      return "[" + std::string(address) + "]:" + std::to_string(port);
    }
    IN_ADDR value = {};
    value.s_addr = client->dstAddr.GetdwIP();
    ProxyInetNtopA(AF_INET, &value, address, sizeof(address));
    return std::string(address) + ":" + std::to_string(port);
  }
  std::string Redact(std::string message) const {
    for (const auto key : {"password", "username"}) {
      const auto secret = configuration_.value(key, std::string());
      if (secret.empty()) continue;
      std::size_t at = 0;
      while ((at = message.find(secret, at)) != std::string::npos) {
        message.replace(at, secret.size(), "[redacted]");
        at += 10;
      }
    }
    if (message.size() > 4096) message.resize(4096);
    return message;
  }
  void AddLog(const std::string& kind, const std::string& text, DWORD pid = 0, DWORD error = 0) {
    std::lock_guard<std::mutex> lock(log_lock_);
    const auto message = Json::parse(Json(Redact(text)).dump(-1, ' ', false, Json::error_handler_t::replace)).get<std::string>();
    logs_.push_back({{"sequence", ++log_sequence_}, {"kind", kind}, {"message", message},
                     {"pid", pid}, {"error", error}});
    if (logs_.size() > 512) logs_.pop_front();
  }

  HMODULE module_ = nullptr;
  IGlobalProxy* proxy_ = nullptr;
  BOOL (WINAPI* release_)() = nullptr;
  DWORD (WINAPI* attach_)(DWORD, DWORD, LPCSTR) = nullptr;
  std::vector<Handle> file_locks_;
  Json configuration_ = Json::object();
  Json settings_ = Json::object();
  std::unique_ptr<Handle> root_handle_;
  DWORD root_pid_ = 0;
  ULONGLONG root_time_ = 0;
  bool winsock_started_ = false;
  bool monitoring_ = false;
  bool recording_ = false;
  bool replay_open_ = false;
  std::mutex ownership_lock_;
  std::map<DWORD, ULONGLONG> owned_;
  std::mutex log_lock_;
  std::deque<Json> logs_;
  std::uint64_t log_sequence_ = 0;
};

Json Dispatch(Runtime& runtime, const Json& request, const std::string& token) {
  const auto op = request["op"].get<std::string>();
  const auto& args = request["args"];
  if (op == "hello") {
    return {{"session_token", token}, {"pid", GetCurrentProcessId()}, {"experimental", true},
            {"backend_version", "1.3.5"}, {"capabilities", {
                {"native_runtime", true}, {"root_architectures", Json::array({"x64"})},
                {"launch", true}, {"children", true}, {"traffic", true}, {"logs", true},
                {"https_decryption", true}, {"quic_decryption", true}, {"recording", true},
                {"replay", true}, {"current_user_ca", true}, {"attach_existing", false},
                {"terminate_target", false}, {"packaged_apps", false}}}};
  }
  if (op == "configure") return runtime.Configure(args);
  if (op == "launch") return runtime.Launch(args);
  if (op == "status") return runtime.Status();
  if (op == "logs") return runtime.Logs(args);
  if (op == "monitor.start") return runtime.MonitorStart(args);
  if (op == "monitor.stop" || op == "recording.stop") return runtime.MonitorStop();
  if (op == "capture.options") return runtime.CaptureOptions(args);
  if (op == "recording.start") return runtime.RecordingStart(args);
  if (op == "replay.open") return runtime.ReplayOpen(args);
  if (op == "replay.close") return runtime.ReplayClose();
  if (op == "query") return runtime.Query(args);
  if (op.rfind("ca.", 0) == 0) return runtime.Certificate(op);
  if (op == "stop" || op == "shutdown") { runtime.Stop(); return runtime.Status(); }
  throw Error("unsupported_operation", "Operation is not implemented");
}

bool ReadLine(std::string& line) {
  line.clear();
  char value = 0;
  while (std::cin.get(value)) {
    if (value == '\n') return true;
    if (line.size() == kMaxRequest) throw Error("request_too_large", "Request exceeds 64 KiB");
    if (value != '\r') line += value;
  }
  if (!line.empty()) throw Error("incomplete_request", "EOF in a JSON frame");
  return false;
}

int Run() {
  if (GetFileType(GetStdHandle(STD_INPUT_HANDLE)) != FILE_TYPE_PIPE ||
      GetFileType(GetStdHandle(STD_OUTPUT_HANDLE)) != FILE_TYPE_PIPE) return 2;
  SetHandleInformation(GetStdHandle(STD_INPUT_HANDLE), HANDLE_FLAG_INHERIT, 0);
  SetHandleInformation(GetStdHandle(STD_OUTPUT_HANDLE), HANDLE_FLAG_INHERIT, 0);
  _setmode(_fileno(stdin), _O_BINARY);
  _setmode(_fileno(stdout), _O_BINARY);
  const auto token = SessionToken();
  SessionProtocol protocol(token);
  Runtime runtime;
  std::string line;
  while (ReadLine(line)) {
    Json response = {{"v", 1}, {"id", nullptr}, {"ok", false}};
    bool shutdown = false;
    try {
      const auto envelope = Parse(line);
      if (envelope.is_object() && envelope.contains("id")) {
        response["id"] = Number(envelope, "id", 1, kMaxId);
      }
      auto request = protocol.Accept(line);
      response["id"] = request["id"];
      response["result"] = Dispatch(runtime, request, token);
      response["ok"] = true;
      shutdown = request["op"] == "shutdown";
      if (response.dump().size() > kMaxResponse) throw Error("response_too_large", "Request a smaller page");
    } catch (const Error& error) {
      response.erase("result");
      response["ok"] = false;
      response["error"] = {{"code", error.code}, {"message", error.what()}};
    } catch (const std::exception&) {
      response.erase("result");
      response["ok"] = false;
      response["error"] = {{"code", "invalid_or_backend_error"}, {"message", "Operation failed validation or the backend rejected it"}};
    }
    std::cout << response.dump() << '\n' << std::flush;
    if (!std::cout || shutdown) break;
  }
  return 0;
}
}  // namespace flclash_bridge

int wmain() {
  try { return flclash_bridge::Run(); }
  catch (...) { return 1; }
}
