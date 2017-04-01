# Library to support Neaters

## Xor
Basic test for neural nets, can also do parity (xor with greater
than 2 inputs).

## Inverted Pendulum
Demo of an inverted pendulum.
We need to fix the math or employ a physics engine.

We use Gosu for visualization currently. We should
probably convert it to OpenGL later.

## Maze
Maze Generator and evaluator written in C++, called
from the Maze neater. Evolves bots to be able to find
their way from one part of the maze to another part,
the start and end goals are ramdomly selected on a
per maze basis.

Here for visualization we use OpenGL

Calls the C++ maze shared library and is returned
an array of bit-encoded walls, which is then converted
into line segments and then into the OpenGL structures.

### Room Layout in the rooms in the integers

The maze is dumped for testing by the the
C++ library in ASCII on the console. The following
orientation refers to "up", "down", "left", "right",
etc in reference to that dump. Coordinates begin
at the bottom left as (0,0) and increases as you move
"up" and "right".

* 0 - (top)   upper y (or "vertical")
* 1 - (bot)   lower y (or "vertical")
* 2 - (right) right x (or "horizontal")
* 3 - (left)  left  x (or "horizontal")

where the digit is the bit offset in the integer.

Note that most rooms are specified twice. This is
intentional, as later we may use this to specify
one-way passages. For now, the walls (or their
absence) matches in the way you would expect with
adjacent rooms.

Two dimensional array that represent the maze is
group in terms of a width (x) array of breadth (y). 
