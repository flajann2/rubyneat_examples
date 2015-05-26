#include "maze.hpp"

using namespace std;
using namespace maze;

int main(int ac, char** av) {
  cout << "Rat in the proverbial maze\n";
  auto width = 10;
  auto breadth = 10;
  if (ac == 3) {
    width = stoi(av[1]);
    breadth = stoi(av[2]);
  }
  cout << "width given is " << width << " and breadth given is " << breadth << endl;

  Maze m {width, breadth};
  m.dump_out();
  return 0;
}
