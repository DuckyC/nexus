AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( 'shared.lua' )

function GM:PlayerInitialSpawn(ply)
	ply:SetDimension(0)
end
