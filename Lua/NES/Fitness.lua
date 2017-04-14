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