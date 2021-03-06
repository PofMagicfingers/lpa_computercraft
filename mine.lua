os.loadAPI("api/move")
local profondeur = 0                                    -- indique de combien on a creusé
local xPosition = 0                                             -- indique la position courante en x
local zPosition = 0                                             -- indique la position courante en z
local initial_orientation = -1

local plan = {}                                                 -- tableau pour stocker les coordonnées relatives des puits de minage.

local orientation = -1

local chest_orientation

local sDirtoiDir = {south = 0, west = 1, north = 2, east = 3}
local iDirtosDir = {[0]="south", [1]="west", [2]="north", [3]="east"}

local use_exclude_list = false
local exclude_list = {}

if turtle.inspect and fs.exists("mine.exclude") then
	use_exclude_list = true
	local h = fs.open("mine.exclude", "r")
	line = h.readLine()
	while line do exclude_list[line] = true ;  line = h.readLine() end
	h.close()
end

function getOrientation()
	local orient = turtle.getDir()
	if orient ~= "north" and orient ~= "east" and orient ~= "west" and orient ~= "south" then orient = "north" end
	return sDirtoiDir[orient]
end

function turtleRight()
	turtle.turnRight()
end

function turtleLeft()
	turtle.turnLeft()
end
 
function mine()                                 -- fonction qui compare et mine, tourne à droite et direction++
	if use_exclude_list and turtle.inspect then
		block, info = turtle.inspect()
		if block and type(info) == "table" and info["name"] then
			if exclude_list[info["name"]] == true then
				return
			end
		end
	end
	turtle.dig()
end
 
function verifFuel(first_slot, loop)                                    -- vérifie si on a assez de fuel (déplacements) en réserve.
	if turtle.getFuelLevel() < 500 then
		first_slot = first_slot or 1
		if first_slot <= 0 or first_slot > 16 then first_slot = 1 end
		loop = loop or true


		if (turtle.getFuelLevel() ~= "unlimited") then
			for i=first_slot,16 do
				turtle.select(i)
				turtle.refuel()
			end
			if loop then
				while turtle.getFuelLevel() < 5 do
					local x, y, z = gps.locate(5)

					print("J'ai faim !")
					print("Donnez du carburant et appuyez sur une touche !")
					read()
					verifFuel(first_slot, false)
				end
			end
		end
	end
end
 
function check_turtle_full()
	for i=1,16 do
		if turtle.getItemCount(i) == 0 then return false end -- turtle not full
	end

	empty_turtle()

end

function empty_turtle()
	local locationX = turtle.getX()
	local locationZ = turtle.getZ()
	local locationY = turtle.getY()
	local locationO = getOrientation()

	deplacement(0, 0, 0, chest_orientation)

	for slot=1,16 do
		turtle.select(slot)
		while turtle.getItemCount(slot) > 0 do
			if not turtle.drop(turtle.getItemCount(slot)) then
				while not turtle.drop(turtle.getItemCount(slot)) and turtle.getItemCount(slot) > 0 do
					print("Coffre plein, faites de la place puis appuyez sur une touche")
					read()
				end
			else
				if turtle.getItemCount(slot) > 0 then
					sleep(0.5)
				end
			end
		end
	end

	deplacement(locationX, locationY, locationZ, locationO)
end

function setOrientation(orientation)
	-- if orientation >= 0 and orientation <= 3 then
	-- 	local mouvement = orientation - getOrientation()
	-- 	if mouvement ~= 0 then
	-- 		if math.abs(mouvement) == 3 then mouvement = mouvement/3 end
	-- 		for i=1,math.abs(mouvement) do
	-- 			if mouvement < 0 then
	-- 				turtleLeft()
	-- 			else
	-- 				turtleRight()
	-- 			end
	-- 		end
	-- 	end
	-- end

	if orientation >= 0 and orientation <= 3 then
		turtle.turnToDir(iDirtosDir[orientation])
	end

end

