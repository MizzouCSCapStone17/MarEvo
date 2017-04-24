require "Globals"
require "Inputs"
require "IO"
require "Form"
require "Fitness"
require "Timeout"
require "Mutate"
require "NeuralNet"

createForm(140,40,375,450)

if pool == nil then
    initPool()
end

--Begin the infinte fitness loop
while true do  
    
  gui.drawBox(0, 0, 300, 40, 0xFFFFFFFF, 0xFFFFFFFF)
  
  --Get current group and agent
  local group = pool.groups[pool.currGroup]
  local marioAgent = group.marioAgents[pool.currMarioAgent]
    
  --Displays the network for the current agent
  if forms.ischecked(showNeuralNet) then
    displayNetwork(marioAgent)
  end
  --Displays the muatation rates for the current agent
  if forms.ischecked(showMutationRates) then
    displayMutationRates(marioAgent)
  end
  
  --Evaulate the current agent every 4 frames
  if pool.currFrame % 4 == 0 then
    evalCurrentMarioAgent()
  end
    
  --Set the output based on what network picks
  joypad.set(controller, 1)
    
  getPositions()
  getLevelInfo()
  getScore()
  marioState = getMarioState()
	local marioDead = marioState == 'Dying' or marioState == 'Player dies'
    
  --refresh timeout
  if pool.currFrame % 3 == 0 then
    noveltyTimeoutFunction()
    marioTimeoutFunction()
  end
  timeout = timeout - 1
    
  --give a living bonus based on every 3 frames
  local timeoutBonus = pool.currFrame / 3
    
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
    
    distanceFitness = tonumber(forms.gettext(distanceWeight)) * ((furthestDistance - netX) - pool.currFrame / 2) * (math.random(8, 12) / 10)
    console.write("Distance: " .. distanceFitness .. "\n")
    scoreFitness = tonumber(forms.gettext(scoreWeight)) * (marioScore) * (math.random(8, 12) / 10)
    console.write("Score: " .. scoreFitness .. "\n")
    noveltyFitness = tonumber(forms.gettext(noveltyWeight)) * (_currentNSFitness)
    console.write("Novelty: " .. noveltyFitness .. "\n")
    
    fitness = distanceFitness + scoreFitness + noveltyFitness
    --fitness = calcTotalFitness()
    
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
      
    console.write("Gen " .. pool.gen .. ". Group " .. pool.currGroup .. ". Agent " .. pool.currMarioAgent .. ". Fitness: " .. fitness .. "\n")
      
    pool.currGroup = 1
    pool.currMarioAgent = 1
      
    while marioAgentRan() do
      findNextMarioAgent()
    end
        
    initRun()
  end
    
  --the agents that have already run
  local percentCompleteWithGen = percentCompleted()
  
  gui.drawText(110, 5, "MarEvo", 0xFF000000, 11, 14)
  gui.drawText(0, 20, "Gen: " .. pool.gen .. " || Group: " .. pool.currGroup .. " || Agent: " .. pool.currMarioAgent .. " || " .. percentCompleteWithGen .. " %", 0xFF000000, 11, 10)
  
  distanceFitness = tonumber(forms.gettext(distanceWeight)) * ((furthestDistance - netX) - pool.currFrame / 2) * (math.random(8, 12) / 10)
  scoreFitness = tonumber(forms.gettext(scoreWeight)) * (marioScore) * (math.random(8, 12) / 10)
  noveltyFitness = tonumber(forms.gettext(noveltyWeight)) * (_currentNSFitness)
  fitness = math.floor(distanceFitness + scoreFitness + noveltyFitness)
  --temp_fitness = calcTotalFitness()
  
  gui.drawText(0, 30, "Fitness: " .. fitness .. " || Max Fitness: " .. math.floor(pool.maxFitness), 0xFF000000, 11, 10)
    
  --update frame our way
  pool.currFrame = pool.currFrame + 1
    
  --update frame actually with the emulator
  emu.frameadvance();
end
  
      