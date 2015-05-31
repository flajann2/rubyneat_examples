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

require 'ffi'
require_relative 'maze_opengl'

module Maze
  MAZE_BASE = File.join(File.dirname(__FILE__), 'maze')
  MAZE_LIB = File.join(MAZE_BASE, "lib/libmaze.#{FFI::Platform::LIBSUFFIX}")

  # Ruby reprentation and interface to the C++ Maze module
  class Maze
    extend FFI::Library
    ffi_lib MAZE_LIB
    attach_function :generate_maze, [ :int, :int ], :pointer

    attr_accessor :width, :breadth, :room_measure, :wall_measure, :height
    attr :raw, :lmaze, :lwcaps, :lpcaps, :lewalls, :lfloor, :lall

    def gen_maze!
      @raw ||= generate_maze(@width, @breadth).get_array_of_uchar(2, @width * @breadth)
      @list_maze_quads ||= wall_it
    end
   
    # Create the line segments that define the maze
    def wall_it
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
      @rmaze = []
      @roompt = @room_measure / 2.0
      @wallpt = @wall_measure / 2.0
      (0...@width).each do |i|
        b_rooms = []
        x = i * @room_measure
        (0...@breadth).each do |j|
          room = bmaze[i][j]
          y = j * @room_measure
          b_rooms << {
            top: room[:top]     ? [[(x + @roompt) - @roompt + @wallpt, (y + @roompt) + @roompt - @wallpt],
                                   [(x + @roompt) + @roompt - @wallpt, (y + @roompt) + @roompt - @wallpt]] : nil,
            bot: room[:bot]     ? [[(x + @roompt) - @roompt + @wallpt, (y + @roompt) - @roompt + @wallpt],
                                   [(x + @roompt) + @roompt - @wallpt, (y + @roompt) - @roompt + @wallpt]] : nil,
            right: room[:right] ? [[(x + @roompt) + @roompt - @wallpt, (y + @roompt) - @roompt + @wallpt],
                                   [(x + @roompt) + @roompt - @wallpt, (y + @roompt) + @roompt - @wallpt]] : nil,
            left:  room[:left]  ? [[(x + @roompt) - @roompt + @wallpt, (y + @roompt) - @roompt + @wallpt],
                                   [(x + @roompt) - @roompt + @wallpt, (y + @roompt) + @roompt - @wallpt]] : nil,
          }
        end
        @rmaze << b_rooms
      end
      @lmaze   = list_wall_it @rmaze
      @lwcaps  = list_wall_cap_it @rmaze
      @lpcaps  = list_pin_cap_it @rmaze
      @lewalls = list_edge_wall_it @rmaze
      @lfloor  = list_maze_floor @rmaze
      @lall = @lmaze + @lwcaps + @lpcaps + @lewalls + @lfloor 
    end

    # Create the walls
    def list_wall_it(rmaze)
      rooms = rmaze.flatten
      li = []
        rooms.each do |room|
          room.each do |wall, segment|
            unless segment.nil?
              quad = {}
              z1 = 0.0
              z2 = height
              ((x1, y1), (x2, y2)) = segment
              # Face normal
              case wall
              when :top   ; quad[:normal] = [ 0.0, -1.0, 0.0] ; (ix, iy) = [ 0.0,  1.0]
              when :bot   ; quad[:normal] = [ 0.0,  1.0, 0.0] ; (ix, iy) = [ 0.0, -1.0] 
              when :right ; quad[:normal] = [-1.0,  0.0, 0.0] ; (ix, iy) = [ 1.0,  0.0]
              when :left  ; quad[:normal] = [ 1.0,  0.0, 0.0] ; (ix, iy) = [-1.0,  0.0] 
              end

              # wall
              quad[:rect] = [
                             {texture: [0.0, 1.0], vertex: [x1, y1, z1]},
                             {texture: [1.0, 1.0], vertex: [x1, y1, z2]},
                             {texture: [1.0, 0.0], vertex: [x2, y2, z2]},
                             {texture: [0.0, 0.0], vertex: [x2, y2, z1]}
                            ]
              li << quad
            end
          end
        end

      li
    end

    def cap_rot(side)
      case side
      when :top   ; [0.0, 1.0] 
      when :bot   ; [0.0, -1.0] 
      when :right ; [1.0, 0.0] 
      when :left  ; [-1.0, 0.0] 
      end
    end

    def cap_skip?(i, j, side, segment)
      segment.nil? ||
        (side == :bot  && j != 0) ||
        (side == :left && i != 0) 
    end

    # Create caps between walls
    def list_wall_cap_it(rmaze)
      li = []
      z = height
      rmaze.each_with_index do |rbreadth, i|
        rbreadth.each_with_index do |room, j|
          room.each{ |side, segment|
            unless cap_skip? i, j, side, segment 
              quad = {normal: [0.0, 0.0, 1.0], side: side} #caps face up as all
              ((x1, y1), (x2, y2)) = segment
              ix, iy = cap_rot(side)
              quad[:side] = side # for debugging only
              quad[:rect] = [
                             {texture: [0.0, 1.0], vertex: [x1, y1, z]},
                             {texture: [1.0, 1.0], vertex: [x1 + (@wall_measure*ix), y1 + (@wall_measure*iy), z]},
                             {texture: [1.0, 0.0], vertex: [x2 + (@wall_measure*ix), y2 + (@wall_measure*iy), z]},
                             {texture: [0.0, 0.0], vertex: [x2, y2, z]}
                            ]
              li << quad
            end
          }
        end
      end
      li
    end

    # given the x,y coordinate of the left and bottom of the
    # cap, respectively, generate the vertices and texture map
    # of the cap. Generate 5 faces and return the array of the
    # vertices.
    def pin_cap(x, y, side = nil)
      faces = []
      z = height
      xw = x + @wall_measure
      yw = y + @wall_measure
      zw = 0.0

      # cap of the cap -- maze square
      quad = {normal: [0.0, 0.0, 1.0], side: side}
      quad[:rect] = [
                     {texture: [0.0, 1.0], vertex: [x,  y,  z]},
                     {texture: [1.0, 1.0], vertex: [x,  yw, z]},
                     {texture: [1.0, 0.0], vertex: [xw, yw, z]},
                     {texture: [0.0, 0.0], vertex: [xw, y,  z]}
                    ]
      faces << quad

      # top(2d ref) wall
      quad = {normal: [1.0, 0.0, 0.0], side: side}
      quad[:rect] = [
                     {texture: [0.0, 1.0], vertex: [x,  yw, z]},
                     {texture: [1.0, 1.0], vertex: [x,  yw, zw]},
                     {texture: [1.0, 0.0], vertex: [xw, yw, zw]},
                     {texture: [0.0, 0.0], vertex: [xw, yw, z]}
                    ]
      faces << quad

      # bot(2d ref) wall
      quad = {normal: [-1.0, 0.0, 0.0], side: side}
      quad[:rect] = [
                     {texture: [0.0, 1.0], vertex: [x,  y, z]},
                     {texture: [1.0, 1.0], vertex: [x,  y, zw]},
                     {texture: [1.0, 0.0], vertex: [xw, y, zw]},
                     {texture: [0.0, 0.0], vertex: [xw, y, z]}
                    ]
      faces << quad

      # right(2d ref) wall
      quad = {normal: [0.0, 1.0, 0.0], side: side}
      quad[:rect] = [
                     {texture: [0.0, 1.0], vertex: [xw, y,  z]},
                     {texture: [1.0, 1.0], vertex: [xw, y,  zw]},
                     {texture: [1.0, 0.0], vertex: [xw, yw, zw]},
                     {texture: [0.0, 0.0], vertex: [xw, yw, z]}
                    ]
      faces << quad

      # left(2d ref) wall
      quad = {normal: [0.0, -1.0, 0.0], side: side}
      quad[:rect] = [
                     {texture: [0.0, 1.0], vertex: [x, y,  z]},
                     {texture: [1.0, 1.0], vertex: [x, y,  zw]},
                     {texture: [1.0, 0.0], vertex: [x, yw, zw]},
                     {texture: [0.0, 0.0], vertex: [x, yw, z]}
                    ]
      faces << quad

      faces
    end

    def pin_skip?(i, j, side, segment)
      segment.nil? ||
        (side == :bot  && j != 0) ||
        (side == :left && i != 0) 
    end

    # Create pin caps between wall junctions
    # Here we will take the room coordinate as addressing
    # the pin to and right of the room, and negative coordinates
    # for the lower and left edges.
    def list_pin_cap_it(rmaze)
      li = []
      rmaze.each_with_index do |rbreadth, i|
        rbreadth.each_with_index do |room, j|
          room.each{ |side, segment|
            unless pin_skip? i, j, side, segment
              ((x1, y1), (x2, y2)) = segment
              li += pin_cap(x2, y2, side)
            end
          }
        end
      end
      li
    end

    # Create the edge walls
    def list_edge_wall_it(rmaze)
      []
    end

    # Create the maze floor
    def list_maze_floor(rmaze)
      []
    end

    def to_s(delim="\n")
      s = []
      gen_maze!
      (0...width).each do |i|
        (0...breadth).each do |j|
          s << "(#{i},#{j}): #{@rmaze[i][j]}"
        end
      end
      s.join(delim)
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
    def physical(room: 1.0, wall: 0.1, height: 1.0 &block)
      @maze.room_measure,
      @maze.wall_measure,
      @maze.height = if block_given?
                       block.()
                     else
                       [room, wall, height]
                     end
    end


    def maze(&block)
      @maze = Maze.new
            
      def show(mazeob: @maze, debug: false, gl: true, &block)
        mazeob.gen_maze!
        if debug
          puts mazeob.to_s 
          puts "lmaze:::";   pp @maze.lmaze
          puts "lwcaps:::";  pp @maze.lwcaps
          puts "lpcaps:::";  pp @maze.lpcaps
          puts "lewalls:::"; pp @maze.lewalls
          puts "lfloor:::";  pp @maze.lfloor
        end

        mazeob.show_loop if gl
      end

      block.(@maze)
    end
  end
end