function calcPlan(initial_orientation, direction)                                     -- calcule les emplacements des puits de minage
		print("CALCPLAN WITH initial_orientation = "..initial_orientation.." and direction = "..direction.." !")
		sleep(5)
		local factorX, factorZ

		if initial_orientation == "south" then
			factorZ = 1
			if direction == "right" then
				factorX = -1
			else
				factorX = 1
			end
		end
		if initial_orientation == "west" then
			factorX = -1
			if direction == "right" then
				factorZ = -1
			else
				factorZ = 1
			end
		end
		if initial_orientation == "north" then
			factorZ = -1
			if direction == "right" then
				factorX = 1
			else
				factorX = -1
			end
		end
		if initial_orientation == "east" then
			factorX = 1
			if direction == "right" then
				factorZ = 1
			else
				factorZ = -1
			end
		end

		local x, z, temp, xTemp
		temp = 1
		-- pour forcer à miner le point de départ
		plan[temp] = {}
		plan[temp][1] = 0
		plan[temp][2] = 0
		temp = temp + 1
	   
		-- on boucle sur les colonnes
		for z=0,largeur do
				x = 0
			   
				--on calcule le x du 1er premier puit de minage pour la colonne z
				x = 5 - (z*2) + x
				while x < 0 do
						x = x + 5
				end

				if x <= longueur then
					plan[temp] = {}
					plan[temp][1] = x*factorX
					plan[temp][2] = z*factorZ
					temp = temp + 1
 				end

				-- et ensuite on trouve automatiquement les autres emplacements de la colonne z
				while x <= longueur do
						x = x + 5
						if x <= longueur then
								plan[temp] = {}
								plan[temp][1] = x*factorX
								plan[temp][2] = z*factorZ
								temp = temp + 1
						end
				end
				z = z + 1
		end
end
 
function deplacement(x, y, z, dir)                               -- pour aller à des coordonnées précises
	if dir and (tonumber(dir) < 0 or tonumber(dir) >= 4) then
		dir = 0
	end

	print("déplacement vers "..x..","..y..","..z.." !")

	turtle.fMoveTo(x, y, z, iDirtosDir[dir], "y", "x", "z")
 
--  		local l_initial_orientation
-- 		local nbX
-- 		local nbZ
	   
-- 		l_initial_orientation = getOrientation()

-- -- On commence par se déplacer en x
	   
-- 		r = tonumber(r)
-- 		s = tonumber(s)
	   
-- 		if r > xPosition then
-- 				nbX = r - xPosition
-- 				setOrientation(longueur_dir)
-- 		elseif r < xPosition then
-- 				nbX = xPosition - r
-- 				setOrientation(minus_longueur_dir)
-- 		end
	   
-- 		if r ~= xPosition then
-- 				while nbX > 0 do
-- 						if not turtle.forward() then
-- 								check_turtle_full()
-- 								turtle.dig() -- ici, on n'a pas réussi à avancer, donc on creuse devant soit pour dégager le passage
-- 								turtle.forward()
-- 						end
-- 						if getOrientation() == longueur_dir then xPosition = xPosition + 1 else xPosition = xPosition - 1 end
-- 						verifFuel()
-- 						nbX = nbX - 1
-- 				end
-- 		end
 
-- -- Ensuite on fait le déplacement en z
	   
-- 		if s > zPosition then
-- 				nbZ = s - zPosition
			   
-- 				setOrientation(largeur_dir)
-- 		elseif s < zPosition then
-- 				nbZ = zPosition - s
			   
-- 				setOrientation(minus_largeur_dir)
-- 		end
	   
-- 		if s ~= zPosition then
-- 				while nbZ > 0 do
-- 						if not turtle.forward() then
-- 								check_turtle_full()
-- 								turtle.dig() -- ici, on n'a pas réussi à avancer, donc on creuse devant soit pour dégager le passage
-- 								turtle.forward()
-- 						end
-- 						if getOrientation() == largeur_dir then zPosition = zPosition + 1 else zPosition = zPosition - 1 end
-- 						verifFuel()
-- 						nbZ = nbZ - 1
-- 				end
-- 		end
	   
-- 		--on se remet en direction "zéro"
-- 		setOrientation(l_initial_orientation)
 
end

