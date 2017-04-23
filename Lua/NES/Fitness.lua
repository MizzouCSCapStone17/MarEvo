

--ranks all agents and determines one w/ highest fitness. higher rank = higher fitness
function rankGlobally()
    local global = {}
    for s = 1,#pool.group do
        local group = pool.group[s]
        for g = 1,#group.marioAgents do
            table.insert(global, group.marioAgents[g])
        end
    end
    table.sort(global, function (a,b)
        return (a.fitness < b.fitness)
    end)
    
    for g=1,#global do
        global[g].globalRank = g
    end
end

--determines if current agent has fitness measured
function fitnessAlreadyMeasured()
  local group = pool.group[pool.currentGroup]
  local marioAgent = group.marioAgents[pool.currentMarioAgent]
    
  return marioAgent.fitness ~= 0
end

--calculates avg fitness of a group by global rank added up divided by num of agents
function calculateAverageFitness(group)
    local total = 0
    
    for g=1,#group.marioAgents do
        local marioAgent = group.marioAgents[g]
        total = total + marioAgent.globalRank
    end
    
    group.averageFitness = total / #group.marioAgents
    
end

--total is sum of the total avg fitness for each group
function totalAverageFitness()
    local total = 0
    for s = 1,#pool.group do
        local group = pool.group[s]
        total = total + group.averageFitness
    end

    return total
end

function calculateTotalFitness()
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