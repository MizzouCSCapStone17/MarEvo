--trys random types of mutation on an agent
function mutate(marioAgent)
    for mutation,rate in pairs(marioAgent.mutationRates) do
        if math.random(1,2) == 1 then
            --randomly increare/decrease all mutation types
            marioAgent.mutationRates[mutation] = 0.95*rate
        else
            marioAgent.mutationRates[mutation] = 1.05263*rate
        end
    end
    
    --point mutate if connections chance greater than rand
    if math.random() < marioAgent.mutationRates["connections"] then
        pointMutate(marioAgent)
    end
    
    --link mutate w/ bias if greater than link rate
    local p = marioAgent.mutationRates["link"]
    while p > 0 do
        if math.random() < p then
            linkMutate(marioAgent, false)
        end
        p = p - 1
    end

    --link mutate w/ bias if greater than bias rate
    p = marioAgent.mutationRates["bias"]
    while p > 0 do
        if math.random() < p then
            linkMutate(marioAgent, true)
        end
        p = p - 1
    end
    
    --node mutate if greater than node rate
    p = marioAgent.mutationRates["node"]
    while p > 0 do
        if math.random() < p then
            nodeMutate(marioAgent)
        end
        p = p - 1
    end
    
    p = marioAgent.mutationRates["enable"]
    while p > 0 do
        if math.random() < p then
            enableDisableMutate(marioAgent, true)
        end
        p = p - 1
    end

    p = marioAgent.mutationRates["disable"]
    while p > 0 do
        if math.random() < p then
            enableDisableMutate(marioAgent, false)
        end
        p = p - 1
    end
end

--sees if link alreadt exists
function containsLink(traits, link)
    for i=1,#traits do
        local trait = traits[i]
        if trait.into == link.into and trait.out == link.out then
            return true
        end
    end
end

--the connection mutation rate for each trait changes the weight for mutation
function pointMutate(marioAgent)
    local step = marioAgent.mutationRates["step"]
    
    for i=1,#marioAgent.traits do
        local trait = marioAgent.traits[i]
        if math.random() < _perturbChance then
            --increase by step size
            trait.weight = trait.weight + math.random() * step*2 - step
        else
            --redo the mutation
            trait.weight = math.random()*4-2
        end
    end
end

--set one agent as input and one agent as output for new trait
function linkMutate(marioAgent, forceBias)
    --random neuron
    local neuron1 = randomNeuron(marioAgent.traits, false)
    --random input neuron
    local neuron2 = randomNeuron(marioAgent.traits, true)
     
    local newLink = newTrait()
    if neuron1 <= _inputs and neuron2 <= _inputs then
        --Both input nodes
        return
    end
    if neuron2 <= _inputs then
        -- Swap output and input
        local temp = neuron1
        neuron1 = neuron2
        neuron2 = temp
    end

    newLink.into = neuron1
    newLink.out = neuron2
    if forceBias then
        newLink.into = _inputs
    end
    
    if containsLink(marioAgent.traits, newLink) then
        return
    end
    newLink.innovation = newInnovation()
    newLink.weight = math.random()*4-2
    
    table.insert(marioAgent.traits, newLink)
end

--node mutation needed by link and bias mutation
function nodeMutate(marioAgent)
    if #marioAgent.traits == 0 then
        return
    end
    
    marioAgent.maxNeuron = marioAgent.maxNeuron + 1

    --get random trait in list of trait for agent
    local trait = marioAgent.traits[math.random(1,#marioAgent.traits)]
    if not trait.enabled then
        return
    end
    --disable the trait
    trait.enabled = false
    
    --copy trait and output to end
    local trait1 = copyTrait(trait)
    trait1.out = marioAgent.maxNeuron
    trait1.weight = 1.0
    trait1.innovation = newInnovation()
    trait1.enabled = true
    table.insert(marioAgent.traits, trait1)
    
    --copy trait and set input to end
    local trait2 = copyTrait(trait)
    trait2.into = marioAgent.maxNeuron
    trait2.innovation = newInnovation()
    trait2.enabled = true
    table.insert(marioAgent.traits, trait2)
end

--enable/diable trait for an agent
function enableDisableMutate(marioAgent, enable)
    local candidates = {}
    for _,trait in pairs(marioAgent.traits) do
        if trait.enabled == not enable then
            table.insert(candidates, trait)
        end
    end
    
    if #candidates == 0 then
        return
    end
    
    local trait = candidates[math.random(1,#candidates)]
    trait.enabled = not trait.enabled
end