function turtleDown()
	check_turtle_full()

	if turtle.detectDown() == true then   -- on vérifie si il y a un bloc en dessous
		if turtle.digDown() == false then -- si on n'arrive pas à creuser en dessous, alors c'est la bedrock
			return false             -- donc je met le drapeau à true pour sortir de la boucle
		else
			verifFuel()
			while turtle.down() == false do
				sleep(0.1)
				print("Impossible de descendre ?")
			end
			profondeur = profondeur+1
		end
	else                                    -- si il n'y a pas de bloc alors c'est de l'air, de l'eau ou de la lave
		verifFuel()
		while turtle.down() == false do
			sleep(0.1)
			print("Impossible de descendre ?")
		end
		profondeur = profondeur+1
	end

	return true
end


--********************************************--
--********** Programme principal *************--
--********************************************--
print("Initialisation...")
print("")
print("La tortue doit etre placee dans une zone (minimum 2x2) delimitee avec n'importe quel element : barrieres, cubes, etc...")
print("")
print("L'inventaire de la tortue doit contenir UNIQUEMENT un coffre (slot 1) et du charbon (peu importe) avant de commencer.")
print("")
print("Quand tout est pret, appuez sur Entree...")
read()

while turtle.detect() do
	print("Impossible d'avancer...")
	turtleRight()
end

verifFuel(2)

turtle.setCoordsWithGPS()
turtle.setCoords(0, 0, 0, turtle.getDir())

-- initialiser position
getOrientation()
turtleRight()
turtleRight()
turtle.forward()
turtleRight()
turtleRight()

largeur_dir = getOrientation()
minus_largeur_dir = getOrientation()-2
if minus_largeur_dir < 0 then minus_largeur_dir = 4 + minus_largeur_dir end

largeur = 0

while turtle.detect() == false do
	turtle.forward()
	largeur = largeur+1
end

-- detect next direction
local nextDirection = turtleRight

nextDirection()

if turtle.detect() then
	turtleLeft()
	turtleLeft()
	if turtle.detect() then
		print("Impossible de continuer, la zone doit faire 2 de largeur minimum !")
		exit()
	else
		nextDirection = turtleLeft
	end
end

longueur_dir = getOrientation()
minus_longueur_dir = getOrientation()-2
if minus_longueur_dir < 0 then minus_longueur_dir = 4 + minus_longueur_dir end
longueur = 0

while turtle.detect() == false do
	turtle.forward()
	longueur = longueur+1
end

nextDirection()

for i=1,largeur do
	turtle.forward()
end 

nextDirection()

for i=1,longueur do
	turtle.forward()
end 

turtle.dig()

turtle.select(1)
turtle.place()

chest_orientation = getOrientation()

nextDirection()

initial_orientation = getOrientation()

calcPlan(turtle.getDir(), nextDirection == turtleRight and "right" or "left") -- on calcule les emplacements des puits de forage
 
local p, pmax = 1, #plan
 
-- ici, affichage du nombre de puits à creuser et attente confirmation pour commencer
-- puis à chaque down ou up, affichage de la profondeur et màj du "puit en cours/nb puits total"
-- et affichage lorsqu'on vide l'inventaire ou que l'on reprend du charbon
 
print("")
print("Nombre de puits a creuser : "..#plan)

profondeur = 0

while p <= pmax do
		verifFuel() -- on refait le plein si besoin
		print("Deplacement puit "..p.."/"..pmax)


		deplacement(plan[p][1], 0, plan[p][2], initial_orientation) -- puis on se déplace sur le puit à forer

		while turtleDown() do
			print("En bas ! profondeur = "..profondeur)
			for i=1,4 do
				mine()
				turtleRight()
			end
			check_turtle_full()
			print("Fin du minage. En bas ?")
		end

		print("Impossible d'aller plus bas. En haut...")

		deplacement(turtle.getX(), 0, turtle.getZ(), getOrientation(), "y", "x", "z")

		print("Puit fini")

	   
		p = p + 1
end
 
deplacement(0,0,0, initial_orientation) -- retour au point de départ

empty_turtle()