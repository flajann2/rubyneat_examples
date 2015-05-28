# -*- coding: utf-8 -*-
=begin rdoc
= Maze

Evolution of a bot to navigate the maze and avoid hitting the walls.

The start- and endpoints in the maze is chosen at random, as well as
the maze itself randomly generated.

We employ OpenGL to render the maze and the critter(s) so that
one can actually visualize the results.

During the evaluation mode, the actual simulations, as well as the
maze generations, are all done in a C++14 library for speed.
=end

require 'opengl'
require 'glu'
require 'glut'
require 'ffi'
require 'chunky_png'

module Maze
  MAZE_BASE = File.join(File.dirname(__FILE__), 'maze')
  MAZE_LIB = File.join(MAZE_BASE, "lib/libmaze.#{FFI::Platform::LIBSUFFIX}")

  # Ruby reprentation and interface to the C++ Maze module
  class Maze
    include Gl
    include Glu
    include Glut
    extend FFI::Library
    ffi_lib MAZE_LIB
    attach_function :generate_maze, [ :int, :int ], :pointer

    def gen_maze!(width, breadth)
      @width = width
      @breadth = breadth
      @raw = generate_maze(@width, @breadth).get_array_of_uchar(2, @width * @breadth)
    end

    def raw
      @raw
    end
   
    # Create the line segments that define the maze
    def wall_it!
    end
  end

  module DSL
    # dimensions of the maze (width x breadth)
    def dimensions(width: 5, breadth: 3, &block)
      @width, @breadth = if block_given?
                           block.()
                         else
                           [width, breadth]
                         end
    end

    # Assume MKS units, define the witdth of the 
    # square room and the width of the wall.
    def physical(room: 1.0, wall: 0.1, &block)
      @room_measure, @wall_measure = if block_given?
                                       block.()
                                     else
                                       [room, wall]
                                     end
    end


    def maze(&block)
      @maze = Maze.new
            
      def show(mazeob: @maze, &block)
        r = mazeob.gen_maze!(@width, @breadth)
        pp r.map{|i| i.to_s(2)}
      end

      block.(@maze)
    end
  end
end



