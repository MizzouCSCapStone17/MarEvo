require "Globals"
require "Inputs"
require "IO"
require "Fitness"
require "Mutate"
require "NeuralNet"


--Begin the infinte fitness loop
while true do
    --collision = memory.readbyte(0x490)
    --gui.text(0,140,collision)
  
    --Get current group and agent
    local group = pool.group[pool.currentGroup]
    local marioAgent = group.marioAgents[pool.currentMarioAgent]
    
    --Displays the network for the current agent
    displayMarioAgent(marioAgent)
    
    --marioScore = getMarioScore()
    --gui.text(0, 150, "Mario has score " .. marioScore)
    
    --Evaulate the current agent every 5 frames
    if pool.currentFrame%5 == 0 then
        evaluateCurrent()
    end
    
    --Set the output based on what network picks
    joypad.set(controller, 1)
    
    
    getPositions()
    if marioX > rightmost then
        rightmost = marioX
        timeout = _timeoutConstant
    end
    
    timeout = timeout - 1
    
    local timeoutBonus = pool.currentFrame / 4
    
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
            --writeFile("mybackup." .. pool.generation .. "." .. forms.gettext(saveLoadFile))
        end
        
        console.write("Gen " .. pool.generation .. ". Group " .. pool.currentGroup .. ". Agent " .. pool.currentMarioAgent .. ". Fitness: " .. fitness .. "\n")
        pool.currentGroup = 1
        pool.currentMarioAgent = 1
        while fitnessAlreadyMeasured() do
            nextMarioAgent()
        end
        
        initializeRun()
    end

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
    
    gui.text(0, 410, "Gen: " .. pool.generation .. " || Group: " .. pool.currentGroup .. " || Agent: " .. pool.currentMarioAgent .. " || Measured: " .. math.floor(measured/total*100) .. " %")
        gui.text(0, 420, "Fitness: " .. math.floor(rightmost - (pool.currentFrame) / 2 - (timeout + timeoutBonus)*2/3) + (marioScore / 10) .. " || Max Fitness: " .. math.floor(pool.maxFitness))
    
    pool.currentFrame = pool.currentFrame + 1
  
    emu.frameadvance();
end

