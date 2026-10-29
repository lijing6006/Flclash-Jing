#pragma once

#include <windows.h>
#include <shlwapi.h>
#include <string>
#include <vector>

namespace flclash_bridge {
inline bool WindowsPatternsMatch(const std::wstring& value, const std::vector<std::wstring>& patterns) {
  for (const auto& pattern : patterns) {
    if (PathMatchSpecW(value.c_str(), pattern.c_str())) return true;
  }
  return false;
}
}  // namespace flclash_bridge
