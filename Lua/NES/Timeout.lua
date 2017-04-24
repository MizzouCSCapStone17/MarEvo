--checks if coordinate has not been seen by agent already
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

--checks if mario has not improved distance
function marioTimeoutFunction()
	if marioX > furthestDistance then
		furthestDistance = marioX
    timeout = tonumber(forms.gettext(timeoutConstantText))
	end
end