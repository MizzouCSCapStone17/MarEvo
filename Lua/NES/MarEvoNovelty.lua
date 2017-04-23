require "Globals"
require "Inputs"
require "IO"
require "Form"
require "Fitness"
require "Timeout"
require "Mutate"
require "NeuralNet"

createForm(140,40,375,400)

if pool == nil then
    initializePool()
end

--Begin the infinte fitness loop
while true do  
    
  gui.drawBox(0, 0, 300, 40, 0xFFFFFFFF, 0xFFFFFFFF)
  
  --Get current group and agent
  local group = pool.group[pool.currentGroup]
  local marioAgent = group.marioAgents[pool.currentMarioAgent]
    
  --Displays the network for the current agent
  if forms.ischecked(showNeuralNet) then
    displayNetwork(marioAgent)
  end
  --Displays the muatation rates for the current agent
  if forms.ischecked(showMutationRates) then
    displayMutationRates(marioAgent)
  end
  
  --Evaulate the current agent every 4 frames
  if pool.currentFrame % 4 == 0 then
    evaluateCurrent()
  end
    
  --Set the output based on what network picks
  joypad.set(controller, 1)
    
  getPositions()
  getLevelInfo()
  getScore()
  marioState = getMarioState()
	local marioDead = marioState == 'Dying' or marioState == 'Player dies'
    
  --refresh timeout
  if pool.currentFrame % 3 == 0 then
    noveltyTimeoutFunction()
    marioTimeoutFunction()
  end
  timeout = timeout - 1
    
  --give a living bonus based on every 3 frames
  local timeoutBonus = pool.currentFrame / 3
    
  timeoutTotal = timeout + timeoutBonus
    
  --if agent has timed out or died
  if timeoutTotal <= 0 or _autoTimeout == true or marioDead then
    _autoTimeout = false
    local distanceFitness = 0
    local scoreFitness = 0
    local noveltyFitness = 0
    local fitness = 0
    --local fitnesses = {0, 0, 0}
      
    marioAgent.ran = true
    
    distanceFitness = tonumber(forms.gettext(distanceWeight)) * ((furthestDistance - netX) - pool.currentFrame / 2)
    console.write("Distance: " .. distanceFitness .. "\n")
    scoreFitness = tonumber(forms.gettext(scoreWeight)) * (marioScore)
    console.write("Score: " .. scoreFitness .. "\n")
    noveltyFitness = tonumber(forms.gettext(noveltyWeight)) * (_currentNSFitness)
    console.write("Novelty: " .. noveltyFitness .. "\n")
    
    fitness = distanceFitness + scoreFitness + noveltyFitness
    --fitness = calculateTotalFitness()
    
    --bonus for finishing the level
    if furthestDistance > 3186 then
      fitness = fitness + 1000
    end
    if fitness <= 0 then
      fitness = math.random(-100,-1)
    end
    if _noFitness == true then
      fitness = fitness - math.random(20,40)
    end
      
    marioAgent.fitness = fitness
      
    if fitness > pool.maxFitness then
      pool.maxFitness = fitness
      writeFile("Pools/maxFitnessGen." .. marioWorld .. "-".. marioLevel .. ".pool")
    end
      
    console.write("Gen " .. pool.generation .. ". Group " .. pool.currentGroup .. ". Agent " .. pool.currentMarioAgent .. ". Fitness: " .. fitness .. "\n")
      
    pool.currentGroup = 1
    pool.currentMarioAgent = 1
      
    while agentAlreadyRan() do
      nextMarioAgent()
    end
        
    initializeRun()
  end
    
  --the agents that have already run
  local percentCompleteWithGen = percentCompleted()
  
  gui.drawText(110, 5, "MarEvo", 0xFF000000, 11, 14)
  gui.drawText(0, 20, "Gen: " .. pool.generation .. " || Group: " .. pool.currentGroup .. " || Agent: " .. pool.currentMarioAgent .. " || " .. percentCompleteWithGen .. " %", 0xFF000000, 11, 10)
  
  distanceFitness = tonumber(forms.gettext(distanceWeight)) * ((furthestDistance - netX) - pool.currentFrame / 2)
  scoreFitness = tonumber(forms.gettext(scoreWeight)) * (marioScore)
  noveltyFitness = tonumber(forms.gettext(noveltyWeight)) * (_currentNSFitness)
  fitness = distanceFitness + scoreFitness + noveltyFitness
  --temp_fitness = calculateTotalFitness()
  
  gui.drawText(0, 30, "Fitness: " .. fitness .. " || Max Fitness: " .. math.floor(pool.maxFitness), 0xFF000000, 11, 10)
    
  --update frame our way
  pool.currentFrame = pool.currentFrame + 1
    
  --update frame actually with the emulator
  emu.frameadvance();
end
  
      