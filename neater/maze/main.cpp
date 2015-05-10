#include "maze.hpp"

using namespace std;
using namespace maze;

int main() {
  cout << "Rat in the proverbial maze\n";
  Maze m {10, 10};
  m.dump_out();
  return 0;
}
