#include <string>
#include <iostream>
#include <thread>
#include <vector>
#include <tuple>

/*
  For now, we'll just do a 2-D maze.
  Too much trouble to generalize for the scope
  of this project.
 */

namespace maze 
{
  const int Dim = 2;
  const double room_width = 1.0;
  const double room_breadth = 1.0;

  using namespace std;

  class Room {
  private:
    vector<bool> walls;
    
  public:
    Room();
    ~Room();
  };
  
  /* Maze class
     
     The maze encapsulates a number of rooms of the specification
     given. 

     In this, we shall make simplifying assumptions. 
     
  */

  class Maze {
  private:
    int width;
    int breadth;
    vector<vector<Room>> board;
    
  public:
    Maze(int w, int b);
    void dump_out();
  };
}
