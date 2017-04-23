--checks if coordinate has not been seen by agent already
function noveltyTimeout()
	--Gain cordinates and species with hashes
	local location = math.floor(marioY / 64) * 10000 + memory.readbyte(0x6D) * 1000 + math.floor(memory.readbyte(0x86) / 64)
	local group = pool.currentGroup*100 + pool.currentMarioAgent

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
	--Gain cordinates and species with hashes
	local cordLocation = math.floor(marioY / 64) * 10000 + memory.readbyte(0x6D) * 1000 + math.floor(memory.readbyte(0x86) / 64)
	local cordGroup = pool.currentGroup * 100 + pool.currentMarioAgent

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
		--if forms.ischecked(distanceTimeout) then
			timeout = tonumber(forms.gettext(timeoutConstantText))
		--end
	end
end