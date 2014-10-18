local side = "left"
local password = "quiche"

while true do 
	term.clear()
	term.setCursorPos(1,1)
	write("Password: ")
	local input = read("*")

	if input == password then
		term.clear()
		term.setCursorPos(1,1)

		print("Yipee !")
		rs.setOutput(side,true)

		local stay_open = true
		while stay_open do
			write("\nRefermer la porte ? (oui/non)\n")

			if read() == "oui" then
				write("On ferme !")
				sleep(1)
				stay_open = false
			end
			term.clear()
			term.setCursorPos(1,1)
		end
		rs.setOutput(side, false)
	else
		print("Pas trop swag ce password !")
		sleep(2)
	end
end
