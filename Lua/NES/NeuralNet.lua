require "Mutate"
require "Fitness"
require "Inputs"
require "IO"

function findMaxFitnessForGeneration()
  local generationDistanceFitness = 0
  local generationMaxFitness = 0
  
  for n,groups in pairs(pool.groups) do
		for m,marioAgents in pairs(pool.groups.marioAgents) do
      
      if marioAgent.fitness > generationMaxFitness then
				generationMaxFitness = marioAgent.fitness
			end
			
			if marioAgent.distanceFitness > generationDistanceFitness then
				generationDistanceFitness = marioAgent.distanceFitness
			end
      
		end
	end
end

function setNoveltyFitness()
	local file = io.open("Fitness.csv", "a")
	local nspCount = 0
  
	for loc,set in pairs(pool.landscape) do
		local count = 0
		for ga,value in pairs(set) do
        	count = count + 1
		end
		if count <= tonumber(forms.gettext(noveltyConstantText)) then
			nspCount = nspCount + 1
		 	for ga,value in pairs(set) do
        local group = math.floor(tonumber(ga) / 100)
        local marioAgent = tonumber(ga) % 100

				pool.groups[group].marioAgents[marioAgent].fitness = pool.groups[group].marioAgents[marioAgent].fitness + (tonumber((forms.gettext(noveltyConstantText)) - count) * tonumber(forms.gettext(noveltyWeight)))
			end
		end
	end
  
	file:write(pool.generation ..","..tostring(nspCount).. "\n")
	console.writeline("NSP: " .. nspCount)
	file:close()
end

function gainNoveltyFitness(location)
	if pool.generation > 0 then
		local count = 0
		if pool.oldLandscape[location] ~= nil then
			for k,v in pairs(pool.oldLandscape[location]) do
        count = count + 1
			end
		end
		if count <= tonumber(forms.gettext(noveltyConstantText)) then
			_currentNSFitness = _currentNSFitness + 1
		end
	end
end

--determine if neuron val is +/-
function sigmoid(x)
  return 2/(1+math.exp(-4.9*x))-1
end

--a new collection of all groups for all generations
function newPool()
  local pool = {}
  pool.generation = 0
  pool.modernization = _outputs 
  pool.landscape = {}
  pool.oldLandscape = {}
  pool.groups = {}
  pool.currGroup = 1
  pool.currMarioAgent = 1
  pool.currentFrame = 0
  pool.maxFitness = 0
  
  return pool
end

--increase the modernization of the pool
function newModernization()
  pool.modernization = pool.modernization + 1
  return pool.modernization
end

--a new agent. the thing that evolves
function newMarioAgent()
  local marioAgent = {}
  marioAgent.fitness = 0 --how good the agent is
  marioAgent.traits = {} --like genes
  marioAgent.nn = {} --truth table of all input/output vals
  marioAgent.maxNeurons = 0 --num inputs
  marioAgent.globalRank = 0 --rank compared to other agents
  marioAgent.ran = false
  marioAgent.mutationRates = {}
  marioAgent.mutationRates["connections"] = _mutateConnectionsChance
  marioAgent.mutationRates["link"] = _linkMutationChance
  marioAgent.mutationRates["bias"] = _biasMutationChance
  marioAgent.mutationRates["node"] = _nodeMutationChance
  marioAgent.mutationRates["enable"] = _enableMutationChance
  marioAgent.mutationRates["disable"] = _disableMutationChance
  marioAgent.mutationRates["step"] = _stepSize
    
  return marioAgent
end

--copys an agent to another agent
function copyMarioAgent(marioAgent)
  local tempMarioAgent = newMarioAgent()
    
  for t = 1, #marioAgent.traits do
    table.insert(tempMarioAgent.traits, copyTrait(marioAgent.traits[t]))
  end
    
  tempMarioAgent.maxNeurons = marioAgent.maxNeurons
  tempMarioAgent.mutationRates["connections"] = marioAgent.mutationRates["connections"]
  tempMarioAgent.mutationRates["link"] = marioAgent.mutationRates["link"]
  tempMarioAgent.mutationRates["bias"] = marioAgent.mutationRates["bias"]
  tempMarioAgent.mutationRates["node"] = marioAgent.mutationRates["node"]
  tempMarioAgent.mutationRates["enable"] = marioAgent.mutationRates["enable"]
  tempMarioAgent.mutationRates["disable"] = marioAgent.mutationRates["disable"]
    
  return tempMarioAgent
end

--creates a primitiveAgent agent ready to run
function primitiveMarioAgent()
  local primitiveMarioAgent = newMarioAgent()
  local modernization = 1

  primitiveMarioAgent.maxNeurons = _inputs
  --give the agent a chance to mutate right off the bat
  mutate(primitiveMarioAgent)
    
  return primitiveMarioAgent
