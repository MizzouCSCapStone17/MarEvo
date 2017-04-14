function getPositions()
  marioX = memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86)
  marioY = memory.readbyte(0x03B8)+16
    
  screenX = memory.readbyte(0x03AD)
  screenY = memory.readbyte(0x03B8)
end


function getTile(dx, dy)
  local x = marioX + dx + 8
  local y = marioY + dy - 16
  local page = math.floor(x/256)%2

  local subx = math.floor((x%256)/16)
  local suby = math.floor((y - 32)/16)
  local addr = 0x500 + page*13*16+suby*16+subx
        
  if suby >= 13 or suby < 0 then
    return 0
  end
        
  if memory.readbyte(addr) ~= 0 then
    return 1
  else
    return 0
  end
end


function getSprites()
  local sprites = {}
  for slot=0,4 do
    local enemy = memory.readbyte(0xF+slot)
    if enemy ~= 0 then
      local ex = memory.readbyte(0x6E + slot)*0x100 + memory.readbyte(0x87+slot)
      local ey = memory.readbyte(0xCF + slot)+24
      sprites[#sprites+1] = {["x"]=ex,["y"]=ey}
    end
  end
      
  return sprites
end

function getExtendedSprites()
  return {}
end

function getMarioScore()
    -- 0x07DD-0x07E2	Mario score (1000000 100000 10000 1000 100 10)
    local addresses = { 0x7DD, 0x7DE, 0x7DF, 0x7E0, 0x7E1, 0x7E2 }
    local scores = { 1000000, 100000, 10000, 1000, 100, 10 }
    local score = 0
    -- FIXME!
    for i = 1, table.getn(addresses) do
        score = score + (scores[i] * memory.readbyte(addresses[i]))
    end

    return score
end

function getInputs()
    getPositions()
    
    sprites = getSprites()
    extended = getExtendedSprites()
    
    local inputs = {}
    
    for dy=-_boxRadius*16,_boxRadius*16,16 do
        for dx=-_boxRadius*16,_boxRadius*16,16 do
            inputs[#inputs+1] = 0
            
            tile = getTile(dx, dy)
            if tile == 1 and marioY+dy < 0x1B0 then
                inputs[#inputs] = 1
            end
            
            for i = 1,#sprites do
                distx = math.abs(sprites[i]["x"] - (marioX+dx))
                disty = math.abs(sprites[i]["y"] - (marioY+dy))
                if distx <= 8 and disty <= 8 then
                    inputs[#inputs] = -1
                end
            end

            for i = 1,#extended do
                distx = math.abs(extended[i]["x"] - (marioX+dx))
                disty = math.abs(extended[i]["y"] - (marioY+dy))
                if distx < 8 and disty < 8 then
                    inputs[#inputs] = -1
                end
            end
        end
    end
    
    --mariovx = memory.read_s8(0x7B)
    --mariovy = memory.read_s8(0x7D)
    
    return inputs
end