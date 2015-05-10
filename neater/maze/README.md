# MAZE C++ Module example

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
      x lower wall  | 0               1 | x upper wall
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
