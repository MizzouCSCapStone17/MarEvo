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

function calcTotalFitness()
  local distanceFitness = 0
  local scoreFitness = 0
  local noveltyFitness = 0
  local fitnesses = {0, 0, 0}
      
  distanceFitness = tonumber(forms.gettext(distanceWeight)) * (furthestDistance - netX)
  console.write("Distance: " .. distanceFitness .. "\n")
    
  scoreFitness = tonumber(forms.gettext(scoreWeight)) * (marioScore)
  console.write("Score: " .. scoreFitness .. "\n")
    
  noveltyFitness = tonumber(forms.gettext(noveltyWeight)) * (_currentNSFitness)
  console.write("Novelty: " .. noveltyFitness .. "\n")

  fitnesses[0] = distanceFitness
  fitnesses[1] = scoreFitness
  fitnesses[2] = noveltyFitness
      
    --table.sort(fitnesses)
  return fitnesses[0] + fitnesses[1] + fitnesses[2]
end