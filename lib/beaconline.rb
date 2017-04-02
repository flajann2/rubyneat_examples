=begin rdoc
 Beaconline Model
=end

def beacon(*inp)
  
end

# Node Model
class Nodes
  def initialize
    @rows = NODE_ROWS
    @cols = NODE_COLUMS
    @nodes = @rows * @cols
    @room_width = ROOM_WIDTH
    @room_height = ROOM_HEIGHT
    @room_breadth = ROOM_BREADTH
  end

  def model
    @model ||= (1..@cols).map { |iy|
      (1..@rows).map { |ix|
        [[ix, iy], [(ix.to_f / (@rows+1)) * @room_width,
                    (iy.to_f / (@cols+1)) * @room_breadth,
                    @room_height]]
      }
    }.flatten(1).to_h.freeze
  end  
end

class Beacons
  
  def initialize
    @rand = Random.new
    @beacons = BEACONS
    @room_width = ROOM_WIDTH
    @room_height = ROOM_HEIGHT
    @room_breadth = ROOM_BREADTH
    @highest = HIGHEST_BEACON
    raise "beacons too high" if @highest > @room_height
  end

  def model
    @model ||= (0..@beacons).map { |b|
      [b, [@room_width * @rand.rand,
           @room_breadth * @rand.rand,
           @highest * @rand.rand]]
    }.to_h.freeze
  end
end

# Testing
if __FILE__ == $PROGRAM_NAME
  require 'pp'  
  NODE_ROWS = 3
  NODE_COLUMS = 3
  ROOM_WIDTH = 10.0
  ROOM_BREADTH = 10.0
  ROOM_HEIGHT = 3.0
  BEACONS = 20
  HIGHEST_BEACON = 1.6

  pp Nodes.new.model
  # Should be
  # {[1, 1]=>[2.5, 2.5, 3.0],
  #  [2, 1]=>[5.0, 2.5, 3.0],
  #  [3, 1]=>[7.5, 2.5, 3.0],
  #  [1, 2]=>[2.5, 5.0, 3.0],
  #  [2, 2]=>[5.0, 5.0, 3.0],
  #  [3, 2]=>[7.5, 5.0, 3.0],
  #  [1, 3]=>[2.5, 7.5, 3.0],
  #  [2, 3]=>[5.0, 7.5, 3.0],
  #  [3, 3]=>[7.5, 7.5, 3.0]}
  
  pp Beacons.new.model
end
