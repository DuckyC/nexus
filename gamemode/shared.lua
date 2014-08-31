GM.Name 	= "Nexus"
GM.Author 	= "GModCoders"
GM.Email 	= "N/A"
GM.Website 	= "glua.me"
GM.Path 	= "gamemodes/"..GM.FolderPath.."/gamemode"

DeriveGamemode("sandbox")

nexus = {}

if SERVER then
	AddCSLuaFile('libraries/loader.lua')
end
include('libraries/loader.lua')

function GM:Initialize()
	self.BaseClass.Initialize( self )
end
