=begin rdoc
  Beaconline Model
  http://s2is.org/Issues/v1/n2/papers/paper14.pdf
=end

module Beaconline
  A = -53.0 # calibrated dBm
  N = (80.0 - A) / (10.0 * 1.4) # n - calibration (estimated) -(RSSI - A) / (10 log10 d)
  FADEOUT = -90.0
  MAX_CLOSENESS = -30.0
  
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
    attr_reader :beacons,
                :room_width,
                :room_height,
                :room_breadth,
                :heighest
    
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
  
      @width   = width
      @breadth = breadth
      @height  = height
      
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
    
    def distance_matrix
      @distance_matrix ||= compute_dm
    end
  
    private
    
    def compute_dm
      beacons.model.map{ |beacon_key, bpos|
        nodes.model.map{ |node_key, npos|
          [[beacon_key, node_key], rssi(distance(npos, bpos)), distance(npos, bpos)]
        }
      }
    end
  
    def distance(u, v)
      Math.sqrt u.zip(v).map{ |a, b| (b-a)**2.0 }.reduce(:+)
    end
  
    def rssi(dist)
      r = -(10.9 * N * Math.log10(dist) + A)
      if r < FADEOUT
        0
      elsif r > MAX_CLOSENESS
        MAX_CLOSENESS
      else
        r
      end
    end
  end

  # for now, this is just a passthru
  def condition_rssi_vector vec
    vec
  end

  # for now, this is just a passthru
  def uncondition_output_vector vec
    vec
  end
end


# Testing
if __FILE__ == $PROGRAM_NAME
  require 'pp'  

  raum = Beaconline::Raum.new(rows: 3,
                              cols: 3,
                              width: 30.0,
                              height: 3.0,
                              breadth: 30.0,
                              beacons: 20,
                              highest: 1.6)

  puts 'NODES'
  pp raum.nodes.model  
  puts 'BEACONS'
  pp raum.beacons.model
  puts 'DISTANCE_MATRIX'
  pp raum.distance_matrix
end
