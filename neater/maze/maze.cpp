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
    cout << "opening passages between "; 
    this->dump_out();
    adjr->dump_out();
    cout << endl;

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
    room->dump_out();
    cout << " random beginnings at (" << i << "," << j << ")" << endl;
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

  void Maze::dump_out() {
    for (auto vw : board) {
      cout << "vw: ";
      for (auto vb : vw){
        vb.dump_out();
      }
      cout << endl;
    }
  }
}
