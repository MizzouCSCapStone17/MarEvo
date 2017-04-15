--checks if a coordinate has been seen before by an agent
function marioTimeout()
  if marioX > rightmost then
    rightmost = marioX
    timeout = _timeoutConstant
  end
end