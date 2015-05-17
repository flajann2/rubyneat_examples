#include <string>
#include <iostream>
#include <thread>
#include <vector>
#include <tuple>
#include <random>
#include <map>

/*
  For now, we'll just do a 2-D maze.
  Too much trouble to generalize for the scope
  of this project.
 */

namespace maze 
{
  using namespace std;

  const int Dim = 2;
  const double room_width = 1.0;
  const double room_breadth = 1.0;
  const int x=0;
  const int y=1;
  const int z=2; // for the future, we reserve this for now.
  const int thiswall = 0;
  const int thatwall = 1;

  // dx, dy room offsets for adjoining rooms
  const vector<tuple<int,int>> neighbor_room_offsets {
      make_tuple(-1, 0), 
      make_tuple(1,  0),
      make_tuple(0,  -1), 
      make_tuple(0,  1)
      };

  // this - that -> this_wall_index, that_wall_index
  map<tuple<int,int>, tuple<int,int>> passage {
    {make_tuple(-1, 0), make_tuple(1, 0)},
    {make_tuple(1, 0),  make_tuple(0, 1)},
    {make_tuple(0, -1), make_tuple(3, 2)},
    {make_tuple(0, 1),  make_tuple(2, 3)}
  };


  /*
    See README.md for documentation on the layout, etc.
   */
  class Room { 
    friend class Maze;

  private:
    vector<bool> walls;
    bool visited;
    tuple<int, int> coord;
    class Maze* pm; 

  public:
    Room();
    ~Room();

    vector<Room*> available_neighbors();
    void open_passage(Room* adjoining_room);
    void dump_out();
    auto to_encoded();

  private:
    tuple<int,int> &pass_walls(Room* that);
  };
  
  /* Maze class
     
     The maze encapsulates a number of rooms of the specification
     given. 

     In this, we shall make simplifying assumptions. 
     * All rooms are square, all walls have zero width.
     
  */

  class Maze {
    friend class Room;
    unsigned char *expar = nullptr;

  private:
    int width;
    int breadth;
    double room_size;
    vector<vector<Room>> board;
    
    void init();
    void blaze_the_maze();

  public:
    Maze(int w, int b);
    Maze(int w, int b, double room_size);
    ~Maze();
    vector<Room> &operator[](int i);
    void dump_out();
    auto to_export();
  };
}
