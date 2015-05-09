#include "maze.hpp"

namespace maze 
{
  using namespace std;

  Room::Room() {
    walls = vector<bool>(Dim*2, true);
  }

  Room::~Room() {
  }

  Maze::Maze(int w, int b) : width(w), breadth(b) {
    
  }
}
