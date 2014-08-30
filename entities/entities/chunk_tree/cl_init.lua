include("shared.lua")

function ENT:Initialize()
end

function ENT:Draw()
	local ent = self
	local ply = LocalPlayer()
	if(ent:GetNWInt("Kunit_PhaseEnt") > 0) then
		if(ply:GetNWInt("Kunit_Phase") == ent:GetNWInt("Kunit_PhaseEnt")) then
			self:DrawModel()
		else
			--print("NOT DRAWING ONE")
		end
	end
	--self:DrawModel()
end

function ENT:Think()
end
