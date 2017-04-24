require "Mutate"
require "Fitness"
require "Inputs"
require "IO"

function findMaxFitnessForGeneration()
		local generationMaxFitness=0
		local generationDistanceFitness=0
		for n,groups in pairs(pool.group) do
		for m,marioAgents in pairs(pool.group.marioAgents) do
			
			if marioAgent.distanceFitness > generationDistanceFitness then
				generationDistanceFitness = marioAgent.distanceFitness
			end

			if marioAgent.fitness > generationMaxFitness then
				generationMaxFitness = marioAgent.fitness
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

				pool.group[group].marioAgents[marioAgent].fitness = pool.group[group].marioAgents[marioAgent].fitness + (tonumber((forms.gettext(noveltyConstantText)) - count) * tonumber(forms.gettext(noveltyWeight)))
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
  pool.group = {}
  pool.generation = 0
  pool.innovation = _outputs 
  pool.currentGroup = 1
  pool.currentMarioAgent = 1
  pool.currentFrame = 0
  pool.maxFitness = 0
    
  pool.landscape = {}
  pool.oldLandscape = {}
  --stats
  pool.maxFitnessAgent = {} --Vanillia Best Fitness of this Generation per Genome
	pool.maxDistanceAgent = {} --Highest Rightmost Fitnes of this Generation per Genome
	pool.maxNoveltyAgent = {} --Highest Novelty Fitness of this Generation per Genome
	pool.maxFitnessCollective = {} --Vanillia Best Fitness of this Generation per Genome
	pool.maxDistanceCollective = {} --Highest Rightmost Fitnes of this Generation per Genome
	pool.maxNoveltyCollective = {} --Highest Novelty Fitness of this Generation per Genome
	pool.avgFitnessGenome = {} --Vanillia Best Fitness of this Generation per Genome
	pool.avgDistanceGenome = {} --Highest Rightmost Fitnes of this Generation per Genome
	pool.avgNoveltyGenome = {} --Highest Novelty Fitness of this Generation per Genome
	pool.avgFitnessCollective = {} --Vanillia Best Fitness of this Generation per Genome
	pool.avgDistanceCollective = {} --Highest Rightmost Fitnes of this Generation per Genome
	pool.avgNoveltyCollective = {} --Highest Novelty Fitness of this Generation per Genome
	NetWorld = marioWorld
	NetLevel = marioLevel
	half = false
    
    return pool
end

--increase the innovation of the pool
function newInnovation()
    pool.innovation = pool.innovation + 1
    return pool.innovation
end

--a new agent. the thing that evolves
function newMarioAgent()
    local marioAgent = {}
    marioAgent.traits = {} --like genes
    marioAgent.fitness = 0 --how good the agent is
    marioAgent.distanceFitness = 0
    marioAgent.nn = {} --truth table of all input/output vals
    marioAgent.maxNeuron = 0 --num inputs
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
    local marioAgent2 = newMarioAgent()
    for t = 1, #marioAgent.traits do
        table.insert(marioAgent2.traits, copyTrait(marioAgent.traits[t]))
    end
    marioAgent2.maxNeuron = marioAgent.maxNeuron
    marioAgent2.mutationRates["connections"] = marioAgent.mutationRates["connections"]
    marioAgent2.mutationRates["link"] = marioAgent.mutationRates["link"]
    marioAgent2.mutationRates["bias"] = marioAgent.mutationRates["bias"]
    marioAgent2.mutationRates["node"] = marioAgent.mutationRates["node"]
    marioAgent2.mutationRates["enable"] = marioAgent.mutationRates["enable"]
    marioAgent2.mutationRates["disable"] = marioAgent.mutationRates["disable"]
    
    return marioAgent2
end

--creates a basic agent ready to run
function basicMarioAgent()
    local marioAgent = newMarioAgent()
    local innovation = 1

    marioAgent.maxNeuron = _inputs
    --give the agent a chance to mutate right off the bat
    mutate(marioAgent)
    
    return marioAgent
end



--create new trait, like a gene
function newTrait()
    local trait = {}
    trait.into = 0
    trait.out = 0
    trait.weight = 0.0
    trait.enabled = true
    trait.innovation = 0
    
    return trait
