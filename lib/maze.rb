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
require 'ply'
require_relative 'maze_opengl'

module Maze
  MAZE_BASE = File.join(File.dirname(__FILE__), 'maze')
  MAZE_LIB = File.join(MAZE_BASE, "lib/libmaze.#{FFI::Platform::LIBSUFFIX}")

  # Ply API
  CRITTER_FILE = File.join(MAZE_BASE, "../../public/models/critter2.ply")
  VRTX = 'vertex'
  FACE = 'face'
  VRTXI = 'vertex_indices'

  # Ruby reprentation and interface to the C++ Maze module
  class Maze
    extend FFI::Library
    ffi_lib MAZE_LIB
    attach_function :generate_maze, [ :int, :int ], :pointer

    attr_accessor :width, :breadth, :room_measure, :wall_measure, :height
    attr_reader :raw, :lmaze, :lwcaps, :lpcaps, :lewalls, :lfloor, :lall
    attr_reader :roompt, :wallpt, :textl
    attr_reader :tmap # texture map

    def gen_maze!
      @raw ||= generate_maze(@width, @breadth).get_array_of_uchar(2, @width * @breadth)
      @list_maze_quads ||= wall_it
    end

    def gen_maze_mit_texture!
      gen_maze!
      @textl
    end

    def ij2xy(i, j, xoff: 0.0, yoff: 0.0)
      [i * @room_measure + xoff, j * @room_measure + yoff]
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
        (0...@breadth).each do |j|
          room = bmaze[i][j]
          x, y = ij2xy(i, j, xoff: @roompt, yoff: @roompt)
          b_rooms << {
            top: room[:top]     ? [[x - @roompt + @wallpt, y + @roompt - @wallpt],
                                   [x + @roompt - @wallpt, y + @roompt - @wallpt]] : nil,
            bot: room[:bot]     ? [[x - @roompt + @wallpt, y - @roompt + @wallpt],
                                   [x + @roompt - @wallpt, y - @roompt + @wallpt]] : nil,
            right: room[:right] ? [[x + @roompt - @wallpt, y - @roompt + @wallpt],
                                   [x + @roompt - @wallpt, y + @roompt - @wallpt]] : nil,
            left:  room[:left]  ? [[x - @roompt + @wallpt, y - @roompt + @wallpt],
                                   [x - @roompt + @wallpt, y + @roompt - @wallpt]] : nil,
          }
        end
        @rmaze << b_rooms
      end
      @lmaze   = list_wall_it @rmaze
      @lwcaps  = list_wall_cap_it @rmaze
      @lpcaps  = list_pin_cap_it @rmaze
      @lewalls = list_edge_wall_it @rmaze
      @lfloor  = list_maze_floor @rmaze
      @lall = (@lmaze + @lwcaps + @lpcaps + @lewalls + @lfloor).flatten
      
      # sort according to texture
      @textl = Hash[@tmap.keys.map{|tex| [tex, []]}]
      @lall.each do |quad|
        @textl[quad[:texture]] << quad
      end
      @lall
    end

    # Create the walls
    def list_wall_it(rmaze)
      rooms = rmaze.flatten
      li = []
        rooms.each do |room|
          room.each do |wall, segment|
            unless segment.nil?
              quad = {texture: :wall}
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
                             {tex_coord: [0.0, 1.0], vertex: [x1, y1, z1]},
                             {tex_coord: [1.0, 1.0], vertex: [x1, y1, z2]},
                             {tex_coord: [1.0, 0.0], vertex: [x2, y2, z2]},
                             {tex_coord: [0.0, 0.0], vertex: [x2, y2, z1]}
                            ]
              li << quad
            end
          end
        end

      li
    end

    def wall_cap_rot(side)
      case side
      when :top   ; [0.0, 1.0] 
      when :bot   ; [0.0, -1.0] 
      when :right ; [1.0, 0.0] 
      when :left  ; [-1.0, 0.0] 
      end
    end

    def wall_cap_skip?(i, j, side, segment)
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
            unless wall_cap_skip? i, j, side, segment 
              quad = {normal: [0.0, 0.0, 1.0], side: side, texture: :cap} #caps face up as all
              ((x1, y1), (x2, y2)) = segment
              ix, iy = wall_cap_rot(side)
              quad[:side] = side # for debugging only
              quad[:rect] = [
                             {tex_coord: [0.0, 1.0], vertex: [x1, y1, z]},
                             {tex_coord: [1.0, 1.0], vertex: [x1 + (@wall_measure*ix), y1 + (@wall_measure*iy), z]},
                             {tex_coord: [1.0, 0.0], vertex: [x2 + (@wall_measure*ix), y2 + (@wall_measure*iy), z]},
                             {tex_coord: [0.0, 0.0], vertex: [x2, y2, z]}
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
      quad = {normal: [0.0, 0.0, 1.0], side: side, texture: :cap}
      quad[:rect] = [
                     {tex_coord: [0.0, 1.0], vertex: [x,  y,  z]},
                     {tex_coord: [1.0, 1.0], vertex: [x,  yw, z]},
                     {tex_coord: [1.0, 0.0], vertex: [xw, yw, z]},
                     {tex_coord: [0.0, 0.0], vertex: [xw, y,  z]}
                    ]
      faces << quad

      # top(2d ref) wall
      quad = {normal: [1.0, 0.0, 0.0], side: side, texture: :wall}
      quad[:rect] = [
                     {tex_coord: [0.0, 1.0], vertex: [x,  yw, z]},
                     {tex_coord: [1.0, 1.0], vertex: [x,  yw, zw]},
                     {tex_coord: [1.0, 0.0], vertex: [xw, yw, zw]},
                     {tex_coord: [0.0, 0.0], vertex: [xw, yw, z]}
                    ]
      faces << quad

      # bot(2d ref) wall
      quad = {normal: [-1.0, 0.0, 0.0], side: side, texture: :wall}
      quad[:rect] = [
                     {tex_coord: [0.0, 1.0], vertex: [x,  y, z]},
                     {tex_coord: [1.0, 1.0], vertex: [x,  y, zw]},
                     {tex_coord: [1.0, 0.0], vertex: [xw, y, zw]},
                     {tex_coord: [0.0, 0.0], vertex: [xw, y, z]}
                    ]
      faces << quad

      # right(2d ref) wall
      quad = {normal: [0.0, 1.0, 0.0], side: side, texture: :wall}
      quad[:rect] = [
                     {tex_coord: [0.0, 1.0], vertex: [xw, y,  z]},
                     {tex_coord: [1.0, 1.0], vertex: [xw, y,  zw]},
                     {tex_coord: [1.0, 0.0], vertex: [xw, yw, zw]},
                     {tex_coord: [0.0, 0.0], vertex: [xw, yw, z]}
                    ]
      faces << quad

      # left(2d ref) wall
      quad = {normal: [0.0, -1.0, 0.0], side: side, texture: :wall}
      quad[:rect] = [
                     {tex_coord: [0.0, 1.0], vertex: [x, y,  z]},
                     {tex_coord: [1.0, 1.0], vertex: [x, y,  zw]},
                     {tex_coord: [1.0, 0.0], vertex: [x, yw, zw]},
                     {tex_coord: [0.0, 0.0], vertex: [x, yw, z]}
                    ]
      faces << quad

      faces
    end

    # Create pin caps between wall junctions
    # Here we will take the room coordinate as addressing
    # the pin to and right of the room, and negative coordinates
    # for the lower and left edges.
    def list_pin_cap_it(rmaze)
      li = []
      (-1...width).each do |i|
        (-1...breadth).each do |j|
          x,y = ij2xy(i, j, xoff: room_measure - wallpt, yoff: room_measure - wallpt)
          li += pin_cap(x, y, [i, j, x, y])
        end
      end
      li
    end

    # Create the edge walls.
    def list_edge_wall_it(rmaze)
      z0 = 0.0
      z1 = height

      (0...width).map{ |i|
        x1, ya = ij2xy(i,   0,       xoff: wallpt,  yoff: -wallpt)
        x2, yb = ij2xy(i+1, breadth, xoff: -wallpt, yoff: wallpt)
        [
         {
           normal: [0.0, -1.0, 0.0],
           side: :edge_x_lower_wall,
           texture: :wall,
           rect: [
                  {tex_coord: [0.0, 1.0], vertex: [x1, ya, z0]},
                  {tex_coord: [1.0, 1.0], vertex: [x2, ya, z0]},
                  {tex_coord: [1.0, 0.0], vertex: [x2, ya, z1]},
                  {tex_coord: [0.0, 0.0], vertex: [x1, ya, z1]},
                 ]
         },
         {
           normal: [0.0, 1.0, 0.0],
           side: :edge_x_upper_wall,
           texture: :wall,
           rect: [
                  {tex_coord: [0.0, 1.0], vertex: [x1, yb, z0]},
                  {tex_coord: [1.0, 1.0], vertex: [x2, yb, z0]},
                  {tex_coord: [1.0, 0.0], vertex: [x2, yb, z1]},
                  {tex_coord: [0.0, 0.0], vertex: [x1, yb, z1]},
                 ]
         }
        ]
      }.flatten + (0...breadth).map{ |j|
        xa, y1 = ij2xy(0,     j,   xoff: -wallpt, yoff: wallpt)
        xb, y2 = ij2xy(width, j+1, xoff: wallpt,  yoff: -wallpt)
        [
         {
           normal: [-1.0, 0.0, 0.0],
           side: :edge_y_right_wall,
           texture: :wall,
           rect: [
                  {tex_coord: [0.0, 1.0], vertex: [xa, y1, z0]},
                  {tex_coord: [1.0, 1.0], vertex: [xa, y2, z0]},
                  {tex_coord: [1.0, 0.0], vertex: [xa, y2, z1]},
                  {tex_coord: [0.0, 0.0], vertex: [xa, y1, z1]},
                 ]
         },
         {
           normal: [1.0, 0.0, 0.0],
           side: :edge_y_left_wall,
           texture: :wall,
           rect: [
                  {tex_coord: [0.0, 1.0], vertex: [xb, y1, z0]},
                  {tex_coord: [1.0, 1.0], vertex: [xb, y2, z0]},
                  {tex_coord: [1.0, 0.0], vertex: [xb, y2, z1]},
                  {tex_coord: [0.0, 0.0], vertex: [xb, y1, z1]},
                 ]
         }
        ]
      }.flatten
    end

    # Create the maze floor
    def list_maze_floor(rmaze)
      c0 = [-wallpt, -wallpt, 0.0]
      c1 = [-wallpt, room_measure * breadth + wallpt, 0.0]
      c2 = [room_measure * width + wallpt, room_measure * breadth + wallpt, 0.0]
      c3 = [room_measure * width + wallpt, -wallpt, 0.0]
      [{
         normal: [0.0, 0.0, 1.0],
         side: :floor,
         texture: :floor,
         rect: [
                {tex_coord: [0.0, 1.0], vertex: c0},
                {tex_coord: [1.0, 1.0], vertex: c1},
                {tex_coord: [1.0, 0.0], vertex: c2},
                {tex_coord: [0.0, 0.0], vertex: c3}
               ]
       }]
    end

    # Critter comprises polygons (triangles and rectangles)
    def ply_critter
      @ply ||= Ply::PlyFile.new(CRITTER_FILE)                            
    end

    def critter_faces
      ply_critter.data[FACE].each do |vi|
        face = {shape: :critter, texture: :critter}
        vrtx = vi[VRTXI].map{ |i| ply_critter.data[VRTX][i] }
        face[:normal] = %w{nx ny nz}.map{|k| vrtx.first[k]}
        face[:poly] = vrtx.map{ |v| {vertex: %w{x y z}.map{ |a| v[a]} } }
        yield face
      end
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
