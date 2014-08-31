local path = (GM and GM.Path) or GAMEMODE.Path

function nexus.load()
	for _, x in pairs(file.Find(path..'/libraries/*','GAME')) do
		local realm = x:sub(1,2)
		local relPath = GM.FolderName..'/gamemode/libraries/'..x
		if realm == 'cl' then
			if SERVER then AddCSLuaFile(relPath) print('Sent '..x) continue end
			include(relPath)
			print('Included '..x)
		elseif realm == 'sv' then
			if SERVER then include(relPath) print('Included '..x) end
		elseif realm =='sh' then
			if SERVER then AddCSLuaFile(relPath) print('Sent '..x) end
			include(relPath)
			print('Included '..x)
		end
	end
end

nexus.load()