# MAZE C++ Module example

## Prerequisites for Building Maze
* CMake
* C++14

This has been built and tested under Ubuntu Linux as of now.
No plans to test this under distros or OSes are in the works now.
Please feel free to do pull requests for other platforms!

## Room Layout
Given the maze coordinates begin in the lower left
corner, and progress towards the right (x) and up (y),
    
* 0 - lower x
* 1 - upper x
* 2 - lower y
* 3 - upper y

(see `neighbor_room_offsets` and `passage`)


                           (0, 1)
                        y upper wall
                    ---------------------
                    |         3         |
                    |                   |
                    |                   |
       x left wall  | 0               1 | x right wall
         (-1,0)     |                   |   (+1, 0)
                    |                   |
                    |         2         |
                    ---------------------
                        y lower wall
                           (0, -1)

                    Wall indexing in Room
                    as reflected in passage

Adjacent rooms with walls knocked out MUST have
the adjacent wall knocked out.

+--+--+--+--+
|  |  |  |  |
+--+--+--+--+
|  |  |  |  |
+--+--+--+--+
|  |  |  |  |
+--+--+--+--+
|  |  |  |  |
+--+--+--+--+

+--+--+--+--+
|     |     |
+--+  +  +  +
|     |  |  |
+--+  +--+  +
|        |  |
+--+--+  +  +
|           |
+--+--+--+--+
