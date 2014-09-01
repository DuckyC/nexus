nexus.dimensions = {}

if SERVER then
	util.AddNetworkString( "nx_dimension" )
	util.AddNetworkString( "nx_dimension_all" )
end

local ENTITY = FindMetaTable("Entity")

function ENTITY:GetDimension()
	return nexus.dimensions[self:EntIndex()] or 0
end

function ENTITY:ShouldInteract(ent, debugprint)
	if self == ent then return true end
	local dim1 = self.GetDimension and self:GetDimension() or 0
	local dim2 = ent.GetDimension and ent:GetDimension() or 0
	local bool = (dim1 == -1 or dim2 == -1 or (dim1 == dim2))
	if debugprint then print(self, dim1, ent, dim2, bool) end
	return bool
end

if SERVER then
	local function BroadcastDimension(Ent)
		if !IsValid(Ent) then return end 
		net.Start("nx_dimension")
			net.WriteInt(Ent:EntIndex(), 16)
			net.WriteInt(Ent:GetDimension(), 16)
		net.Broadcast()
	end

	local function SendAllDimensions(Ply)
		net.Start("nx_dimension_all")
			local AllEntities = ents.GetAll()
			net.WriteInt(#AllEntities,16)
			for _,Ent in pairs(AllEntities) do
				net.WriteInt(Ent:EntIndex(), 16)
				net.WriteInt(Ent.dimension, 16)
			end
		net.Send(Ply)
	end

	function ENTITY:SetDimension(dimension)
		nexus.dimensions[self:EntIndex()] = dimension or 0
		BroadcastDimension(self)
		if self:IsPlayer() then 
			self:DropObject( )
			for k,v in pairs(self:GetWeapons()) do
				v.dimension = dimension or 0
			end
		end
	end	


	concommand.Add("dimension_setme",function(ply, _, args) if tonumber(args[1]) and IsValid(ply) then ply:SetDimension(tonumber(args[1])) end end)
	concommand.Add("dimension_setthis",function(ply, _, args) 
		if tonumber(args[1]) and IsValid(ply) then 
			local trace = ply:GetEyeTrace()
			if IsValid(trace.Entity) then
				trace.Entity:SetDimension(tonumber(args[1])) 
			end
		end 
	end)
else
	local function HandleEntity(id, dimension)
		if type(id) == "table" then
			for nid,dimension in pairs(id) do
				HandleEntity(nid, dimension)
			end
		end
		nexus.dimensions[id] = dimension or 0
	end

	net.Receive("nx_dimension", function()
		local id = net.ReadInt(16)
		local dimension = net.ReadInt(16)
		HandleEntity(id, dimension)
		print("Received dimension for",id, dimension)
	end)

	net.Receive("nx_dimension_all", function()
		local AllEntities = net.ReadInt(16)
		local Dimensions = {}
		for i=1, AllEntities do
			local id = net.ReadInt(16)
			local dimension = net.ReadInt(16)
			Dimensions[id] = dimension
		end
		HandleEntity(Dimensions)
		print("Received #"..AllEntities.." entity dimensions")
	end)
end



if SERVER then
	-- spawning
	hook.Add("PlayerSpawnedVehicle"	, "nx_dimensions", function(ply  , ent) ent:SetDimension(ply:GetDimension()) end)
	hook.Add("PlayerSpawnedSWEP"	, "nx_dimensions", function(ply  , ent) ent:SetDimension(ply:GetDimension()) end)
	hook.Add("PlayerSpawnedSENT"	, "nx_dimensions", function(ply  , ent) ent:SetDimension(ply:GetDimension()) end)
	hook.Add("PlayerSpawnedRagdoll"	, "nx_dimensions", function(ply,_, ent) ent:SetDimension(ply:GetDimension()) end)
	hook.Add("PlayerSpawnedProp"	, "nx_dimensions", function(ply,_, ent) ent:SetDimension(ply:GetDimension()) end)

	-- player allow
	hook.Add("CanPlayerUnfreeze"	, "nx_dimensions", function(ent1, ent2) if !ent1:ShouldInteract(ent2) then return false end end)
	hook.Add("PlayerCanPickupItem"	, "nx_dimensions", function(ent1, ent2) if !ent1:ShouldInteract(ent2) then return false end end)
	hook.Add("PlayerCanPickupWeapon", "nx_dimensions", function(ent1, ent2) if !ent1:ShouldInteract(ent2) then return false end end)
	hook.Add("AllowPlayerPickup"	, "nx_dimensions", function(ent1, ent2) if !ent1:ShouldInteract(ent2) then return false end end)
	hook.Add("AllowPlayerPickup"	, "nx_dimensions", function( target, dmginfo ) 
		if !target:ShouldInteract(dmginfo:GetInflictor()) then
			dmginfo:SetDamageForce(Vector(0,0,0))
			dmginfo:SetDamage(0)
			return dmginfo
		end
	end)
else
	local IgnoreClasses = {"viewmodel", "physgun_beam", "beam"}
	local function IsIgnored(Ent) 
		if !IsValid(Ent) then return true end 
		local class = Ent:GetClass()
		for i=1, #IgnoreClasses do 
			if class == IgnoreClasses[i] then return true end
		end
		return false
	end

	local LPly = LocalPlayer()
	hook.Add("PrePlayerDraw"	, "nx_dimensions", function(ply2) return !LPly:ShouldInteract(ply2) end)
	hook.Add("PlayerFootstep"	, "nx_dimensions", function(ply2) return !LPly:ShouldInteract(ply2) end)
	hook.Add("DrawPhysgunBeam"	, "nx_dimensions", function(ply2) return LPly:ShouldInteract(ply2) end)
	hook.Add("PreDrawHUD", "nx_dimensions", function()
		local AllEntities = ents.GetAll()
		for i=1, #AllEntities do
			local Ent = AllEntities[i]
			if Ent == LPly or IsIgnored(Ent) then continue end
			local ShouldInteract = LPly:ShouldInteract(Ent)
			if Ent:GetNoDraw() == ShouldInteract then
				RunConsoleCommand("-attack")
				Ent:DrawShadow(ShouldInteract)
				Ent:SetNoDraw(!ShouldInteract)
			end
		end
	end)
end
hook.Add("CanPlayerEnterVehicle"	, "nx_dimensions", function(ent1, ent2) if !ent1:ShouldInteract(ent2) then return false end end)
hook.Add("PlayerCanHearPlayersVoice", "nx_dimensions", function(ent1, ent2) if !ent1:ShouldInteract(ent2) then return false end end)
hook.Add("PlayerShouldTakeDamage"	, "nx_dimensions", function(ent1, ent2) if !ent1:ShouldInteract(ent2) then return false end end)
hook.Add("PhysgunPickup"			, "nx_dimensions", function(ent1, ent2) if !ent1:ShouldInteract(ent2) then return false end end)
hook.Add("GravGunPunt"				, "nx_dimensions", function(ent1, ent2) if !ent1:ShouldInteract(ent2) then return false end end)
hook.Add("ShouldCollide"			, "nx_dimensions", function(ent1, ent2) if !ent1:ShouldInteract(ent2) then return false end end)

hook.Add("OnEntityCreated"			, "nx_dimensions", function(ent)
	ent:EnableCustomCollisions(true)
	local id = ent:EntIndex()
	nexus.dimensions[id] = nexus.dimensions[id] or -1
end)