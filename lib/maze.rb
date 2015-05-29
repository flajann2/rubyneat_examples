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

    attr_accessor :width, :breadth, :room_measure, :wall_measure
    attr :raw

    def gen_maze!
      @raw = generate_maze(@width, @breadth).get_array_of_uchar(2, @width * @breadth)
    end
   
    # Create the line segments that define the maze
    def wall_it!
      bmaze = []
      @raw.each_slice(@breadth) do |a|
        bmaze << a
        def a.[](i)
          room = super
          {
            top:   room & (1 << 0) != 0,
            bot:   room & (1 << 1) != 0,
            right: room & (1 << 2) != 0,
            left:  room & (1 << 3) != 0,
          }
        end
      end

      # Here we calculate the actual line segments
      # for all the rooms
      rmaze = []
      roompt = @room_measure / 2.0
      wallpt = @wall_measure / 2.0
      (0...@width).each do |i|
        b_rooms = []
        x = i * @room_measure
        (0...@breadth).each do |j|
          room = bmaze[i][j]
          y = j * @room_measure
          b_rooms << {
            top: room[:top] ? [[(x + roompt) - roompt + wallpt, (y + roompt) + roompt - wallpt], 
                               [(x + roompt) + roompt - wallpt, (y + roompt) + roompt - wallpt]] : nil,
            bot: room[:bot] ? [[(x + roompt) - roompt + wallpt, (y + roompt) - roompt + wallpt],
                               [(x + roompt) + roompt - wallpt, (y + roompt) - roompt + wallpt]] : nil,

            right: room[:right] ? [[(x + roompt) + roompt - wallpt, (y + roompt) - roompt + wallpt], 
                                   [(x + roompt) + roompt - wallpt, (y + roompt) + roompt - wallpt]] : nil,
            left:  room[:left]  ? [[(x + roompt) - roompt + wallpt, (y + roompt) - roompt + wallpt],
                                   [(x + roompt) - roompt + wallpt, (y + roompt) + roompt - wallpt]] : nil,
          }
        end
        rmaze << b_rooms
      end
      rmaze
    end
  end

  module DSL
    # dimensions of the maze (width x breadth)
    def dimensions(width: 5, breadth: 3, &block)
      @maze.width, @maze.breadth = if block_given?
                           block.()
                         else
                           [width, breadth]
                         end
    end

    # Assume MKS units, define the witdth of the 
    # square room and the width of the wall.
    def physical(room: 1.0, wall: 0.1, &block)
      @maze.room_measure, @maze.wall_measure = if block_given?
                                                 block.()
                                               else
                                                 [room, wall]
                                               end
    end


    def maze(&block)
      @maze = Maze.new
            
      def show(mazeob: @maze, &block)
        r = mazeob.gen_maze!
        mwalls = mazeob.wall_it!
        (0...@maze.width).each do |i|
          (0...@maze.breadth).each do |j|
            puts "(#{i},#{j}) = #{mwalls[i][j]}"
          end
        end
      end

      block.(@maze)
    end
  end
end



