--LPA by: http://youtube.com/thepofplayer
--This is a modified version of the PasteBin script to work directly with lpa's ThePofPlayer program files.
--Based on TurtleScripts.com
local tArgs = { ... }

local function termClear()
	term.clear()
	term.setCursorPos(1,1)
    print( " LPA v1.0 BETA (#h8ZjhpU7)" )
	print( "---------------" )
    print("")
end

local function printUsage()
  term.clear()
  term.setCursorPos(1,1)
    print( " LPA v1.1 BETA (#h8ZjhpU7)" )
	print( "---------------" )
	print( "by: Pof Magicfingers" )
	print( " " )
	print( "Utilisation:" )
	print( " == Recuperation ==" )
	print( "  lpa (episode) (program)" )
	print( " == Liste des programmes ==" )
	print( "  lpa (episode)" )
	print( " == Mise a jour LPA ==" )
	print( "  lpa update" )
	print( " " )
end

function decode(resp)
  resp = resp or ""
  local table = {}
  local index = 1

  i, j = string.find(resp, "/PofMagicfingers/lpa_computercraft/blob/[^/]+/")
  while i ~= nil do
  	content = string.sub(resp, j+1, string.find(resp, "\"", j)-1)
  	if not string.match(content, ".spec$") and not string.match(content, ".md$") then
  		if string.match(content, ".lua$") then
  			content = string.gsub(content, ".lua$","")
  		end
	    table[index] = content
	    index = index + 1
	end
    i, j = string.find(resp, "/PofMagicfingers/lpa_computercraft/blob/[^/]+/", j)
  end

  return table
end

function printlist(resp, ep)
  resp = resp or ""

  local table = decode(resp)
  local printed = 0
  local per_page = 4

  termClear()
  term.setCursorPos(1,3)

  print("Episode "..ep..": Programmes (1/"..math.ceil(#table/per_page)..")")
  print("============================")
  print("")

  for i=1,#table do
    if printed == per_page then
      print("")
      print("Suite: Appuyez sur une touche...")
      os.pullEvent ("key")
      printed = 0
	  termClear()
	  term.setCursorPos(1,3)
      print("Episode "..ep..": Programmes ("..math.ceil(i/per_page).."/"..math.ceil(#table/per_page)..")")
      print("============================")
      print("")
    end
    print("   - "..table[i] )
    printed = printed + 1
  end
  print("")
end

local function getFile(episode, program)
	termClear()

	if episode == "update" and program == "" then
		episode = "master" ; program = "lpa"
	end

    if episode == "" then
		print( "Vous devez fournir un numero d'episode !" ) ; return
	else
		if type(tonumber(episode)) == "number" then
			episode = "ep"..tostring(tonumber(episode))
		end
	end

	if program == "" then
		termClear()
		write( "Connexion... " )
		local response = http.get("https://github.com/PofMagicfingers/lpa_computercraft/file-list/"..episode)
		if response then
			local sResponse = response.readAll()
			response.close()
			printlist(sResponse, episode)
		else
			print( "Echec." )
			print( " " )
			print( "Verifiez le point suivant :" )
			print( "  - (episode) : est un nombre")
			print("")
			print( "	  exemple : lpa 3 " )
			print("")
		end
		return
	end
	termClear()
	write( "Connexion... " )
	local response = http.get("https://raw2.github.com/PofMagicfingers/lpa_computercraft/"..episode.."/"..program..".lua")
	if not response then
		response = http.get("https://raw2.github.com/PofMagicfingers/lpa_computercraft/"..episode.."/"..program)
	end
	if response then
		print( "OK !" )
		local sResponse = response.readAll()
		response.close()
		
	    local sPath = shell.resolve( program )

		local spec_response = http.get("https://raw2.github.com/PofMagicfingers/lpa_computercraft/"..episode.."/"..program..".spec")
		if spec_response then
			local tResponse = textutils.unserialize(spec_response.readAll())
			spec_response.close()
			if tResponse and tResponse["installPath"] then
				sPath = tResponse["installPath"] ; program = sPath
			end
		end

		sDirPath = string.match(sPath, "(.-)([^/]-)$")

		pcall(function() fs.makeDir(sDirPath) end)

		if (not fs.isDir( sDirPath ) and fs.exists( sDirPath )) then
			print("Impossible de creer le dossier d'installation "..sDirPath)
			print("Creez le dossier manuellement et reessayez.")
			return
		end

		if fs.exists( sPath ) then
			if fs.isDir( sPath ) then
				print("Un dossier "..sPath.." existe deja, renommez le ou supprimez le pour pouvoir installer ce programme")
				return
			else
				local override = ""
				printed = 0
				while override ~= "n" and override ~= "o" do
					if printed == 3 then 
						termClear()
						printed = 0
					end
					print( "Le programme "..program.." existe !" )
					print( "Remplacer ? (o pour oui, n pour non)" )
					print( " " )
					event, override = os.pullEvent ("char")
					printed = printed + 1
				end
				if override == "n" then return end
			end
		end
		
		local file = fs.open( sPath, "w" )
		file.write( sResponse )
		file.close()
		print( " " )
		print( "Nouvelle commande : "..program )
		print( "[===========================] 100%" )
		print( " "..string.len(sResponse).." octets")
		print( " " )
		print( "Telechargement accompli." )
	else
		print( "Echec." )
		print( " " )
		print( "Verifiez les points suivant :" )
		print( "  - (program) : majuscules importantes" )
		print( "  - (episode) : est un nombre")
		print( " ")
		print( "exemple : lpa 3 programmeCool " )
		print(" ")
	end
end

local gui_mode = false
if #tArgs < 1 then
	printUsage()
	return
end
local episode = tArgs[1] or ""
local program = tArgs[2] or ""
getFile(episode, program)
