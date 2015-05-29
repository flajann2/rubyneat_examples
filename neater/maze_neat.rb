require 'maze'

include NEAT::DSL
include Maze::DSL

=begin rdoc
=Bots in a Maze
=end

maze do 
  puts "Maze"
  
  dimensions width: 8, breadth: 6
  physical room: 1.0, wall: 0.05, height: 0.5
  show
end
