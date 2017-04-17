--checks if a coordinate has been seen before by an agent
function marioTimeout()
  if marioX > rightmost then
    rightmost = marioX
    timeout = _timeoutConstant
  end
end

--checks if coordinate has not been seen by agent already
function noveltyTimeout()
	--Gain cordinates and species with hashes
	local location = math.floor(marioY/64)*10000+memory.readbyte(0x6D) * 1000 + math.floor(memory.readbyte(0x86)/64)
	local group = pool.currentGroup*100 + pool.currentMarioAgent

	if pool.landscape[tostring(location)]==nil then
		pool.landscape[tostring(location)]={}
	end

	if not pool.landscape[tostring(location)][tostring(group)]==true then
		pool.landscape[tostring(location)][tostring(group)]=true
    
    timeout = _timeoutConstant
    
    GainNoveltyFitness(tostring(location))
	end
end