#include <string>
#include <iostream>
#include <thread>
#include "maze.h"

using namespace std;

int main() {
  cout << "rat in the maze\n";
  Room r;
  for (auto i=0; i < sizeof(r.walls); ++i)
    cout << "room " << i << " is " << r.walls[i]  << endl;
  return 0;
}
