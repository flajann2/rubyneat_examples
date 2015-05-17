require 'maze'

include NEAT::DSL
include Maze::DSL

=begin rdoc
=Bots in a Maze
=end


maze do 
  puts "Maze"
  
  dimensions width: 5, breadth: 3
  show
end
