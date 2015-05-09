#include "maze.hpp"

using namespace std;
using namespace maze;

int main() {
  cout << "rat in the maze\n";
  Maze m {10, 10};
  m.dump_out();
  return 0;
}
