--ENUM--
LAYER_MAIN = 1

--layer meta--
layer = {}
layer.__index = layer
layers = {}

function layer.new()
	local t = {info = {}}
	setmetatable(t,layer.index)
	t.key = table.insert(layers,t)
	return t
end

function layer:returnToMain()
	for i=1,self.ents do
		self.ents[i]:SetLayer(LAYER_MAIN)
	end
	layers[self.key] = nil
	return self
end

function layer:setType(type)
	self.type = type
	return self
end

function layer:getInfo()
	//return event.getInfo(self.type)
end

--NET--
if SERVER then
	util.AddNetworkString('nx_layer_set')
end
if CLIENT then
	net.Receive('nx_layer_set',function()
		local index = net.ReadUInt(32)
		local layer = net.ReadUInt(8)
		local ent = Entity(index)
		if !IsValid(ent) then
			return
		end
		ent.layer = layer
		ent:handle()
	end)
end
--META--
local ENT = FindMetaTable('Entity')

if SERVER then
	function ENT:setLayer(num)
		print('Setting layer for ',self,' layer: ',num)
		self.layer = num
		net.Start('nx_layer_set')
		net.WriteUInt(self:EntIndex(),32)
		net.WriteUInt(num,8)
		net.Broadcast()
	end

else
	function ENT:handle()
		if !self:shouldLayer() then return end
		local lp = LocalPlayer()
		if self == lp then
			for _, x in pairs(ents.GetAll()) do
				if x == lp then continue end
				x:handle()
			end
			return
		end
		local phys = self:GetPhysicsObject()
		if self:getLayer() ~= lp:getLayer() then
			self:SetNoDraw(true)
			self:DrawShadow(false)
		else
			self:SetNoDraw(false)
			self:DrawShadow(true)
		end

	end
end

function ENT:getLayer()
	return (self.layer and self.layer > 0 and self.layer) or nil
end

function ENT:shouldLayer()
	if self:IsPlayer() then return true end
	if self:IsVehicle() then return true end

	local class = self:GetClass()

	if string.find(class,'weapon_') then return true end
	if string.find(class,'prop_') then return true end
	return false
end

--GM--
local GM = GM or GAMEMODE
function GM:OnEntityCreated(ent)
	if !ent:shouldLayer() then return end
	if SERVER then
		ent:setLayer(LAYER_MAIN)
	else
		ent:handle()
	end
end