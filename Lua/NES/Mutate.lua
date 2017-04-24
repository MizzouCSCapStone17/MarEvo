--trys random types of mutation on an agent
function mutate(marioAgent)
  local p = 0
  
  for m,r in pairs(marioAgent.mutationRates) do
    if math.random(1,2) == 1 then
      --randomly increare/decrease all mutation types
      marioAgent.mutationRates[m] = 1.05263*r
    else
      marioAgent.mutationRates[m] = 0.95*r
    end
  end
    
  --point mutate if connections chance greater than rand
  if math.random() < marioAgent.mutationRates["connections"] then
    pointMutation(marioAgent)
  end
  
  p = marioAgent.mutationRates["enable"]
  while p > 0 do
    if math.random() < p then
      enableDisableMutation(marioAgent, true)
    end
    p = p - 1
  end

  p = marioAgent.mutationRates["disable"]
  while p > 0 do
    if math.random() < p then
      enableDisableMutation(marioAgent, false)
    end
    p = p - 1
  end
  
  --link mutate w/ bias if greater than bias rate
  p = marioAgent.mutationRates["bias"]
  while p > 0 do
    if math.random() < p then
      linkMutation(marioAgent, true)
    end
    p = p - 1
  end
    
  --link mutate w/ bias if greater than link rate
  p = marioAgent.mutationRates["link"]
  while p > 0 do
    if math.random() < p then
      linkMutation(marioAgent, false)
    end
    p = p - 1
  end
    
  --node mutate if greater than node rate
  p = marioAgent.mutationRates["node"]
  while p > 0 do
    if math.random() < p then
      nodeMutation(marioAgent)
    end
    p = p - 1
  end
end

--sees if link alreadt exists
function containsLink(traits, link)
  for t = 1, #traits do
    local trait = traits[t]
    if trait.inn == link.inn and trait.out == link.out then
      return true
    end
  end
end

--enable/diable trait for an agent
function enableDisableMutation(marioAgent, enable)
  local candidateTraits = {}
  local n = 0
  
  for _,trait in pairs(marioAgent.traits) do
    if trait.enabled == not enable then
      table.insert(candidateTraits, trait)
    end
  end
    
  if #candidateTraits == 0 then
    return
  end
  
  n = #candidateTraits
  local trait = candidateTraits[math.random(1,n)]
  trait.enabled = not trait.enabled
end

--the connection mutation rate for each trait changes the weight for mutation
function pointMutation(marioAgent)
  local stepSize = marioAgent.mutationRates["step"]
    
  for t = 1, #marioAgent.traits do
    local trait = marioAgent.traits[t]
    if math.random() < _perturbChance then
      --increase by step size
      trait.weight = trait.weight + math.random() * stepSize*2 - stepSize
    else
      --redo the mutation
      trait.weight = math.random()*4-2
    end
  end
end

--set one agent as input and one agent as output for new trait
function linkMutation(marioAgent, forceBias)
  --random neuron
  local tempNeuron = randomNeuron(marioAgent.traits, false)
  --random input neuron
  local tempNeuron2 = randomNeuron(marioAgent.traits, true)
  local newLink = newTrait()
  
  if tempNeuron <= _inputs and tempNeuron2 <= _inputs then
    --Both input nodes
    return
  end
  if tempNeuron2 <= _inputs then
    -- Swap output and input
    local temp = tempNeuron
    tempNeuron = tempNeuron2
    tempNeuron2 = temp
  end

  newLink.inn = tempNeuron
  newLink.out = tempNeuron2
  
  if forceBias then
    newLink.inn = _inputs
  end
  
  if containsLink(marioAgent.traits, newLink) then
    return
  end
  
  newLink.modernization = newModernization()
  newLink.weight = math.random()*4-2
    
  table.insert(marioAgent.traits, newLink)
end

--node mutation needed by link and bias mutation
function nodeMutation(marioAgent)
  if #marioAgent.traits == 0 then
    return
  end
    
  marioAgent.maxNeurons = marioAgent.maxNeurons + 1

  --get random trait in list of trait for agent
  local trait = marioAgent.traits[math.random(1,#marioAgent.traits)]
  if not trait.enabled then
    return
  end
  --disable the trait
  trait.enabled = false
    
  --copy trait and output to end
  local tempTrait = copyTrait(trait)
  tempTrait.enabled = true
  tempTrait.out = marioAgent.maxNeurons
  tempTrait.weight = 1.0
  tempTrait.modernization = newModernization()
  table.insert(marioAgent.traits, tempTrait)
    
  --copy trait and set input to end
  local tempTrait2 = copyTrait(trait)
  tempTrait2.enabled = true
  tempTrait2.inn = marioAgent.maxNeurons
  tempTrait2.modernization = newModernization()
  table.insert(marioAgent.traits, tempTrait2)
end
