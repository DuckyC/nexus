
ENT.Base = "base_brush"
ENT.Type = "brush"
ENT.Spawnable = false

if CLIENT then return end

function ENT:Initialize() end

function ENT:KeyValue(key, value)
	self[key] = tonumber(value)
end

function ENT:StartTouch( ent )

end

function ENT:EndTouch( ent )

end