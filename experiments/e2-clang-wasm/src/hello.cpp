#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
int main() {
  std::vector<std::string> v{"wasm", "hello", "c++"};
  std::sort(v.begin(), v.end());
  for (auto &s : v) std::cout << s << ' ';
  std::cout << std::endl;
  // note: sysroot libc++abi is built without exception support; no try/throw
  return 0;
}
