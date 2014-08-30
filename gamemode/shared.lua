
GM.Name 	= "Nexus"
GM.Author 	= "GModCoders"
GM.Email 	= "N/A"
GM.Website 	= "glua.me"

DeriveGamemode("sandbox")

include("sh_dimensions.lua")

function GM:Initialize()
	self.BaseClass.Initialize( self )
end