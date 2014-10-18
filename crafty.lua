while true do
	while turtle.getItemCount(5) < 1 do
		turtle.select(5)
		turtle.suckUp()
	end
	while turtle.getItemCount(6) < 1 do
		turtle.select(6)
		turtle.suckUp()
	end
	while turtle.getItemCount(9) < 1 do
		turtle.select(9)
		turtle.suckUp()
	end
	while turtle.getItemCount(10) < 1 do
		turtle.select(10)
		turtle.suckUp()
	end
	turtle.select(16)
	while turtle.craft() do
		print("crafted")
	end
	turtle.drop()
end
