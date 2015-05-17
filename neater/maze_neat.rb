require 'maze'

include NEAT::DSL
include Maze::DSL

=begin rdoc
=Bots in a Maze
=end


maze do 
  puts "Maze"
  
  dimensions width: 40, breadth: 10
  show
end
