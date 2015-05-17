# MAZE C++ Module example

## Prerequisites for Building Maze
* CMake
* C++14

This has been built and tested under Ubuntu Linux as of now.
No plans to test this under distros or OSes are in the works now.
Please feel free to do pull requests for other platforms!

## Room Layout, C++ side
Given the maze coordinates begin in the lower left
corner, and progress towards the right (x) and up (y),
    
* 0 - left  x
* 1 - right x
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

### Sample output from Maze
    +--+--+--+--+--+--+--+--+--+--+
    |        |     |              |
    +  +--+--+--+  +--+  +--+--+--+
    |  |  |  |     |  |  |     |  |
    +  +  +  +  +--+  +  +  +--+  +
    |  |  |     |  |              |
    +  +  +--+  +  +--+  +--+--+--+
    |           |     |  |  |     |
    +--+--+--+  +--+  +  +  +  +--+
    |              |              |
    +--+--+  +--+  +  +--+--+  +--+
    |     |  |              |     |
    +--+  +  +  +--+  +--+--+  +--+
    |        |  |        |  |     |
    +  +  +--+  +  +  +  +  +--+--+
    |  |  |     |  |  |     |     |
    +  +--+  +  +  +--+  +  +  +--+
    |     |  |  |  |     |        |
    +  +--+  +--+--+--+  +  +  +  +
    |     |  |           |  |  |  |
    +--+--+--+--+--+--+--+--+--+--+

## Format of the raw data returned by generate_maze()

An array of unsigned char,
 raw = width | breath | r | r | r ...
 ar = raw + 2
 
Obviously the max size array that can be returned
this way is 255 * 255 rooms, but for a maze this should
be more than enough.

Given w : 0 to width-1, and b : 0-breadth-1

room(w,b) = ar[w * breadth + b]

### Room Layout in the unsigned char
Given that a shif operation is used to shift the
bit vectors into the unsigned chars, the ordering
is exactly reversed.

* 3 - left  x
* 2 - right x
* 1 - lower y
* 0 - upper y

where the digit is the bit offset in the uchar.
