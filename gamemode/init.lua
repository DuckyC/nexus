AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( 'shared.lua' )

function GM:PlayerInitialSpawn(ply)
	ply:startEvent(TYPE_FFA) --for debugging
end

function GM:PlayerDeath(ply)
	local func = event.getHook(ply:getEvent(),'PlayerDeath')
	func(ply)
end