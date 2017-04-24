--checks if coordinate has not been seen by agent already
function noveltyTimeout()
  local location = 0
  local group = 0
	
  --Gain cordinates and species with hashes
	location = math.floor(marioY / 64) * 10000 + memory.readbyte(0x6D) * 1000 + math.floor(memory.readbyte(0x86) / 64)
	group = pool.currGroup*100 + pool.currMarioAgent

	if pool.landscape[tostring(location)] == nil then
		pool.landscape[tostring(location)] = {}
	end

	if not pool.landscape[tostring(location)][tostring(group)] == true then
		pool.landscape[tostring(location)][tostring(group)] = true
    
    timeout = _timeoutConstant
    
    gainNoveltyFitness(tostring(location))
	end
end

function noveltyTimeoutFunction()
  local cordLocation = 0
  local cordGroup = 0
	--Gain cordinates and species with hashes
	cordLocation = math.floor(marioY / 64) * 10000 + memory.readbyte(0x6D) * 1000 + math.floor(memory.readbyte(0x86) / 64)
	cordGroup = pool.currGroup * 100 + pool.currMarioAgent

	if pool.landscape[tostring(cordLocation)] == nil then
		pool.landscape[tostring(cordLocation)] = {}
	end

	if not pool.landscape[tostring(cordLocation)][tostring(cordGroup)] == true then
		pool.landscape[tostring(cordLocation)][tostring(cordGroup)] = true
		--if forms.ischecked(noveltyTimeout) then
			timeout = tonumber(forms.gettext(timeoutConstantText))
			gainNoveltyFitness(tostring(cordLocation))
		--end
	end
end

function marioTimeoutFunction()
	if marioX > furthestDistance then
		furthestDistance = marioX
    timeout = tonumber(forms.gettext(timeoutConstantText))
	end
end