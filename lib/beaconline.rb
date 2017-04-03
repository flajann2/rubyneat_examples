=begin rdoc
 Beaconline Model
=end

def beacon(*inp)
  
end

# Node Model
class Nodes
  def initialize(rows: nil,
                 cols: nil,
                 width: nil,
                 height: nil,
                 breadth: nil)
    @rows = rows
    @cols = cols
    @nodes = @rows * @cols
    @room_width = width
    @room_height = height
    @room_breadth = breadth
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
  def initialize(rand: Random.new,
                 beacons: 20,
                 width: nil,
                 height: nil,
                 breadth: nil,
                 highest: nil
                )
    @rand = rand
    @beacons = beacons
    @room_width = width
    @room_height = height
    @room_breadth = breadth
    @highest = highest
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

class Raum
  attr_accessor :nodes, :beacons
  def initialize(rows: 3,
                 cols: 3,
                 width: 10.0,
                 height: 3.0,
                 breadth: 10.0,
                 rand: Random.new,
                 beacons: 20,
                 highest: 1.6)

    @nodes = Nodes.new(rows: rows,
                       cols: cols,
                       width: width,
                       height: height,
                       breadth: breadth)

    @beacons = Beacons.new(rand: rand,
                           beacons: beacons,
                           width: width,
                           height: height,
                           breadth: breadth,
                           highest: height)
  end
end


# Testing
if __FILE__ == $PROGRAM_NAME
  require 'pp'  

  raum = Raum.new(rows: 3,
                  cols: 3,
                  width: 10.0,
                  height: 3.0,
                  breadth: 10.0,
                  rand: Random.new,
                  beacons: 20,
                  highest: 1.6)

  pp raum.nodes.model
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
  
  pp raum.beacons.model
end
