// C++17 on wasip1: classes, virtuals, smart pointers, STL, exceptions.
#include <algorithm>
#include <iostream>
#include <map>
#include <memory>
#include <numeric>
#include <stdexcept>
#include <string>
#include <vector>

struct Shape {
  virtual ~Shape() = default;
  virtual double area() const = 0;
  virtual std::string name() const = 0;
};
struct Rect : Shape {
  double w, h;
  Rect(double w, double h) : w(w), h(h) {
    if (w < 0 || h < 0) throw std::invalid_argument("negative size");
  }
  double area() const override { return w * h; }
  std::string name() const override { return "rect"; }
};
struct Circle : Shape {
  double r;
  explicit Circle(double r) : r(r) {}
  double area() const override { return 3.14159265358979 * r * r; }
  std::string name() const override { return "circle"; }
};

int main() {
  std::vector<std::unique_ptr<Shape>> shapes;
  shapes.push_back(std::make_unique<Rect>(3, 4));
  shapes.push_back(std::make_unique<Circle>(1));
  shapes.push_back(std::make_unique<Rect>(1, 1));
  try {
    shapes.push_back(std::make_unique<Rect>(-1, 2));
  } catch (const std::exception &e) {
    std::cout << "caught: " << e.what() << "\n";
  }
  std::sort(shapes.begin(), shapes.end(), [](auto &a, auto &b) { return a->area() < b->area(); });
  std::map<std::string, int> count;
  for (auto &s : shapes) {
    std::cout << s->name() << " area=" << s->area() << "\n";
    count[s->name()]++;
  }
  double total = std::accumulate(shapes.begin(), shapes.end(), 0.0,
                                 [](double acc, auto &s) { return acc + s->area(); });
  std::cout << "total=" << total << " rects=" << count["rect"] << " circles=" << count["circle"] << "\n";
}