end



--create new trait, like a gene
function newTrait()
  local trait = {}
  trait.enabled = true
  trait.inn = 0
  trait.out = 0
  trait.weight = 0.0
  trait.modernization = 0
    
  return trait
end

--copies trait to another trait
function copyTrait(trait)
  local tempTrait = newTrait()
  tempTrait.enabled = trait.enabled
  tempTrait.inn = trait.inn
  tempTrait.out = trait.out
  tempTrait.weight = trait.weight
  tempTrait.modernization = trait.modernization
    
  return tempTrait
end


--sees how many traits are in common between two sets of traits
function disjoint(traits1, traits2)
    local temp1 = {}
    local temp2 = {}
    local disjointTraits = 0
    local n = 0
    
    for t = 1, #traits1 do
        local trait = traits1[t]
        temp1[trait.modernization] = true
    end

    for t = 1, #traits2 do
        local trait = traits2[t]
        temp2[trait.modernization] = true
    end
    
    for t = 1, #traits1 do
        local trait = traits1[t]
        if not temp2[trait.modernization] then
            disjointTraits = disjointTraits + 1
        end
    end
    
    for t = 1, #traits2 do
        local trait = traits2[t]
        if not temp1[trait.modernization] then
            disjointTraits = disjointTraits + 1
        end
    end
    
    n = math.max(#traits1, #traits2)
    
    return disjointTraits / n
end

--sums the weights of two sets of traits
function weights(traits1, traits2)
  local temp = {}
  local sum = 0
  local coincident = 0
  
  for t = 1, #traits2 do
    local trait = traits2[t]
    temp[trait.modernization] = trait
  end

  for t = 1, #traits1 do
    local trait = traits1[t]
    if temp[trait.modernization] ~= nil then
      local tempTrait = temp[trait.modernization]
      sum = sum + math.abs(trait.weight - tempTrait.weight)
      coincident = coincident + 1
    end
  end
    
  return sum / coincident
end

--create new group
function newGroup()
  local group = {}
  group.marioAgents = {} --list of all agents in the group
  group.topFitness = 0
  group.avgFitness = 0
  group.staleness = 0 --num gens in a row the group hasnt got better
    
  return group
end


--adds the new child agent to a group similar to it
function addAgentToGroup(agent)
  local foundGroup = false
  
  for g = 1, #pool.groups do
    local group = pool.groups[g]
    if not foundGroup and sameGroup(agent, group.marioAgents[1]) then
      table.insert(group.marioAgents, agent)
      foundGroup = true
    end
  end
    
  if not foundGroup then
    local agentGroup = newGroup()
    table.insert(agentGroup.marioAgents, agent)
    table.insert(pool.groups, agentGroup)
  end
end

--finds if to agents have the same group
function sameGroup(agent1, agent2)
  local dd = _dDisjoint*disjoint(agent1.traits, agent2.traits)
  local dw = _dWeights*weights(agent1.traits, agent2.traits) 
  
  return dd + dw < _dThreshold
end

--create a new neruon
function newNeuron()
  local neuron = {}
  neuron.value = 0.0
  neuron.incoming = {}
    
  return neuron
end

--creates a network that will take inputs from agent and spit out output for the agent
function generateNeuralNet(marioAgent)
    local neuralNet = {}
    neuralNet.neurons = {}
    
    --create neurons needed for inputs
    for i = 1, _inputs do
        neuralNet.neurons[i] = newNeuron()
    end
    
    --create output neurons afer max num if nodes
    for o = 1, _outputs do
        neuralNet.neurons[_maxNeurons+o] = newNeuron()
    end
    
    --sort traits by output
    table.sort(marioAgent.traits, function (a,b)
        return (a.out < b.out)
    end)
  
  --for all traits
    for t = 1, #marioAgent.traits do
        local trait = marioAgent.traits[t]
        if trait.enabled then
            --make new neuron for output
            if neuralNet.neurons[trait.out] == nil then
                neuralNet.neurons[trait.out] = newNeuron()
            end
            local neuron = neuralNet.neurons[trait.out]
            --set incoming neuron of the outout neruon to be isself
            table.insert(neuron.incoming, trait)
            if neuralNet.neurons[trait.inn] == nil then
                neuralNet.neurons[trait.inn] = newNeuron()
            end
        end
    end
    
    marioAgent.nn = neuralNet
end

--get outpur from network based on inputs
function evaluateNeuralNet(nn, inputs)
  table.insert(inputs, 1)
  local outputs = {}
    
  --set all neurons equal to val of inputs
  for i = 1, _inputs do
    nn.neurons[i].value = inputs[i]
  end
    
    
  for _,neuron in pairs(nn.neurons) do
    local sum = 0
    for ni = 1, #neuron.incoming do
      --go through all traits that connect an output
      local incoming = neuron.incoming[ni]
      --find input that this connects to
      local temp = nn.neurons[incoming.inn]
      --get sum
      sum = sum + incoming.weight * temp.value
    end
        
    --change val of neuron using sum and the sigmoid func
    if #neuron.incoming > 0 then
      neuron.value = sigmoid(sum)
    end
  end
    
  --add all active outputs for set of inputs
  for o = 1, _outputs do
    local button = _buttons[o]
    if nn.neurons[_maxNeurons+o].value <= 0 then
      outputs[button] = false
    else
      outputs[button] = true
    end
  end
    
  return outputs
end

--uses evaluateNeuralNet to evaluate the network and ensure left/right and up/down are not pressed at same time
function evaluateCurrentAgent()
  local group = pool.groups[pool.currGroup]
  local marioAgent = group.marioAgents[pool.currMarioAgent]

  inputs = getInputs()
  controller = evaluateNeuralNet(marioAgent.nn, inputs)
    
  if controller["Up"] and controller["Down"] then
    controller["Up"] = false
    controller["Down"] = false
  end
  if controller["Left"] and controller["Right"] then
    controller["Left"] = false
    controller["Right"] = false
  end

  joypad.set(controller, 1)
end

--check if the current agent has already ran
function agentAlreadyRan()
  local group = pool.groups[pool.currGroup]
  local marioAgent = group.marioAgents[pool.currMarioAgent]
    
  return marioAgent.ran
end

--finds next agent to run
function nextMarioAgent()
  pool.currMarioAgent = pool.currMarioAgent + 1
  
  --iterate through all agents to see if all have ran and if so, new generation
  if pool.currMarioAgent > #pool.groups[pool.currGroup].marioAgents then
    pool.currMarioAgent = 1
    pool.currGroup = pool.currGroup + 1
    if pool.currGroup > #pool.groups then
      newGeneration()
      pool.currGroup = 1
    end
  end
end

--finds the percent of agents to already run
function percentCompleted()
  local total = 0
  local measured = 0
  
  for _,group in pairs(pool.groups) do
    for _,marioAgent in pairs(group.marioAgents) do
      total = total + 1
      if marioAgent.ran then
        measured = measured + 1
      end
    end
  end
  
  return math.floor(measured / total * 100)
end

--creates a new generation of agents
function newGeneration()
  local sum = 0
  local children = {}
  setNoveltyFitness()
  
	for loc,set in pairs(pool.landscape) do
		pool.oldLandscape[loc] = {}
		for ga,value in pairs(set) do
      pool.oldLandscape[loc][ga] = true
		end
	end
  
	--findMaxFitnessForGeneration()
  pool.landscape = {}
  
  cullGroup(false) -- Cull the bottom half of each group
  rankAgentsGlobally()
  killStaleGroups() -- remove groups who havent improved
  rankAgentsGlobally()
  
  for g = 1,#pool.groups do
    local group = pool.groups[g]
    calcAvgFitness(group)
  end
  
  killWeakGroups() --remove groups that are classified as weak
  
  sum = totalAvgFitness()
  children = {}
  
  for s = 1,#pool.groups do
    local group = pool.groups[s]
    numToBreed = math.floor(group.avgFitness / sum * _population) - 1
    for i=1,numToBreed do
      table.insert(children, breedChildAgent(group))
    end
  end
  
  cullGroup(true) -- Cull all but the top member of each group
  
  while #children + #pool.groups < _population do
    local group = pool.groups[math.random(1, #pool.groups)]
    table.insert(children, breedChildAgent(group))
  end
  for c=1,#children do
    local child = children[c]
    addAgentToGroup(child)
  end
    
  pool.generation = pool.generation + 1
  
  writeFile("Pools/gen" .. pool.generation .. "." .. marioWorld .. "-".. marioLevel .. ".pool")
  writeMutations()
  writeAvgNumNeurons()
  writeAvgNumTraits()
  writeAvgGroupFitness()
  writeNumGroups()
  writeMaxFitness()
  writeAvgFitness()

end

--breeds a new agent from a given group, either through crossover and a simple copy
function breedChildAgent(group)
  local child = {}
    
  if math.random() > _crossoverChance then
    agent = group.marioAgents[math.random(1, #group.marioAgents)]
    child = copyMarioAgent(agent)
  else
    agent1 = group.marioAgents[math.random(1, #group.marioAgents)]
    agent2 = group.marioAgents[math.random(1, #group.marioAgents)]
    child = crossover(agent1, agent2)
  end
    
    mutate(child)
    
    return child
end

--finds random neuron from some list of traits
function randomNeuron(traits, nonInput)
    local neurons = {}
    local count = 0
    local n = 0
    
    --add all inputs
    if not nonInput then
        for i = 1, _inputs do
            neurons[i] = true
        end
    end
    --add all outputs
    for o = 1, _outputs do
        neurons[_maxNeurons+o] = true
    end
    for t = 1, #traits do
        --add seperate gene inputs
        if (not nonInput) or traits[t].inn > _inputs then
            neurons[traits[t].inn] = true
        end
        --add seperate gene outputs
        if (not nonInput) or traits[t].out > _inputs then
            neurons[traits[t].out] = true
        end
    end

    --count how many neurons we came up with
    for _,_ in pairs(neurons) do
        count = count + 1
    end
    --generate random number inside this amount
    n = math.random(1, count)
    
    --find the random neuron
    for key, value in pairs(neurons) do
        n = n-1
        if n == 0 then
            return key
        end
    end
    
    return 0
end

--breeding down by combining two agents
function crossover(agent1, agent2)
  -- Make sure g1 is the higher fitness marioAgent
  if agent2.fitness > agent1.fitness then
    tempAgent = agent1
    agent1 = agent2
    agent2 = tempAgent
  end

  local child = newMarioAgent()
    
  local modernizations2 = {}
  for t = 1, #agent2.traits do
    local trait = agent2.traits[t]
    modernizations2[trait.modernization] = trait
  end
    
  for t = 1, #agent1.traits do
    local tempTrait = agent1.traits[t]
    local tempTrait2 = modernizations2[tempTrait.modernization]
    if tempTrait2 ~= nil and math.random(2) == 1 and tempTrait2.enabled then
      table.insert(child.traits, copyTrait(tempTrait2))
    else
      table.insert(child.traits, copyTrait(tempTrait))
    end
  end
    
  child.maxNeurons = math.max(agent1.maxNeurons, agent2.maxNeurons)
    
  for m, r in pairs(agent1.mutationRates) do
    child.mutationRates[m] = r
  end
    
  return child
end



--Removes agents from a group. If cut to one agnet, then one agent remians in group
function cullGroup(toOneAgent)
  for s = 1,#pool.groups do
    local group = pool.groups[s]
        
    table.sort(group.marioAgents, function (a,b)
      return (a.fitness > b.fitness)
    end)
        
    local remainingAgents = math.ceil(#group.marioAgents/2)
    if ctoOneAgent then
      remainingAgents = 1
    end
    while #group.marioAgents > remainingAgents do
      table.remove(group.marioAgents)
    end
  end
end

--removes groups that have not improved
function killStaleGroups()
  local notStale = {}

  for g = 1,#pool.groups do
    local group = pool.groups[g]
        
    table.sort(group.marioAgents, function (a,b)
      return (a.fitness > b.fitness)
    end)
    --look at fitness from top agent in group and see if higher that the current group top fitness
    if group.marioAgents[1].fitness < group.topFitness then
      group.staleness = group.staleness + 1
    else
      group.staleness = 0
      group.topFitness = group.marioAgents[1].fitness
    end
    --if group is below the stale threshold or has set a new max fitness, then they do not get voted off the island
    if group.topFitness >= pool.maxFitness or group.staleness < _staleGroupThreshold then
      table.insert(notStale, group)
    end
  end
  --num of groups now is equal to only the survivors
  pool.groups = notStale
end

--remvoes groups that are classified as weak
function killWeakGroups()
    local notWeak = {}
    local sum = 0
    
    sum = totalAvgFitness()
    for g = 1, #pool.groups do
        local group = pool.groups[g]
        numToBreed = math.floor(group.avgFitness / sum * _population)
        if numToBreed >= 1 then
            table.insert(notWeak, group)
        end
    end

    pool.groups = notWeak
end

--creates the pool to be used
function initializePool()
    pool = newPool()
    
    initializeFitnessFile()

    for i = 1, _population do
        primitiveAgent = primitiveMarioAgent()
        addAgentToGroup(primitiveAgent)
    end

    initializeRun()
end

function initializeRun()
    savestate.load(_state)
    furthestDistance = 0
    pool.currentFrame = 0
    timeout = _timeoutConstant
    _currentNSFitness = 0
    getPositions()
    getScore()
    netX = marioX
    --netScore = marioScore
    clearController()
    
    local group = pool.groups[pool.currGroup]
    local marioAgent = group.marioAgents[pool.currMarioAgent]
    
    generateNeuralNet(marioAgent)
    evaluateCurrentAgent()
end

function clearController()
  controller = {}
    
  for b = 1, #_buttons do
    controller[_buttons[b]] = false
  end
  
  joypad.set(controller, 1)
end