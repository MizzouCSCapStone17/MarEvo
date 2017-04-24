--get mario position
function getPositions()
    marioX = memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86)
    marioY = memory.readbyte(0x03B8) + 16
    
    screenX = memory.readbyte(0x03AD)
		screenY = memory.readbyte(0x03B8)
end

--gets tile used for input
function getTile(dx, dy)
    --distance plus what page they are on
    local x = marioX + dx + 8
    local y = marioY + dy - 16
    local page = math.floor(x / 256) % 2
    
    local subx = math.floor((x % 256) / 16)
    local suby = math.floor((y - 32) / 16)
    local addr = 0x500 + page * 13 * 16 + suby * 16 + subx
        
    if suby >= 13 or suby < 0 then
      return 0
    end
        
    if memory.readbyte(addr) ~= 0 then
      return 1
    else
      return 0
    end
end

--gets enemies if not in air
function getSprites()
    local sprites = {}
    for slot=0,4 do
      --read all slots to see if enemy is present (000F - 0012)
      local enemy = memory.readbyte(0xF+slot)
      if enemy ~= 0 then
        --enemy x and y and page it is on
        local ex = memory.readbyte(0x6E + slot)*0x100 + memory.readbyte(0x87+slot)
        local ey = memory.readbyte(0xCF + slot)+24
        --add enemy pose to list od sprites
        sprites[#sprites+1] = {["x"]=ex,["y"]=ey}
      end
    end
    return sprites
end

function getLevelInfo()
		marioLevel = memory.readbyte(0x0760)
		marioWorld = memory.readbyte(0x075F)
end

function getScore()
  marioScore = memory.readbyte(0x7D8)*100000 + memory.readbyte(0x07D9)*10000 + memory.readbyte(0x07DA)*1000 + memory.readbyte(0x07DB)*100 + memory.readbyte(0x07DC)*10 + memory.readbyte(0x07DC)*1
end

function getMarioState()
		-- 0x000E	Player's state
		local states = { 
			'Leftmost of screen',
			'Climbing vine',
			'Entering reversed-L pipe',
			'Going down a pipe',
			'Autowalk',
			'Autowalk',
			'Player dies',
			'Entering area',
			'Normal',
			'Cannot move',
			--' ',
			'Dying',
			'Palette cycling, can\'t move'
		}
		local stateCode = memory.readbyte(0xE)

		return states[stateCode]
	end

function getInputs()
    getPositions()
    
    sprites = getSprites()
    
    local inputs = {}
    
    --For disty from -16 times the box radius to 16 times the box radius incrementing by 16 and will loop box radius*2 times
    for dy=-_inputRadius*16,_inputRadius*16,16 do
        --same for x's
        for dx=-_inputRadius*16,_inputRadius*16,16 do
            --Set all inputs to 0
            inputs[#inputs+1] = 0
            
            tile = getTile(dx, dy)
            --if block at current location, set input to 1
            if tile == 1 and marioY+dy < 0x1B0 then
                inputs[#inputs] = 1
            end
            
            for i = 1,#sprites do
                --if enemy at currect location, set input to -1
                distx = math.abs(sprites[i]["x"] - (marioX+dx))
                disty = math.abs(sprites[i]["y"] - (marioY+dy))
                if distx <= 8 and disty <= 8 then
                    inputs[#inputs] = -1
                end
            end
        end
    end
    
    --mariovx = memory.read_s8(0x7B)
    --mariovy = memory.read_s8(0x7D)
    
    return inputs
end

function getCollision()
  local val = memory.readbyte(0x490)
  local collided = false
  if val == 255 then
    collided = false
  else
    collided = true
  end
end