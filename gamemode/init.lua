AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( 'shared.lua' )


function Chunk_Test(ply)
	if(ply:GetDimension() == 0) then
		ply:SetDimension(1)
	else
		ply:SetDimension(0)
	end
end
concommand.Add("Chunk_Test",Chunk_Test)
