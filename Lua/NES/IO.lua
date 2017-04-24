--For all Input/Output and file manipulations--
function writeMutations()
  local file = io.open("Mutations.csv", "a")
  
  file:write(pool.gen .. "\n")
  for n,group in pairs(pool.groups) do
    file:write(#group.marioAgents .. "\n")
    for m,marioAgent in pairs(group.marioAgents) do
      for mutation,rate in pairs(marioAgent.mutationRates) do
        file:write(m .. ",")
				file:write(mutation .. ",")
				file:write(rate .. "\n")
			end
    end
  end
  --file:write("done\n")
  file:close()
end

function writeAvgNumNeurons()
  local totalNeurons = 0
  local file = io.open("Neurons.csv", "a")
  file:write(pool.gen .. ",")
  
  for n,group in pairs(pool.groups) do
    for m,marioAgent in pairs(group.marioAgents) do
      totalNeurons = totalNeurons + marioAgent.maxNeurons
    end
  end
  file:write(totalNeurons / 300 .. "\n")
  --file:write("done\n")
  file:close()
end

function writeAvgFitness()
  local totalFitness = 0
  local file = io.open("AvgFitness.csv", "a")
  file:write(pool.gen .. ",")
  
  for n,group in pairs(pool.groups) do
    for m,marioAgent in pairs(group.marioAgents) do
      totalFitness = totalFitness + marioAgent.fitness
    end
  end
  file:write(totalFitness / 300 .. "\n")
  --file:write("done\n")
  file:close()
end

function writeAvgNumTraits()
  local totalTraits = 0
  local file = io.open("Traits.csv", "a")
  file:write(pool.gen .. ",")
  
  for n,group in pairs(pool.groups) do
    for m,marioAgent in pairs(group.marioAgents) do
      totalTraits = totalTraits + #marioAgent.traits
    end
  end
  file:write(totalTraits / 300 .. "\n")
  --file:write("done\n")
  file:close()
end

function writeAvgGroupFitness()
  local file = io.open("GroupFitnesses.csv", "a")
  file:write(pool.gen .. ",")
  for n,group in pairs(pool.groups) do
    file:write(n .. "\n")
    file:write(group.avgFitness .. "\n")
  end
  --file:write("done\n")
  file:close()
end

function writeNumGroups()
  local file = io.open("NumGroups.csv", "a")
	file:write(pool.gen .. ",")
	file:write(#pool.groups .. "\n")
  --file:write("done\n")
  file:close()
end

function writeMaxFitness()
  local file = io.open("MaxFitnesses.csv", "a")
  file:write(pool.gen .. ",")
	file:write(pool.maxFitness .. "\n")
  --file:write("done\n")
  file:close()
end
  

function writeFile(filename)
    local file = io.open(filename, "w")
	file:write(pool.gen .. "\n")
	file:write(pool.maxFitness .. "\n")
	file:write(#pool.groups .. "\n")
  for n,group in pairs(pool.groups) do
		file:write(group.topFitness .. "\n")
		file:write(group.staleness .. "\n")
		file:write(#group.marioAgents .. "\n")
		for m,marioAgent in pairs(group.marioAgents) do
			file:write(marioAgent.fitness .. "\n")
			file:write(marioAgent.maxNeurons .. "\n")
			for mutation,rate in pairs(marioAgent.mutationRates) do
				file:write(mutation .. "\n")
				file:write(rate .. "\n")
			end
			file:write("done\n")

			file:write(#marioAgent.traits .. "\n")
			for l,trait in pairs(marioAgent.traits) do
				file:write(trait.inn .. " ")
				file:write(trait.out .. " ")
				file:write(trait.weight .. " ")
				file:write(trait.modernization .. " ")
				if(trait.enabled) then
					file:write("1\n")
				else
					file:write("0\n")
				end
			end
		end
        end
        file:close()
end



--takes in a pool file and reads the contents
function loadFile(filename)
  local file = io.open(filename, "r")
  --Create a new trait pool
	pool = createNewPool()

	--Read the generation
	pool.gen = file:read("*number")

	--Gather MaxFitness
	pool.maxFitness = file:read("*number")
		--Read the file
		--[[
		Line 1: Generation
		2: Max Fitness
		3: Num of Groups
		4: Top Fitness for Groups
		5: How Stale the group is
		6: Num of agents
		7: Top Fitness for set of agents
		8: Max neuron
		9-23: Setting the diffent rates
		24: Num of traits
		For each gene 25- Num of traits
		.1 Line: Into // what inputs need to be on screen to run this
		.2 Line: Out // what output to execute
		.3 Line: Weight // how important is this trait
		.4 Line: modernization // newness or changes to trait
		.5 Line: Enabled // whether or not to use the trait
		--]]
    local numGroups = file:read("*number")
    for s=1,numGroups do
      local group = createNewGroup()
      table.insert(pool.groups, group)
      group.topFitness = file:read("*number")
      group.staleness = file:read("*number")
      local numMarioAgents = file:read("*number")
      for g=1,numMarioAgents do
        local marioAgent = createNewMarioAgent()
        table.insert(group.marioAgents, marioAgent)
        marioAgent.fitness = file:read("*number")
        marioAgent.maxNeurons = file:read("*number")
        local line = file:read("*line")
        while line ~= "done" do
          marioAgent.mutationRates[line] = file:read("*number")
          line = file:read("*line")
        end
        local numTraits = file:read("*number")
        for n=1,numTraits do
          local trait = createNewTrait()
          table.insert(marioAgent.traits, trait)
          local enabled
          trait.inn, trait.out, trait.weight, trait.modernization, enabled = file:read("*number", "*number", "*number", "*number", "*number")
          if enabled == 0 then
            trait.enabled = false
          else
            trait.enabled = true
          end

        end
      end
    end
    file:close()

	while fitnessAlreadyMeasured() do
		findNextMarioAgent()
	end
	initRun()
	pool.currFrame = pool.currFrame + 1
end

--Save pool based on saveLoadFile name
function savePool()
	local filename = forms.gettext(saveLoadFile)
	writeFile("Pools/"..filename)
end


--Load pool baased on saveLoadFile name
function loadPool()
	local filename = forms.gettext(saveLoadFile)
	loadFile("Pools/"..filename)
end

function initializeFitnessFile()
	local file = io.open("Fitness.csv", "w")
	file:write("-1" ..","..tostring(0).. "\n")
	file:close()
end