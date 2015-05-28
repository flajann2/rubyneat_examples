require 'maze'

include NEAT::DSL
include Maze::DSL

=begin rdoc
=Bots in a Maze
=end

maze do 
  puts "Maze"
  
  dimensions width: 5, breadth: 3
  physical room: 1.0, wall: 0.05
  show
end
