#include "maze.hpp"

namespace maze 
{
  using namespace std;

  Room::Room() {
    walls = vector<bool>(Dim*2, true);
  }

  Room::~Room() {
  }

  // Returns a list of all neighbors not yet
  // visited.
  vector<Room*> Room::available_neighbors() {
    vector<Room*> neighbors {};

    for (auto offset : neighbor_room_offsets) {
      auto i = get<x>(offset) + get<x>(coord);
      auto j = get<y>(offset) + get<y>(coord);
      if (i >= 0 && j >= 0 && i < pm->width && j < pm->breadth)
        if (! (*pm)[i][j].visited)
          neighbors.push_back(&(*pm)[i][j]);
    }
    return neighbors;
  }

  void Room::open_passage(Room* adjr){
    adjr->visited = true;
    auto wpass = pass_walls(adjr);
    walls[get<thiswall>(wpass)] = adjr->walls[get<thatwall>(wpass)] = false;
  }

  tuple<int,int> &Room::pass_walls(Room* that){
    auto index = tuple<int,int> {
        get<x>(coord) - get<x>(that->coord), 
        get<y>(coord) - get<y>(that->coord)
        };
    return passage[index];
  }

  void Room::dump_out() {
    cout << "[";
    cout << get<x>(coord) << "," << get<y>(coord) << ":";
    for (auto wall : walls) 
      cout << wall;
    cout << "]";
  }

  Maze::Maze(int w, int b) : width(w), breadth(b), room_size(10.0) {
    init();
  }

  Maze::Maze(int w, int b, double rs) : width(w),
                                        breadth(b),
                                        room_size(rs) {
    init();
  }

  void Maze::init() {

    for (auto i = 0; i < width; ++i) {
      auto rooms = vector<Room>(breadth, Room());
      for (auto j = 0; j < breadth; ++j) {
        rooms[j].coord = make_tuple(i, j);
        rooms[j].pm = this;
      }
      board.insert(board.cend(), rooms);      
    }
    blaze_the_maze();
  }

  void Maze::blaze_the_maze() {
    // set up random number generation
    random_device rd;
    mt19937 gen(rd());
    uniform_int_distribution<> rw(0, width-1);
    uniform_int_distribution<> rb(0, breadth-1);
    vector<Room*> pool {};

    // randomly select a starting point
    auto i = rw(gen);
    auto j = rb(gen);
    Room* room = &(*this)[i][j];
    pool.push_back(room);

    while(pool.size() > 0) {
      uniform_int_distribution<> rpool(0, pool.size()-1);
      auto rroom = rpool(gen);
      room = pool[rroom];
      auto neighbors = room->available_neighbors();
      if (neighbors.size() > 0) {
        uniform_int_distribution<> rneig(0, neighbors.size()-1);
        auto r = rneig(gen);
        Room* adjoining_room = neighbors[r];
        adjoining_room->visited = true;
        room->open_passage(adjoining_room);
        pool.push_back(adjoining_room);
      } else {
        auto it = pool.cbegin();
        advance(it, rroom);
        pool.erase(it);
      }
    }
  }

  vector<Room> &Maze::operator[](int i) {
    return board[i];
  }

  enum WallMode { top, left, rightend, bottomend };
  const array<WallMode, 3> wallmode = {top, left, bottomend};
  
  void Maze::dump_out() {
    const string UpperWallClosed = "+--";
    const string BottomWall      = "+--";
    const string UpperWallOpened = "+  ";
    const string UpperEndWall    =    "+";
    const string LowerEndWall    =    "+";
    const string LeftWallClosed  = "|  ";
    const string LeftWallOpen    = "   ";
    const string RightEndWall    =    "|";

    for (auto j=breadth-1; j>=0; --j) {
      for (auto wm : wallmode) {
        for(auto i=0; i<width; ++i) {
          Room &r = (*this)[i][j];
          switch (wm) {
          case top: 
            cout << ((r.walls[3]) ? UpperWallClosed : UpperWallOpened); 
            break;
          case left: 
            cout << ((r.walls[0]) ? LeftWallClosed : LeftWallOpen); 
            break;
          case bottomend:
            if (j == 0)
              cout << UpperWallClosed;
            break;
          }
        }
        if (wm != bottomend)
          cout << ((wm == top) ? UpperEndWall : RightEndWall) << endl;
        else if (j == 0)
          cout << LowerEndWall << endl;
      }
    }
  }

  auto Maze::to_export() {
    return nullptr;
  }

  extern "C" auto generate_maze(int width, int breadth) {
    Maze m {width, breadth};
    m.dump_out();
    return m.to_export();
  }
}
