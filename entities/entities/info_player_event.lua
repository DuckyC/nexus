ENT.Type = "point"

if CLIENT then return end

function ENT:Initialize() end

function ENT:KeyValue(key, value)
	self[key] = tonumber(value)
end