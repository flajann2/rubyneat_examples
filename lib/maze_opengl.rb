require 'opengl'
require 'glu'
require 'glut'
require 'chunky_png'

=begin rdoc
The OpenGL logic, etc. for maze
=end
module Maze
  class Maze
    include Gl
    include Glu
    include Glut

    def draw_gl_scene
      rooms = gen_maze!.flatten

      glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
      glLoadIdentity
      glTranslatef 0.0, 0.0, @z
      
      glRotatef @xrot, 1.0, 0.0, 0.0
      glRotatef @yrot, 0.0, 1.0, 0.0
      
      glBindTexture GL_TEXTURE_2D, @textures[@filter]
      
      glBegin GL_QUADS do
        rooms.each do |room|
          room.each do |wall, segment|
            unless segment.nil?
              z1 = 0.0
              z2 = height
              # Face normal
              case wall
              when :top
                glNormal3f(0.0,  1.0,  0.0)
                ((x1, y1), (x2, y2)) = segment
              when :bot 
                glNormal3f(0.0,  -1.0,  0.0)
                ((x1, y1), (x2, y2)) = segment
              when :right 
                glNormal3f(1.0,  0.0,  0.0)
                ((y1, x1), (y2, x2)) = segment
              when :left 
                glNormal3f(-1.0,  0.0,  0.0)
                ((y1, x1), (y2, x2)) = segment
              end
              glTexCoord2f(0.0, 1.0) ; glVertex3f(x1, y1, z1)
              glTexCoord2f(1.0, 1.0) ; glVertex3f(x1, y1, z2)
              glTexCoord2f(1.0, 0.0) ; glVertex3f(x2, y1, z2)
              glTexCoord2f(0.0, 0.0) ; glVertex3f(x2, y1, z1)
            end
          end
        end
      end
    end
  end
end

