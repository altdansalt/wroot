#include <iostream>
#include <stdexcept>
#include <vector>
int main() {
  try { std::vector<int> v; v.at(5); }
  catch (const std::out_of_range &e) { std::cout << "caught: " << e.what() << std::endl; }
  try { throw 42; } catch (int x) { std::cout << "caught int " << x << std::endl; }
}
