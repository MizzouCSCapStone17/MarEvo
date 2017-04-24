require "Globals"
require "NeuralNet"
require "IO"
require "Inputs"

function incX(amount)
    xval = xval + amount
    return xval
end

function incY(amount)
    yval = yval + amount
    return yval
end

function createForm(x, y, boxX, boxY)
  yval = 5
  xval = 5
    
  form = forms.newform(boxX, boxY, "MarEvo Settings"--[[onExit()]])
    
  --checkboxes to show the neural net and mutation rates of the agent
  showNeuralNet = forms.checkbox(form, "Show Neural Network", xval, yval)
  showMutationRates = forms.checkbox(form, "Show Mutations", incX(x), yval)
  yval = incY(y) 
  xval = 0
    
  --Labels to describe our different fitnes types
  typeLabel = forms.label(form, "Fitness Type:", xval, yval)
	weightLabel = forms.label(form, "Weight:", incX(x), yval)
  yval = incY(y) - 0.5 
  xval = 0
  
  --Distance Fitness options
  distanceLabel = forms.label(form, "Distance ", xval, yval)
	distanceWeight = forms.textbox(form, _distanceWeight, 60, 20, nil, incX(x), yval)
  yval = incY(y) 
  xval = 0
  
  --Novelty Fitness Options
  noveltyLabel = forms.label(form, "Novelty ", xval, yval)
	noveltyWeight = forms.textbox(form, _noveltyWeight, 60, 20, nil, incX(x), yval)
  yval = incY(y) 
  xval = 0
  
  --Score Fitness
  scoreLabel = forms.label(form, "Score ", xval, yval)
	scoreWeight = forms.textbox(form, _scoreWeight, 60, 20, nil, incX(x), yval)
  yval = incY(y) 
  xval = 0
  
  --Novelty Constants
  noveltyConstantLabel = forms.label(form, "Novelty Constant: ", xval, yval)
	noveltyConstantText = forms.textbox(form, _noveltyConstant, 30, 20, nil, incX(x), yval)
  yval = incY(y) 
  xval = 0
  
  --Timeout constants
	timeoutConstantLabel = forms.label(form, "Timeout Constant: ", xval, yval)
	timeoutConstantText = forms.textbox(form, _timeoutConstant, 30, 20, nil, incX(x), yval) 
  yval = incY(y) 
  xval = 0
  
  --saves ethe neural network and pool
  saveButton = forms.button(form, "Save", savePool, xval, yval)
  --loads the neural network and pool
  loadButton = forms.button(form, "Load", loadPool, incX(x), yval)
  --Restart the training
  restartButton = forms.button(form, "Restart", initializePool, incX(x), yval)
  yval=incY(y) 
  xval=0
    
  saveLoadLabel = forms.label(form, "Save/Load:", xval, yval)
  saveLoadFile = forms.textbox(form, ".pool", 110, 25, nil, incX(x), yval)
  yval=incY(y) 
  xval=0
    
  playMaxButton = forms.button(form, "Play Max Agent", playMaxAgent, xval, yval)
end

function playMaxAgent()
	local maxFitness = 0
	local maxG, maxA
	for g,group in pairs(pool.group) do
		for a,marioAgent in pairs(group.marioAgents) do
			if marioAgent.fitness > maxFitness then
				maxFitness = marioAgent.fitness
				maxG = g
				maxA = a
			end
		end
	end
	
	pool.currentGroup = maxG
	pool.currentMarioAgent = maxA
	pool.maxFitness = maxFitness
	--forms.settext(maxFitnessLabel, "Max Fitness: " .. math.floor(pool.maxFitness))
	initializeRun()
	pool.currentFrame = pool.currentFrame + 1
	return
end

function displayMutationRates(marioAgent)
  local pos = 40
  for mutation,rate in pairs(marioAgent.mutationRates) do
    gui.drawText(130, pos, mutation .. ": " .. rate, 0xFFFFFFFF, nil, 10)
    pos = pos + 10
  end
end

