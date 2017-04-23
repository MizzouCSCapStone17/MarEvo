--Set all global and constant variables here--
--Global variables denoted by a leading underscore in the name--

_stateFolder="States/"
_state = _stateFolder.."level.1-1.State"

_buttons = {
  "A",
  "B",
  "Up",
  "Down",
  "Left",
  "Right",
}

--where inputs will be taken in at. Basically the agents eye.
_boxRadius = 6

--amount of inputs the agent can take in. Twice the amount of the box b/c there are 2 inputs. Dynamic (enemies) and static (blocks)
_inputSize = (_boxRadius*2+1)*(_boxRadius*2+1)

--what the agent can see
_inputs = _inputSize + 1

--actions that the agent can take. Equal to num of buttons
_outputs = #_buttons

--number of agents per generation
_population = 150

_netGeneration = 0

--deltas for group selection
_deltaDisjoint = 2.0
_deltaWeights = 0.4
_deltaThreshold = 1.0

--how long until a group goes extinct if it doesnt improve
_staleGroup = 10

--chances used in mutation
_mutateConnectionsChance = 0.30
_perturbChance = 0.85 --whether or not to increase/decrese weight
_crossoverChance = 0.80 --chance of mating
_linkMutationChance = 2.0
_nodeMutationChance = 0.55
_biasMutationChance = 0.45
_stepSize = 0.1 --for gradient descent
_disableMutationChance = 0.35
_enableMutationChance = 0.25

--how long until timeout
_timeoutConstant = 30

--if group has died
_autoTimeout = false

--what happens if group has died
_noFitness = false

--num agents can end in one location and not lose fitness
_noveltyConstant = 1
_currentNSFitness = 0

--fitness score weights
_distanceWeight = 2
_scoreWeight = 1
_noveltyWeight = 10

--fitness = 0

--total num of connecting nodes possible for each trait. So output nodes can start at a certain number
_maxNodes = 1000000