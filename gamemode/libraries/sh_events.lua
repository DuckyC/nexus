local path = (GM and GM.Path) or GAMEMODE.Path
events = {}
print(events)

local EV_META = {}
EV_META.__index = EV_META

function EV_META:DeriveEvent(name)
	local EVENT = events.loadEvent(name)
	self = setmetatable(table.Inherit( self, EVENT ), EV_META)
end

local RM_META = {}
RM_META.__index = RM_META
function RM_META:GetPlayers()
	return self.Players
end
function RM_META:GetEvent()
	return self.Event or {}
end
function RM_META:SetEventType(TYPE)
	self.Event = setmetatable(table.Copy(events[TYPE]), EV_META)
end
function RM_META:AddPlayer(ply)
	if type(ply) == "Player" then
		self.Players[#self.Players] = ply
	elseif type(ply) == "table" then
		self.Players = table.Inherit(self.Players, ply)
	end
end

local PLAYER = FindMetaTable("Player")
function PLAYER:SetRoom(Room)
	self.Room = Room
end

local EVENTS_PATH = path.."/events/"
function events.loadEvent(name)
	local searchpath = EVENTS_PATH..name
	local includepath = "nexus/gamemode/events/"..name

	EVENT = nil

	if file.Exists( searchpath, "GAME" ) and file.IsDir(searchpath, "GAME") then
		EVENT = setmetatable({},EV_META)
		EVENT.ID = #events+1
		
		if file.Exists( searchpath.."/cl_init.lua", "GAME" ) then
			if SERVER then 
				AddCSLuaFile(includepath.."/cl_init.lua") 
			else 
				include(includepath.."/cl_init.lua") 
			end
		end
		if SERVER then
			if file.Exists( searchpath.."/init.lua", "GAME" ) then
				include(includepath.."/init.lua") 
			end
		end
	end

	if file.Exists( searchpath..".lua", "GAME" ) then
		EVENT = setmetatable({},EV_META)
		EVENT.ID = #events+1
		
		if SERVER then AddCSLuaFile(includepath..".lua") end
		include(includepath..".lua")

	end

	if EVENT and #EVENT > 0 then
		for name,hookfunc in pairs(EVENT) do
			if type(hookfunc) == "function" then
				hook.Add(name, "EVENT_"..EVENT.Name.."_"..EVENT.ID, hookfunc)
			end
		end
		local rtn = setmetatable(table.Copy(EVENT), EV_META)
		EVENT = nil
		return rtn
	end
	return false
end

function events.load()
	print("Loading events")
	local files, folders = file.Find(path..'/events/*','GAME')
	for _, x in pairs(files) do 
		local EVENT = events.loadEvent(string.Explode(".", x)[1]) 
		if not EVENT then print("OH NOES!",x) continue end
		events[EVENT.ID] = EVENT
		print("Loaded event: "..EVENT.Name)
	end

	for _, x in pairs(folders) do 
		local EVENT = events.loadEvent(x) 
		if not EVENT then print("OH NOES!",x) continue end
		events[EVENT.ID] = EVENT
		print("Loaded event: "..EVENT.Name)
	end
	print("Events loaded")
end

function events.startEvent(TYPE, players)
	local Room = setmetatable({}, RM_META)
	Room:SetEventType(TYPE)
	Room:AddPlayer(Players)
	for k,ply in pairs(players) do
		ply:SetRoom(Room)
	end
end

