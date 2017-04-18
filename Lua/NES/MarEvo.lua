require "Globals"
require "Inputs"
require "IO"
require "Form"
require "Fitness"
require "Timeout"
require "Mutate"
require "NeuralNet"

createForm(140,40,400,200)

if pool == nil then
    initializePool()
end


--event.onexit(onExit())

--Begin the infinte fitness loop
while true do
  --collision = memory.readbyte(0x490)
  --gui.text(0,140,collision)
    
  gui.drawBox(0, 0, 300, 50, 0xFFFFFFFF, 0xFFFFFFFF)
  
  --Get current group and agent
  local group = pool.group[pool.currentGroup]
  local marioAgent = group.marioAgents[pool.currentMarioAgent]
    
  --Displays the network for the current agent
  if forms.ischecked(showNeuralNet) then
    displayMarioAgent(marioAgent)
  end
    
  --marioScore = getMarioScore()
  --gui.text(0, 150, "Mario has score " .. marioScore)
    
  --if we can currently in play (not at loading screen/mario dead/etc)
  --if(playing()) then
    --Evaulate the current agent every 4 frames
    if pool.currentFrame%4 == 0 then
      evaluateCurrent()
    end
    
    --Set the output based on what network picks
    joypad.set(controller, 1)
    
    getPositions()
    getLevelInfo()
    
    --refresh timeout
    if pool.currentFrame%3 == 0 then
      marioTimeout()
    end
    timeout = timeout - 1
    
    --give a timeout/living bonus based on every 4 frames
    local timeoutBonus = pool.currentFrame / 4
    
    --if agent did not finish within the timeout, end the run
    if timeout + timeoutBonus <= 0 or math.floor(rightmost - (pool.currentFrame) / 2 - (timeout + timeoutBonus)*2/3) + (marioScore / 10) < -200 then
      local fitness = (rightmost - pool.currentFrame / 2) + (marioScore / 15)
      if rightmost > 3186 then
        fitness = fitness + 1000
      end
      if fitness == 0 then
        fitness = -1
      end
      marioAgent.fitness = fitness
        
      if fitness > pool.maxFitness then
        pool.maxFitness = fitness
        writeFile("Pools/gen" .. pool.generation .. "." .. marioWorld .. "-".. marioLevel .. ".pool")
      end
        
      console.write("Gen " .. pool.generation .. ". Group " .. pool.currentGroup .. ". Agent " .. pool.currentMarioAgent .. ". Fitness: " .. fitness .. "\n")
      
      pool.currentGroup = 1
      pool.currentMarioAgent = 1
      
      while fitnessAlreadyMeasured() do
        nextMarioAgent()
      end
        
      initializeRun()
    end
    
    --count all the agents that have already run
    local measured = 0
    local total = 0
    for _,group in pairs(pool.group) do
      for _,marioAgent in pairs(group.marioAgents) do
        total = total + 1
        if marioAgent.fitness ~= 0 then
          measured = measured + 1
        end
      end
    end
    gui.drawText(110, 5, "MarEvo", 0xFF000000, 11)
    gui.drawText(0, 20, "Gen: " .. pool.generation .. " || Agent: " .. pool.currentMarioAgent .. " || " .. math.floor(measured/total*100) .. " %", 0xFF000000, 11)
    gui.drawText(0, 30, "Fitness: " .. math.floor(rightmost - (pool.currentFrame) / 2 - (timeout + timeoutBonus)*2/3) + (marioScore / 10) .. " || Max Fitness: " .. math.floor(pool.maxFitness), 0xFF000000, 11)
    
    --update frame our way
    pool.currentFrame = pool.currentFrame + 1
    
    --update frame actually with the emulator
    emu.frameadvance();
  --end
end

