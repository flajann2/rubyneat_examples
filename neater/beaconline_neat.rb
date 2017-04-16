require 'beaconline'
include Beaconline

include NEAT::DSL

#= Mockup for RSSI Beaconline Positioning
# All distances and coordinates are in meters.
# Vectors [x,y,z] maps to width(row,x), breadth(col,y),
# height(z), respectively.


NODE_ROWS = 3
NODE_COLUMS = 3

BEACONS = 20

ROOM_WIDTH = 10.0
ROOM_BREADTH = 10.0
ROOM_HEIGHT = 3.0

HIGHEST_BEACON = 1.6


$raum = Raum.new(rows: NODE_ROWS,
                 cols: NODE_COLS,
                 width: ROOM_WIDTH,
                 height: ROOM_HEIGHT,
                 breadth: ROOM_BREADTH,
                 beacons: BEACONS,
                 highest: HIGHEST_BEACON)

# This is the goal (fitness) parameter
MAX_ALLOWED_DISTANCE_ERROR  = 1.0

# This defines the controller
define "Beaconline" do
  # Define the IO neurons
  inputs {
    Hash[
      (1..NODE_COLUMNS).map{ |j|
        (1..NODE_ROWS).map{ |i|
          [("i%dr_%dc" % [i, j]).to_sym, InputNeuron]
        } + [[:bias, BiasNeuron]]
      }
    ]
  }
  outputs out_x: LinearNeuron, out_y: LinearNeuron, out_z: LinearNeuron

  # Hidden neuron specification is optional. 
  # The name given here is largely meaningless, but may be useful as some sort
  # of unique flag.
  hidden tan: TanhNeuron, gauss: GaussianNeuron 

  ### Settings
  ## General
  hash_on_fitness false
  start_population_size 30
  population_size 30
  max_generations 10000
  max_population_history 10

  ## Evolver probabilities and SDs
  # Perturbations
  mutate_perturb_gene_weights_prob 0.10
  mutate_perturb_gene_weights_sd 0.25

  # Complete Change of weight
  mutate_change_gene_weights_prob 0.10
  mutate_change_gene_weights_sd 1.00

  # Adding new neurons and genes
  mutate_add_neuron_prob 0.05
  mutate_add_gene_prob 0.20

  # Switching genes on and off
  mutate_gene_disable_prob 0.01
  mutate_gene_reenable_prob 0.01

  interspecies_mate_rate 0.03
  mate_only_prob 0.10 #0.7

  # Mating
  survival_threshold 0.20 # top % allowed to mate in a species.
  survival_mininum_per_species  4 # for small populations, we need SOMETHING to go on.

  # Fitness costs
  fitness_cost_per_neuron 0#.00001
  fitness_cost_per_gene   0#.00001

  # Speciation
  compatibility_threshold 2.5
  disjoint_coefficient 0.6
  excess_coefficient 0.6
  weight_coefficient 0.2
  max_species 20
  dropoff_age 15
  smallest_species 5

  # Sequencing
  start_sequence_at 0
  end_sequence_at BEACONS - 1
end

evolve do
  # This query shall return a vector result that will serve
  # as the inputs to the critter. 
  query { |seq|
    # We'll use the seq to create the xor sequences via
    # the least signficant bits.
    condition_rssi_vector (0 ... BEACON_INPUTS).map{|i| (seq & (1 << i)) != 0}
  }

  # Compare the fitness of two critters. We may choose a different ordering
  # here.
  compare {|f1, f2| f2 <=> f1 }

  # Here we integrate the cost with the fitness.
  cost { |fitvec, cost|
    fit = BEACON_STATES - fitvec.reduce {|a,r| a+r} - cost
    $log.debug ">>>>>>> fitvec #{fitvec} => #{fit}, cost #{cost}"
    fit
  }

  fitness { |vin, vout, seq|
    unless vout == :error
      bin = uncondition_boolean_vector vin
      bout = uncondition_boolean_vector vout
      bactual = [xor(*vin)]
      vactual = condition_boolean_vector bactual
      fit = (bout == bactual) ? 0.00 : 1.00
      #simple_fitness_error(vout, vactual.map{|f| f * 0.50 })
      bfit = (bout == bactual) ? 'T' : 'F'
      $log.debug "(%s) Fitness bin=%s, bout=%s, bactual=%s, vout=%s, fit=%6.3f, seq=%s" %
                     [bfit,
                      bin,
                      bout,
                      bactual,
                      vout,
                      fit,
                      seq]
      fit
    else
      $log.debug "Error on #{vin} [#{seq}]"
      1.0
    end
  }

  stop_on_fitness { |fitness, c|
    puts "*** Generation Run #{c.generation_num}, best is #{fitness[:best]} ***\n\n"
    fitness[:best] >= ALMOST_FIT
  }
end

report do |pop, rept|
  $log.info "REPORT #{rept.to_yaml}"
end

# The block here is called upon the completion of each generation
run_engine do |c|
  $log.info "******** Run of generation %s completed, history count %d ********" %
        [c.generation_num, c.population_history.size]
end
