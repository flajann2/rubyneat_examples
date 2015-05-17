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

module Maze

  # Ruby reprentation and interface to the C++ Maze module
  class Maze
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
      @ipwin = InvPendWindow.new
      
      def cart(&block)
        @cart_params = block.()
        unless @cart_params[:naked]
          @cart = @ipwin.cart = Cart.new({ipwin: @ipwin}.merge @cart_params)
        else
          @cart = Cart.new(@cart_params)
        end
      end
      
      def show(cart: @cart, &block)
        unless cart.nil?
          @ipwin.cart = cart
          cart.ipwin = @ipwin
        end
        
        @ipwin.show
      end
      block.(@ipwin)
    end
  end
end