function displayNetwork(marioAgent)
    local nn = marioAgent.nn
    local cells = {}
    local i = 1
    local cell = {}
    --finds all visible cells
    for dy=-_inputRadius,_inputRadius do
        for dx=-_inputRadius,_inputRadius do
            cell = {}
            cell.x = 120+16*dx
            cell.y = 184+16*dy
            cell.value = nn.neurons[i].value
            cells[i] = cell
            i = i + 1
        end
    end
    --dinds the bias cell
    local biasCell = {}
    biasCell.x = 5
    biasCell.y = 150
    biasCell.value = nn.neurons[_inputs].value
    cells[_inputs] = biasCell
    
    gui.drawIcon('controller.ico', 0, 0, 160, 128)
    
    --draws all outputs onto controller
    for o = 1,_outputs do
        cell = {}
        if o == 1 then
          cell.x = 90
          cell.y = 72
        elseif o == 2 then
          cell.x = 106
          cell.y = 72
        elseif o == 3 then
          cell.x = 20
          cell.y = 60
        elseif o == 4 then
          cell.x = 20
          cell.y = 80
        elseif o == 5 then
          cell.x = 8
          cell.y = 68
        else
          cell.x = 34
          cell.y = 68
        end
        --cell.x = 10 + 16 * o
        --cell.y = 60
        cell.value = nn.neurons[_maxNodes + o].value
        cells[_maxNodes+o] = cell
        local color
        if cell.value > 0 then
            color = 0xFF00FF00
        else
            color = 0xFFFFFFFF
        end
    end
    
    --finds cells of all neurons
    for n,neuron in pairs(nn.neurons) do
        cell = {}
        if n > _inputs and n <= _maxNodes then
            cell.x = 140
            cell.y = 40
            cell.value = neuron.value
            cells[n] = cell
        end
    end
    
    --finds lines between input,output,and hidden nodes
    for n=1,4 do
        for _,trait in pairs(marioAgent.traits) do
            if trait.enabled then
                local c1 = cells[trait.into]
                local c2 = cells[trait.out]
                if trait.into > _inputs and trait.into <= _maxNodes then
                    c1.x = 0.75*c1.x + 0.25*c2.x
                    if c1.x >= c2.x then
                        c1.x = c1.x - 40
                    end
                    if c1.x < 90 then
                        c1.x = 90
                    end
                    
                    if c1.x > 220 then
                        c1.x = 220
                    end
                    c1.y = 0.75*c1.y + 0.25*c2.y
                    
                end
                if trait.out > _inputs and trait.out <= _maxNodes then
                    c2.x = 0.25*c1.x + 0.75*c2.x
                    if c1.x >= c2.x then
                        c2.x = c2.x + 40
                    end
                    if c2.x < 90 then
                        c2.x = 90
                    end
                    if c2.x > 220 then
                        c2.x = 220
                    end
                    c2.y = 0.25*c1.y + 0.75*c2.y
                end
            end
        end
    end
    
    --draws all cells
    for n,cell in pairs(cells) do
        if n > _inputs or cell.value ~= 0 then
            local color = math.floor((cell.value+1)/2*256)
            if color > 255 then color = 255 end
            if color < 0 then color = 0 end
            local opacity = 0xFF000000
            if cell.value == 0 then
                opacity = 0x50000000
            end
            color = opacity + color*0x10000 + color*0x100 + color
            gui.drawBox(cell.x-8,cell.y-8,cell.x+8,cell.y+8,opacity,color)
        end
    end
    
    --draws all lines
    for _,trait in pairs(marioAgent.traits) do
        if trait.enabled then
            local c1 = cells[trait.into]
            local c2 = cells[trait.out]
            local opacity = 0xA0000000
            if c1.value == 0 then
                opacity = 0x20000000
            end
            
            local color = 0x80-math.floor(math.abs(sigmoid(trait.weight))*0x80)
            if trait.weight > 0 then 
                color = opacity + 0x8000 + 0x10000*color
            else
                color = opacity + 0x800000 + 0x100*color
            end
            gui.drawLine(c1.x+1, c1.y, c2.x-3, c2.y, color)
        end
    end
    --[[
        local pos = 50
        for mutation,rate in pairs(marioAgent.mutationRates) do
            gui.drawText(80, pos, mutation .. ": " .. rate, 0xFF000000, 10)
            pos = pos + 8
        end
      ]]
end