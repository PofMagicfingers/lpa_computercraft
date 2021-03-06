trackerDB = {}
current_page = 0
modemSide = "back"
lang="fr"

local isDebug = false

--[[
  Saving
]]
function saveData()
  debug("Saving database...")
  debug(textutils.serialize(trackerDB))
  local f = fs.open("trackerDB/trackerDB", "w")
  f.write(textutils.serialize(trackerDB))
  f.close()
  debug("Saved!")
end

function loadData()
  debug("Checking for previous database...")
  if fs.exists("trackerDB/trackerDB") then
    f = fs.open("trackerDB/trackerDB", "r")
    trackerDB = textutils.unserialize(f.readAll())
    f.close()

    debug("Database found. Loading data...")
  end
end

function updateData(computer_id, table)
  debug("Saving state of computer "..tostring(computer_id).." to trackerDB...")
  trackerDB[computer_id] = {id = computer_id, name = table[8], location = vector.new(table[1], table[2], table[3])}
  debug("Triggering database save")
  saveData()
end

function debug(message)
  if isDebug then
    print(message)
    sleep(.5)
  end
end

--[[
  Program functions
]]

function delete_turtle(computer_key)
  while true do
    computer = trackerDB[computer_key]
    term.clear()
    term.setCursorPos(1,1)
    print("")
    if lang == "fr" then
      print("Tortue : ")
    else
      print("Turtle : ")
    end
    print(computer["name"])
    print("")
    if lang == "fr" then
      print("Etes vous sur de vouloir supprimer cette tortue du tracker ?")
    else
      print("Are you sure you want to remove this turtle from the tracker?")
    end
    print("")
    if lang == "fr" then
      print("La tortue sera rajoutee de nouveau des qu'elle bougera...")
    else
      print("The turtle will be added again when it moves...")
    end
    print("")
    print("")
    if lang == "fr" then
      print("Y pour Oui (Yes) / N pour Non ")
    else
      print("Y for yes / N for No")
    end

    local event, param1, param2, param3, param4 = os.pullEvent()

    if event == "rednet_message" then
      updateData(param1, param2)
      -- print("Received rednet_message")
    else
      if event == "key" then
        if param1 == 21 then
          debug("Deleting turtle.")
          trackerDB[computer_key] = nil
          return true
        else
          if param1 == 49 then
            return false
          end
        end
      end
    end
  end
end

function track_or_edit(computer_key)
  computer = trackerDB[computer_key]
  term.clear()
  term.setCursorPos(1,1)

  print("")
  if lang == "fr" then
    print("Suivi de la tortue : ")
  else
    print("Tracking turtle:")
  end
  print(" "..computer["name"])
  if lang == "fr" then
    print("Derniere position connue :")
  else
    print("Last known location:")
  end
  loc = computer["location"]
  if loc.x ~= nil and loc.y ~= nil and loc.z ~= nil then
    print(" "..math.ceil(loc.x)..", "..math.ceil(loc.z).."  ("..math.ceil(loc.y)..")")
  else
    if lang == "fr" then
      print("Inconnue")
    else
      print("Unknown")
    end
  end
  print("")
  print("")
  if lang == "fr" then
    print("Appuyez sur une touche : ")
    print(" X : Supprimer du tracker")
    print(" B : Retour au menu")
  else
    print("Press a key : ")
    print(" X : Delete from tracker")
    print(" B : Go back to menu")
  end

  local event, param1, param2, param3, param4 = os.pullEvent()

  if event == "rednet_message" then
    updateData(param1, param2)
    -- print("Received rednet_message")
  else
    if event == "key" then
      if param1 == 48 then
        return false
      else
        if param1 == 45 then
          return (not delete_turtle(computer_key))
        end
      end
    end
  end

  return true
end

function main()
  local keyset={}
  local n=0

  term.clear()
  term.setCursorPos(1,1)


  for k,v in pairs(trackerDB) do
    n=n+1
    keyset[n]=k
  end

  table.sort(keyset)

  if #keyset > 0 then
    min = (current_page*9)+1
    max = min+8

    if min > #keyset then 
      current_page = 0
      min = 1
      max = 9
    end

    if max > #keyset then
      max = #keyset
    end

    max_page = math.ceil(#keyset/9)

    for i=min,max do
      v = trackerDB[keyset[i]]
      if v then
        local loc = v["location"]
        print("["..(i-min+1).."] "..v["name"])
      end
    end
  
  else

  if lang == "fr" then
    print("Aucune tortue n'envoie sa position, et pas de tortues dans la base de donnees.")
  else
    print("No turtles sending its location, and no turtles in DB.")
  end

  end

  if max_page and tonumber(max_page) > 0 then
    print("")
    print("Page "..tostring(tonumber(current_page)+1).."/"..max_page)
  end

  print("")
  if lang == "fr" then
    print("Appuyez sur une touche : ")
    print(" 1-9 : Editer/Suivre")
    print(" P   : Changer pages")
    print(" Q   : Quitter")
  else
    print("Press a key : ")
    print(" 1-9 : Edit/track turtle")
    print(" P   : Switch pages")
    print(" Q   : Quit this program")
  end
  print("")

  local event, param1, param2, param3, param4 = os.pullEvent()

  if event == "rednet_message" then
    updateData(param1, param2)
    -- print("Received rednet_message")
  else
    if event == "key" then
      if param1 == 16 then
        if lang == "fr" then
          print("Stoppage du tracker")
        else
          print("Stopping tracker")
        end
        return false
      else
        if param1 == 25 then
          current_page = current_page + 1
        else
          if (param1 <= 10 and param1 >= 2) or (param1 <= 81 and param1 >= 71) then
            num = nil
            if (param1 <= 10 and param1 >= 2) then num = (param1-1) end
            if (param1 <= 73 and param1 >= 71) then num = (param1-64) end
            if (param1 <= 77 and param1 >= 75) then num = (param1-71) end
            if (param1 <= 81 and param1 >= 79) then num = (param1-78) end
            num = (num+min-1)
            if num >= min and num <= max then
              while track_or_edit(keyset[num]) do
                -- nothing
              end
            end
          end
        end
      end
    else
      -- print("Received "..event)
    end
  end

  return true
end

--[[
  Start of program
]]

loadData()
rednet.open(modemSide)
while main() do
  -- nothing
end
rednet.close()