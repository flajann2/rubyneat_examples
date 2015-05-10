#include <string>
#include <iostream>
#include <thread>
#include <vector>
#include <tuple>
#include <random>

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
  const vector<tuple<int, int>> neighbor_room_offsets {
    make_tuple(-1, 0), make_tuple(1, 0),
      make_tuple(0, -1), make_tuple(0, 1)
      };

  /*
    Room layout:
    Given the maze coordinates begin in the lower left
    corner, and progress towards the right (x) and up (y),
    
    * 0 - lower x
    * 1 - upper x
    * 2 - lower y
    * 3 - upper y
    (see neighbor_room_offsets)

    Adjacent rooms with walls knocked out MUST have
    the adjacent wall knocked out.
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
  };
  
  /* Maze class
     
     The maze encapsulates a number of rooms of the specification
     given. 

     In this, we shall make simplifying assumptions. 
     * All rooms are square, all walls have zero width.
     
  */

  class Maze {
    friend class Room;

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
    vector<Room> &operator[](int i);
    void dump_out();
  };
}
