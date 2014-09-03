local path = (GM and GM.Path) or GAMEMODE.Path

function nexus.load()
	print("Loading libraries")
	if (SERVER) then
		for _, x in pairs(file.Find(path..'/libraries/*','GAME')) do
			if (x == "loader.lua") then continue end

			local realm = x:sub(1,2)
			if realm == 'cl' then
				AddCSLuaFile(x) print('Sent '..x)
			elseif realm == 'sv' then
				include(x) print('Included '..x)
			elseif realm =='sh' then
				AddCSLuaFile(x) print('Sent '..x)
				include(x)
			end
		end
	else
		local fil = file.Find("nexus/gamemode/libraries/*", "LUA") //blah blah use this instead of path. path includes the gamemodes folder
		for k,v in pairs(fil) do
			if (v == "loader.lua") then continue end

			print(v) 
			include(v)
		end
	end
end

nexus.load()
events.load()