end

--copies trait to another trait
function copyTrait(trait)
    local trait2 = newTrait()
    trait2.into = trait.into
    trait2.out = trait.out
    trait2.weight = trait.weight
    trait2.enabled = trait.enabled
    trait2.innovation = trait.innovation
    
    return trait2
end

function disjoint(traits1, traits2)
    local i1 = {}
    for i = 1,#traits1 do
        local trait = traits1[i]
        i1[trait.innovation] = true
    end

    local i2 = {}
    for i = 1,#traits2 do
        local trait = traits2[i]
        i2[trait.innovation] = true
    end
    
    local disjointTraits = 0
    for i = 1,#traits1 do
        local trait = traits1[i]
        if not i2[trait.innovation] then
            disjointTraits = disjointTraits+1
        end
    end
    
    for i = 1,#traits2 do
        local trait = traits2[i]
        if not i1[trait.innovation] then
            disjointTraits = disjointTraits+1
        end
    end
    
    local n = math.max(#traits1, #traits2)
    
    return disjointTraits / n
end

function weights(traits1, traits2)
    local i2 = {}
    for i = 1,#traits2 do
        local trait = traits2[i]
        i2[trait.innovation] = trait
    end

    local sum = 0
    local coincident = 0
    for i = 1,#traits1 do
        local trait = traits1[i]
        if i2[trait.innovation] ~= nil then
            local gene2 = i2[trait.innovation]
            sum = sum + math.abs(trait.weight - gene2.weight)
            coincident = coincident + 1
        end
    end
    
    return sum / coincident
end

--create new group
function newGroup()
    local group = {}
    group.topFitness = 0
    group.staleness = 0 --num gens in a row the group hasnt got better
    group.marioAgents = {} --list of all agents in the group
    group.averageFitness = 0
    
    return group
end


--adds the new child agent to a group similar to it
function addToGroup(child)
    local foundGroup = false
    for s=1,#pool.group do
        local group = pool.group[s]
        if not foundGroup and sameGroup(child, group.marioAgents[1]) then
            table.insert(group.marioAgents, child)
            foundGroup = true
        end
    end
    
    if not foundGroup then
        local childGroup = newGroup()
        table.insert(childGroup.marioAgents, child)
        table.insert(pool.group, childGroup)
    end
end

--finds if to agents have the same group
function sameGroup(marioAgent1, marioAgent2)
    local dd = _deltaDisjoint*disjoint(marioAgent1.traits, marioAgent2.traits)
    local dw = _deltaWeights*weights(marioAgent1.traits, marioAgent2.traits) 
    return dd + dw < _deltaThreshold
end

--create a new neruon
function newNeuron()
    local neuron = {}
    neuron.incoming = {}
    neuron.value = 0.0
    
    return neuron
end

--creates a network that will take inputs from agent and spit out output for the agent
function generateNeuralNet(marioAgent)
    local neuralNet = {}
    neuralNet.neurons = {}
    
    --create neurons needed for inputs
    for i=1,_inputs do
        neuralNet.neurons[i] = newNeuron()
    end
    
    --create output neurons afer max num if nodes
    for o=1,_outputs do
        neuralNet.neurons[_maxNodes+o] = newNeuron()
    end
    
    --sort traits by output
    table.sort(marioAgent.traits, function (a,b)
        return (a.out < b.out)
    end)
  --for all traits
    for i=1,#marioAgent.traits do
        local trait = marioAgent.traits[i]
        if trait.enabled then
            --make new neuron for output
            if neuralNet.neurons[trait.out] == nil then
                neuralNet.neurons[trait.out] = newNeuron()
            end
            local neuron = neuralNet.neurons[trait.out]
            --set incoming neuron of the outout neruon to be isself
            table.insert(neuron.incoming, trait)
            if neuralNet.neurons[trait.into] == nil then
                neuralNet.neurons[trait.into] = newNeuron()
            end
        end
    end
    
    marioAgent.nn = neuralNet
end

--get outpur from network based on inputs
function evaluateNeuralNet(nn, inputs)
    table.insert(inputs, 1)
    
    if #inputs ~= _inputs then
        print("Wrong num of neural net inputs.")
        return {}
    end
    
    --set all neurons equal to val of inputs
    for i=1,_inputs do
        nn.neurons[i].value = inputs[i]
    end
    
    
    for _,neuron in pairs(nn.neurons) do
        local sum = 0
        for j = 1,#neuron.incoming do
            --go through all traits that connect an output
            local incoming = neuron.incoming[j]
            --find input that this connects to
            local other = nn.neurons[incoming.into]
            --get sum
            sum = sum + incoming.weight * other.value
        end
        
        --change val of neuron using sum and the sigmoid func
        if #neuron.incoming > 0 then
            neuron.value = sigmoid(sum)
        end
    end
    
    --add all active outputs for set of inputs
    local outputs = {}
    for o=1,_outputs do
        local button = _buttons[o]
        if nn.neurons[_maxNodes+o].value > 0 then
            outputs[button] = true
        else
            outputs[button] = false
        end
    end
    
    return outputs
end

function evaluateCurrent()
    local group = pool.group[pool.currentGroup]
    local marioAgent = group.marioAgents[pool.currentMarioAgent]

    inputs = getInputs()
    controller = evaluateNeuralNet(marioAgent.nn, inputs)
    
    if controller["Left"] and controller["Right"] then
        controller["Left"] = false
        controller["Right"] = false
    end
    if controller["Up"] and controller["Down"] then
        controller["Up"] = false
        controller["Down"] = false
    end

    joypad.set(controller, 1)
end

function agentAlreadyRan()
  local group = pool.group[pool.currentGroup]
  local marioAgent = group.marioAgents[pool.currentMarioAgent]
    
  return marioAgent.ran
end
function nextMarioAgent()
    pool.currentMarioAgent = pool.currentMarioAgent + 1
    if pool.currentMarioAgent > #pool.group[pool.currentGroup].marioAgents then
        pool.currentMarioAgent = 1
        pool.currentGroup = pool.currentGroup + 1
        if pool.currentGroup > #pool.group then
            newGeneration()
            pool.currentGroup = 1
        end
    end
end

function percentCompleted()
  local total = 0
  local measured = 0
  
  for _,group in pairs(pool.group) do
    for _,marioAgent in pairs(group.marioAgents) do
      total = total + 1
      if marioAgent.ran then
        measured = measured + 1
      end
    end
  end
  
  return math.floor(measured/total*100)
end

function newGeneration()
  --if forms.ischecked(noveltyIsOn) then
		setNoveltyFitness()
	--end
  
	for loc,set in pairs(pool.landscape) do
		pool.oldLandscape[loc] = {}
		for sg,value in pairs(set) do
        	pool.oldLandscape[loc][sg] = true
		end
	end
  
	--findMaxFitnessForGeneration()
  pool.landscape={}
  
  
  cullGroup(false) -- Cull the bottom half of each group
  rankGlobally()
  removeStaleGroup()
  rankGlobally()
  
  for s = 1,#pool.group do
    local group = pool.group[s]
    calculateAverageFitness(group)
  end
  
  removeWeakGroup()
  
  local sum = totalAverageFitness()
  local children = {}
  
  for s = 1,#pool.group do
    local group = pool.group[s]
    breed = math.floor(group.averageFitness / sum * _population) - 1
    for i=1,breed do
      table.insert(children, breedChild(group))
    end
  end
  
  cullGroup(true) -- Cull all but the top member of each group
  
  while #children + #pool.group < _population do
    local group = pool.group[math.random(1, #pool.group)]
    table.insert(children, breedChild(group))
  end
  for c=1,#children do
    local child = children[c]
    addToGroup(child)
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
function breedChild(group)
    local child = {}
    if math.random() < _crossoverChance then
        a1 = group.marioAgents[math.random(1, #group.marioAgents)]
        a2 = group.marioAgents[math.random(1, #group.marioAgents)]
        child = crossover(a1, a2)
    else
        a = group.marioAgents[math.random(1, #group.marioAgents)]
        child = copyMarioAgent(a)
    end
    
    mutate(child)
    
    return child
end

--finds random neuron from some list of traits
function randomNeuron(traits, nonInput)
    local neurons = {}
    --add all inputs
    if not nonInput then
        for i=1,_inputs do
            neurons[i] = true
        end
    end
    --add all outputs
    for o=1,_outputs do
        neurons[_maxNodes+o] = true
    end
    for i=1,#traits do
        --add seperate gene inputs
        if (not nonInput) or traits[i].into > _inputs then
            neurons[traits[i].into] = true
        end
        --add seperate gene outputs
        if (not nonInput) or traits[i].out > _inputs then
            neurons[traits[i].out] = true
        end
    end

    local count = 0
    --count how many neurons we came up with
    for _,_ in pairs(neurons) do
        count = count + 1
    end
    --generate random number inside this amount
    local n = math.random(1, count)
    
    --find the random neuron
    for k,v in pairs(neurons) do
        n = n-1
        if n == 0 then
            return k
        end
    end
    
    return 0
end

function crossover(g1, g2)
    -- Make sure g1 is the higher fitness marioAgent
    if g2.fitness > g1.fitness then
        tempg = g1
        g1 = g2
        g2 = tempg
    end

    local child = newMarioAgent()
    
    local innovations2 = {}
    for i=1,#g2.traits do
        local trait = g2.traits[i]
        innovations2[trait.innovation] = trait
    end
    
    for i=1,#g1.traits do
        local gene1 = g1.traits[i]
        local gene2 = innovations2[gene1.innovation]
        if gene2 ~= nil and math.random(2) == 1 and gene2.enabled then
            table.insert(child.traits, copyTrait(gene2))
        else
            table.insert(child.traits, copyTrait(gene1))
        end
    end
    
    child.maxNeuron = math.max(g1.maxNeuron,g2.maxNeuron)
    
    for mutation,rate in pairs(g1.mutationRates) do
        child.mutationRates[mutation] = rate
    end
    
    return child
end


--Removes agents from a group. If cut to one, then one agent remians in group
function cullGroup(cutToOne)
    for s = 1,#pool.group do
        local group = pool.group[s]
        
        table.sort(group.marioAgents, function (a,b)
            return (a.fitness > b.fitness)
        end)
        
        local remaining = math.ceil(#group.marioAgents/2)
        if cutToOne then
            remaining = 1
        end
        while #group.marioAgents > remaining do
            table.remove(group.marioAgents)
        end
    end
end

--removes groups that have not improved
function removeStaleGroup()
    local survived = {}

    for s = 1,#pool.group do
        local group = pool.group[s]
        
        table.sort(group.marioAgents, function (a,b)
            return (a.fitness > b.fitness)
        end)
        --look at fitness from top agent in group and see if higher that the current group top fitness
        if group.marioAgents[1].fitness > group.topFitness then
            group.topFitness = group.marioAgents[1].fitness
            group.staleness = 0
        else
            group.staleness = group.staleness + 1
        end
        --if group is below the stale threshold or has set a new max fitness, then they do not get voted off the island
        if group.staleness < _staleGroup or group.topFitness >= pool.maxFitness then
            table.insert(survived, group)
        end
    end
    --num of groups now is equal to only the survivors
    pool.group = survived
end

function removeWeakGroup()
    local survived = {}

    local sum = totalAverageFitness()
    for s = 1,#pool.group do
        local group = pool.group[s]
        breed = math.floor(group.averageFitness / sum * _population)
        if breed >= 1 then
            table.insert(survived, group)
        end
    end

    pool.group = survived
end

function initializePool()
    pool = newPool()
    
    initializeFitnessFile()

    for i=1, _population do
        basic = basicMarioAgent()
        addToGroup(basic)
    end

    initializeRun()
end

function initializeRun()
    savestate.load(_state2)
    furthestDistance = 0
    pool.currentFrame = 0
    timeout = _timeoutConstant
    _currentNSFitness = 0
    getPositions()
    getScore()
    netX = marioX
    --netScore = marioScore
    clearJoypad()
    
    local group = pool.group[pool.currentGroup]
    local marioAgent = group.marioAgents[pool.currentMarioAgent]
    generateNeuralNet(marioAgent)
    evaluateCurrent()
end

function clearJoypad()
    controller = {}
    for b = 1,#_buttons do
        controller[_buttons[b]] = false
    end
  joypad.set(controller, 1)
end