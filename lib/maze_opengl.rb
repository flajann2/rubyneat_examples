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
    IW_WIDTH = 640
    IW_HEIGHT = 480

    def initialize
      @textures = nil
      @xrot = 0.0
      @yrot = 0.0
      @x_speed = 0.0
      @y_speed = 0.0
      @z = -10.0
      @ambient = [0.5, 0.5, 0.5, 1.0]
      @diffuse = [1.0, 1.0, 1.0, 1.0]
      @light_position = [0.0, 0.0, 2.0, 1.0]
      @filter = 0
      @keys = []
      @lighting = false
      @fullscreen = false

      #HERE: texture symbols mapped to cardinals for textures.
      @tmap = {wall: 0, floor: 1, cap: 2, critter: 3} 

      glutInit
      
      glutInitDisplayMode GLUT_RGB | GLUT_DOUBLE | GLUT_ALPHA | GLUT_DEPTH
      glutInitWindowSize IW_WIDTH, IW_HEIGHT
      glutInitWindowPosition 0, 0
      
      @window = glutCreateWindow "RubyNEAT Maze Example"
      
      glutDisplayFunc :draw_gl_scene
      glutReshapeFunc :reshape
      glutIdleFunc :idle
      glutKeyboardFunc :keyboard
      
      reshape IW_WIDTH, IW_HEIGHT
      load_textures('stone_wall_seamless.png',
                    'rock_mixed.png',
                    'tilesf2.png',
                    'tilesf4.png',
                    'concrete_tile.png')
      init_gl
    end


    def init_gl
      glEnable GL_TEXTURE_2D
      glShadeModel GL_SMOOTH
      glClearColor 0.0, 0.0, 0.0, 0.5
      glClearDepth 1.0
      glEnable GL_DEPTH_TEST
      glDepthFunc GL_LEQUAL
      glHint GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST
      
      glLightfv GL_LIGHT1, GL_AMBIENT, @ambient
      glLightfv GL_LIGHT1, GL_DIFFUSE, @diffuse
      glLightfv GL_LIGHT1, GL_POSITION, @light_position
      
      glEnable GL_LIGHT1
      
      true
    end

    def show_loop
      glutMainLoop
    end


    def reshape width, height
      width   = width.to_f
      height = height.to_f
      height = 1.0 if height.zero?
      
      glViewport 0, 0, width, height
      
      glMatrixMode GL_PROJECTION
      glLoadIdentity
      
      gluPerspective 45.0, width / height, 0.1, 100.0
      
      glMatrixMode GL_MODELVIEW
      glLoadIdentity
      
      true
    end

    def draw_gl_scene
      quads = gen_maze_mit_texture!

      glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
      glLoadIdentity
      glTranslatef -width * room_measure / 2.0, -breadth * room_measure / 2.0, @z
      
      glRotatef @xrot, 1.0, 0.0, 0.0
      glRotatef @yrot, 0.0, 1.0, 0.0
      
      # Maze
      quads.keys.each do |texture|
        glBindTexture GL_TEXTURE_2D, @textures[tmap[texture]]
        glBegin GL_QUADS do
          quads[texture].each do |quad|
            glNormal3f(* quad[:normal])
            quad[:rect].each_with_index do |ver, i|
              glTexCoord2f(*ver[:tex_coord])
              glVertex3f(*ver[:vertex])
            end
          end
        end
      end

      # Bots
      glBindTexture GL_TEXTURE_2D, @textures[tmap[:critter]]
      glBegin GL_LINE_STRIP do
        critter_faces do |face|
          glNormal3f(* face[:normal])
          face[:poly].each_with_index do |ver, i|
            #glTexCoord2f(*ver[:tex_coord])
            glVertex3f(*ver[:vertex])
          end
        end
      end   

      # TODO: bots
      @xrot += @x_speed
      @yrot += @y_speed
      glutSwapBuffers
    end

    def idle
      glutPostRedisplay
    end

    def keyboard key, x, y
      case key
      when ?\e then
        glutDestroyWindow @window
        exit 0
      when 'l' then
        @lighting = !@lighting
        
        if @lighting then
          glEnable GL_LIGHTING
          puts "lights on"
        else
          glDisable GL_LIGHTING
          puts "lights off"
        end
      when 'F' then
        @filter += 1
        @filter %= @texture_count         
        puts "texture #{@filter}"
      when 'f' then
        @fullscreen = !@fullscreen
        
        if @fullscreen then
          glutFullScreen
        else
          glutPositionWindow 0, 0
        end
      when 'X' then @x_speed += 0.05
      when 'x' then @x_speed -= 0.05
      when 'Y' then @y_speed += 0.05
      when 'y' then @y_speed -= 0.05
      when 'Z' then @z       -= 1.0
      when 'z' then @z       += 1.0
      else
        puts key
      end

      glutPostRedisplay
    end

    
    def load_textures(*images)
      @textures = glGenTextures(@texture_count = images.size)
      images.each_with_index do |file, i|
        png = ChunkyPNG::Image.from_file(File.expand_path("../../public/#{file}", __FILE__))
        image = png.to_rgba_stream

        glBindTexture GL_TEXTURE_2D, @textures[i]
        glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
        glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST
        gluBuild2DMipmaps GL_TEXTURE_2D, GL_RGBA, png.width, png.height, GL_RGBA, GL_UNSIGNED_BYTE, image
      end
    end
  end
end
