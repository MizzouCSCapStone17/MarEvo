--ranks all agents and determines one w/ highest fitness. higher rank = higher fitness
function rankAgentsGlobally()
  local globalRankings = {}
  
  for g = 1,#pool.groups do
    local group = pool.groups[g]
    for a = 1,#group.marioAgents do
      table.insert(globalRankings, group.marioAgents[a])
    end
  end
  
  table.sort(globalRankings, function (a,b)
    return (a.fitness < b.fitness)
  end)
    
  for a = 1, #globalRankings do
    globalRankings[a].globalRank = a
  end
end

--determines if current agent has fitness measured
function fitnessAlreadyMeasured()
  local group = pool.groups[pool.currGroup]
  local marioAgent = group.marioAgents[pool.currMarioAgent]
    
  return marioAgent.fitness ~= 0
end

--calculates avg fitness of a group by global rank added up divided by num of agents
function calcAvgFitness(group)
  local totalFitness = 0
  
  for a = 1, #group.marioAgents do
    local marioAgent = group.marioAgents[a]
    totalFitness = totalFitness + marioAgent.globalRank
  end
    
  group.avgFitness = totalFitness / #group.marioAgents
    
end

--total is sum of the total avg fitness for each group
function totalAvgFitness()
  local totalFitness = 0
  for g = 1, #pool.groups do
    local group = pool.groups[g]
    totalFitness = totalFitness + group.avgFitness
  end

  return totalFitness
end

--calculates total fitness for all agents
function calcTotalFitness()
  local distanceFitness = 0
  local scoreFitness = 0
  local noveltyFitness = 0
  local fitnesses = {0, 0, 0}
  local total = 0
      
  distanceFitness = tonumber(forms.gettext(distanceWeight)) * (furthestDistance - netX)
  console.write("Distance: " .. distanceFitness .. "\n")
    
  scoreFitness = tonumber(forms.gettext(scoreWeight)) * (marioScore)
  console.write("Score: " .. scoreFitness .. "\n")
    
  noveltyFitness = tonumber(forms.gettext(noveltyWeight)) * (_currentNSFitness)
  console.write("Novelty: " .. noveltyFitness .. "\n")

  fitnesses[0] = distanceFitness
  fitnesses[1] = scoreFitness
  fitnesses[2] = noveltyFitness
  
  total = fitnesses[0] + fitnesses[1] + fitnesses[2]
      
  return total
end

--sets the novelty fitness score for an agent
function setNoveltyFitness()
	local file = io.open("Fitness.csv", "a")
	local nspCount = 0
  
	for loc,set in pairs(pool.landscape) do
		local count = 0
		for ga,value in pairs(set) do
        	count = inc(count)
		end
		if count <= tonumber(forms.gettext(noveltyConstantText)) then
			nspCount = inc(nspCount)
		 	for ga,value in pairs(set) do
        local group = math.floor(tonumber(ga) / 100)
        local marioAgent = tonumber(ga) % 100

				pool.groups[group].marioAgents[marioAgent].fitness = pool.groups[group].marioAgents[marioAgent].fitness + (tonumber((forms.gettext(noveltyConstantText)) - count) * tonumber(forms.gettext(noveltyWeight)))
			end
		end
	end
  
	file:write(pool.gen ..","..tostring(nspCount).. "\n")
	console.writeline("NSP: " .. nspCount)
	file:close()
end

--gain novelty fitness based on the location
function gainNoveltyFitness(location)
	if pool.gen > 0 then
		local count = 0
		if pool.oldLandscape[location] ~= nil then
			for key ,value in pairs(pool.oldLandscape[location]) do
        count = inc(count)
			end
		end
		if count <= tonumber(forms.gettext(noveltyConstantText)) then
			_currentNSFitness = inc(_currentNSFitness)
		end
	end
end

--finds the max fitness score for the generation
function findMaxFitnessForGen()
  local genDistanceFitness = 0
  local genMaxFitness = 0
  
  for n, groups in pairs(pool.groups) do
		for m,marioAgents in pairs(pool.groups.marioAgents) do
      
      if marioAgent.fitness > genMaxFitness then
				genMaxFitness = marioAgent.fitness
			end
			
			if marioAgent.distanceFitness > genDistanceFitness then
				genDistanceFitness = marioAgent.distanceFitness
			end
      
		end
	end
end
