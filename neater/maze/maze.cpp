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
    for (auto i = 0; i < w; ++i) {
      board.insert(board.cend(), vector<Room>(b, Room()));
    }
  }

  void Maze::dump_out() {
    for (auto vw : board) {
      cout << "vw" << endl;
      for (auto vb : vw){
        cout << "vb ";
      }
    }
  }
}
