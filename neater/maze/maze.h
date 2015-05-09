//#include <jeayeson/jeayeson.hpp>
#include <string>
#include <iostream>
#include <thread>
#include <vector>
#include <array>

using namespace std;

const int MAZE_DIMENSION = 2;

class Room {
 public: //TODO: make this private!!!
  array<bool, MAZE_DIMENSION * 2> walls {{true, true}};

 public:
  Room();
};

class Maze {
 private:

 public:
  Maze();
};

