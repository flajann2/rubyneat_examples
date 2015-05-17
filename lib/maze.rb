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

module Maze
  MAZE_BASE = File.join(File.dirname(__FILE__), 'maze')
  MAZE_LIB = File.join(MAZE_BASE, "lib/libmaze.#{FFI::Platform::LIBSUFFIX}")

  # Ruby reprentation and interface to the C++ Maze module
  class Maze
    extend FFI::Library
    ffi_lib MAZE_LIB
    attach_function :generate_maze, [ :int, :int ], :pointer
  end

  module DSL

    # dimensions of the maze (width x breadth)
    def dimensions(width: 7, breadth: 7, &block)
      @width, @breadth = if block_given?
                           block.()
                         else
                           [width, breadth]
                         end
    end


    def maze(&block)
      @maze = Maze.new
            
      def show(mazeob: @maze, &block)
        r = mazeob.generate_maze(@width, @breadth).get_array_of_uchar(2, @width * @breadth)
        pp r.map{|i| i.to_s(2)}
      end

      block.(@maze)
    end
  end
end



