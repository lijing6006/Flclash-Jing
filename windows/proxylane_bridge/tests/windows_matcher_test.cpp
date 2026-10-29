#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include "../windows_patterns.hpp"
#include <iostream>
#include <stdexcept>

using namespace flclash_bridge;

int main() {
  std::size_t count = 0;
  auto check = [&](bool result) {
    if (!result) throw std::runtime_error("Windows wildcard matching differed from the audited contract");
    ++count;
  };
  check(WindowsPatternsMatch(L"C:\\Tools\\Helper.exe", {L"*\\helper.exe"}));
  check(WindowsPatternsMatch(L"C:\\Tools\\helper12.exe", {L"*\\helper*.exe"}));
  check(WindowsPatternsMatch(L"C:\\Tools\\helper1.exe", {L"*\\helper?.exe"}));
  check(!WindowsPatternsMatch(L"C:\\Tools\\helper12.exe", {L"*\\helper?.exe"}));
  check(WindowsPatternsMatch(L"C:\\Program Files\\Tools\\app.exe", {L"C:\\Program Files\\*\\app.exe"}));
  check(!WindowsPatternsMatch(L"D:\\Program Files\\Tools\\app.exe", {L"C:\\Program Files\\*\\app.exe"}));
  check(WindowsPatternsMatch(L"api.example.com:443", {L"*.example.com:*"}));
  check(!WindowsPatternsMatch(L"example.org:443", {L"*.example.com:*"}));
  check(WindowsPatternsMatch(L"127.0.0.1:80", {L"127.*:*"}));
  check(WindowsPatternsMatch(L"[::1]:443", {L"[::1]:*"}));
  check(!WindowsPatternsMatch(L"[2001:db8::1]:443", {L"[::1]:*"}));
  check(!WindowsPatternsMatch(L"C:\\Tools\\app.exe", {}));
  std::cout << count << " Windows matcher checks passed; no backend loaded.\n";
}
