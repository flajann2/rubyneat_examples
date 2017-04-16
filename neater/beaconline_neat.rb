# coding: utf-8
require 'beaconline'
include Beaconline

include NEAT::DSL

#= Mockup for RSSI Beaconline Positioning
# All distances and coordinates are in meters.
# Vectors [x,y,z] maps to width(row,x), breadth(col,y),
# height(z), respectively.


NODE_ROWS = 3
NODE_COLUMNS = 3

BEACONS = 20

ROOM_WIDTH = 10.0
ROOM_BREADTH = 10.0
ROOM_HEIGHT = 3.0

HIGHEST_BEACON = 1.6


$raum = Raum.new(rows: NODE_ROWS,
                 cols: NODE_COLUMNS,
                 width: ROOM_WIDTH,
                 height: ROOM_HEIGHT,
                 breadth: ROOM_BREADTH,
                 beacons: BEACONS,
                 highest: HIGHEST_BEACON)

# This is the goal (fitness) parameter
MAX_ALLOWED_DISTANCE_ERROR  = 2.0

# This defines the controller
define "Beaconline" do
  # Define the IO neurons
  inputs {
    Hash[
      (1..NODE_COLUMNS).map{ |j|
        (1..NODE_ROWS).map{ |i|
          [node_key(i,j), InputNeuron]
        }
      }.flatten(1) + [[:bias, BiasNeuron]]
    ]
  }
  outputs ox: LinearNeuron,
          oy: LinearNeuron,
          oz: LinearNeuron,
          oerr: TanhNeuron # should be less 0 if signal is OK

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
  fitness_cost_per_neuron 0.00001
  fitness_cost_per_gene   0.00001

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
    # We'll use the seq to create the rssi sequences
    condition_rssi_vector $raum.distance_matrix[seq].map{ |node, (rssi, dist)| rssi }
  }
  

  # Compare the fitness of two critters. We may choose a different ordering
  # here.
  compare { |f1, f2| f1 <=> f2 }

  # Here we integrate the cost with the fitness.
  cost { |fitvec, cost|
    fit = fitvec.reduce(:+) / BEACONS + cost
    $log.debug ">>>>>>> fitvec #{fitvec} => #{fit}, cost #{cost}"
    fit
  }

  fitness { |vin, vout, seq|
    unless vout == :error
      nodes = uncondition_position_vector vin
      estimated_position = uncondition_position_vector vout
      actual_position = $raum.beacons.model[seq]
      fit = distance(estimated_position[0...3], actual_position)
      
      $log.debug "(%s) Fitness vin=%s, vout=%s, actual=%s, fit=%6.3f, seq=%s" %
                     [fit,
                      vin,
                      vout,
                      actual_position,
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
    fitness[:best] <= MAX_ALLOWED_DISTANCE_ERROR
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
