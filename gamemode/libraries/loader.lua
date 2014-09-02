local path = (GM and GM.Path) or GAMEMODE.Path

function nexus.load()
	print("Loading libraries")
	for _, x in pairs(file.Find(path..'/libraries/*','GAME')) do
		local realm = x:sub(1,2)
		if realm == 'cl' then
			if SERVER then AddCSLuaFile(x) print('Sent '..x) continue end
			include(x)
			print('Included '..x)
		elseif realm == 'sv' then
			if SERVER then include(x) print('Included '..x) end
		elseif realm =='sh' then
			if SERVER then AddCSLuaFile(x) print('Sent '..x) end
			include(x)
			print('Included '..x)
		end
	end
end

nexus.load()
events.load()