local path = (GM and GM.Path) or GAMEMODE.Path
events = {}

local EVENT = {}
EVENT.__index = event
EVENT.Name = "No name"
EVENT.ID = "PlsPutSomethingHere"

function events.load()
	print("Loading events")
	for _, x in pairs(file.Find(path..'/events/*','GAME')) do
		local relPath = GM.FolderName..'/gamemode/events/'..x
		if SERVER then AddCSLuaFile(relPath) end // remake this to load it like a gamemode
		EVENT = setmetatable({},EVENT)
		include(relPath)

		for name,hookfunc in pairs(EVENT) do
			if type(hookfunc) == "function" then
				hook.Add(name, "EVENT_"..name, hookfunc)
			end
		end
		events[EVENT.ID] = EVENT
		EVENT = nil
	end
	print("Events loaded")
end