event = {}
event.__index = event
events = {}

TYPE_MAIN = 1
TYPE_RACE = 2
TYPE_FFA = 3
TYPE_TDM = 4

local path = (GM and GM.Path) or GAMEMODE.Path

function event.new()
	return setmetatable({hooks = {}},event)
end

function event.load()
	print("Loading events")
	for _, x in pairs(file.Find(path..'/events/*','GAME')) do
		local relPath = GM.FolderName..'/gamemode/events/'..x
		if SERVER then AddCSLuaFile(relPath) end
		include(relPath)
	end
	print("Events loaded")
end

function event.getHook(eventType,hook)
	PrintTable(events)
	return events[eventType]['hooks'][hook]
end

function event:register(type)
	events[type] = self
end

function event:addHook(event,func)
	self.hooks[event] = func
end

--pMeta--
local ply = FindMetaTable('Player')

function ply:getEvent()
	return ply.event or TYPE_MAIN
end

function ply:startEvent(type)
	ply.event = type
	//start event
end