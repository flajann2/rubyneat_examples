require 'maze'

include NEAT::DSL
include Maze::DSL

=begin rdoc
=Bots in a Maze
=end

maze do 
  dimensions width: 3, breadth: 4
  physical room: 1.0, wall: 0.3, height: 0.5
  show debug: true, gl: true
end
