curup = 0
maxup = 78
curcot = 0
curline = 0
maxcot = 20

repeat

  turtle.refuel(1)  


  curline = 0
  repeat
    curcot = 0
	repeat
	  if turtle.detect() then
	   turtle.dig()
	  end

	  turtle.forward()

	  curcot = curcot + 1
	until curcot == maxcot

	if curline % 2 == 0 then
	  if curup % 2 == 0 then
	    turtle.turnRight()
      else
        turtle.turnLeft()
	  end
	else
	  if curup % 2 == 0 then
        turtle.turnLeft()
	  else
        turtle.turnRight()
      end
	end
	  
	if turtle.detect() then
	  turtle.dig()
	end
	turtle.forward()
	if curline % 2 == 0 then
	  if curup % 2 == 0 then
	    turtle.turnRight()
      else
        turtle.turnLeft()
	  end
	else
	  if curup % 2 == 0 then
        turtle.turnLeft()
	  else
        turtle.turnRight()
      end
	end
	curline = curline + 1
  until curline == maxcot
  
  
  
  if (turtle.detectDown()) then  
    turtle.digDown()
  end

  turtle.down()
  curup = curup - 1
until curup == 0
