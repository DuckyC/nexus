nexus.dimensions = {}

if SERVER then
	util.AddNetworkString( "nx_dimension" )
	util.AddNetworkString( "nx_dimension_all" )
end

local ENTITY = FindMetaTable("Entity")

function ENTITY:GetDimension()
	return nexus.dimensions[self:EntIndex()] or 0
end

function ENTITY:ShouldInteract(ent)
	if self == ent then return true end
	local dim1 = self.GetDimension and self:GetDimension() or 0
	local dim2 = ent.GetDimension and ent:GetDimension() or 0
	if(dim1 == -1 or dim2 == -1 or (dim1 == dim2))then
		return true
	else 
		return false
	end
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
else
	local LPly = LocalPlayer()

	local function SetDrawAndShadow(Ent)
		/*if IsValid(Ent) and !Ent:IsPlayer() and Ent:GetClass() != "viewmodel" then
			local bool = LPly:ShouldInteract(Ent)
			Ent:DrawShadow(bool)
			Ent:SetNoDraw(!bool)
			print(Ent, bool)
		end
		if Ent == LPly then
			for _,AEnt in pairs(ents.GetAll()) do
				if AEnt == LPly or AEnt == game.GetWorld() then continue end
				SetDrawAndShadow(v)
			end
		end
		if IsValid(Ent) and Ent:IsPlayer() then
			for _,Wep in pairs(Ent:GetWeapons()) do
				nexus.dimensions[Wep:EntIndex()] = dimension or 0
				SetDrawAndShadow(Wep)
			end
		end*/
	end

	local function HandleEntity(id, dimension)
		if type(id) == "table" then
			for nid,dimension in pairs(id) do
				HandleEntity(nid, dimension)
			end
		end
		nexus.dimensions[id] = dimension or 0
		print("Starting timer")
		timer.Simple(1, function()
			print(Entity(id), id)
			SetDrawAndShadow(Entity(id))
		end)
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
	function GM:CanPlayerUnfreeze( ent1, ent2 ) return ent1:ShouldInteract(ent2) end
	function GM:PlayerCanPickupItem( ent1, ent2 ) return ent1:ShouldInteract(ent2) end
	function GM:PlayerCanPickupWeapon( ent1, ent2 ) return ent1:ShouldInteract(ent2) end
	function GM:AllowPlayerPickup( ent1, ent2 ) return ent1:ShouldInteract(ent2) end
	function GM:EntityTakeDamage( target, dmginfo ) 
		if !target:ShouldInteract(dmginfo:GetInflictor()) then
			dmginfo:SetDamageForce(Vector(0,0,0))
			dmginfo:SetDamage(0)
		end
		return dmginfo
	end
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
	function GM:PrePlayerDraw( ply2 )
		return !LPly:ShouldInteract(ply2)
	end
	function GM:PlayerFootstep(  ply2 )
		return !LPly:ShouldInteract(ply2)
	end
	function GM:DrawPhysgunBeam( ply2)
		return LPly:ShouldInteract(ply2)
	end
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
function GM:ShouldCollide( ent1, ent2 ) sukmudik() return ent1:ShouldInteract(ent2) end
function GM:CanPlayerEnterVehicle( ent1, ent2 ) return ent1:ShouldInteract(ent2)  end
function GM:GravGunPickupAllowed( ent1, ent2 ) return ent1:ShouldInteract(ent2)  end
function GM:PlayerCanHearPlayersVoice( ent1, ent2 ) return ent1:ShouldInteract(ent2)  end
function GM:PlayerShouldTakeDamage( ent1, ent2 ) return ent1:ShouldInteract(ent2)  end
function GM:PhysgunPickup( ent1, ent2 ) return ent1:ShouldInteract(ent2)  end
function GM:GravGunPunt( ent1, ent2 ) return ent1:ShouldInteract(ent2)  end

hook.Add("ShouldCollide", "nx_dimensions", function( ent1, ent2 ) sukmudik() return ent1:ShouldInteract(ent2) end)

hook.Add("OnEntityCreated", "nx_dimensions", function(ent)
	timer.Simple(1, function() if IsValid(ent) then print(ent, "collpls") ent:EnableCustomCollisions(true) end end)
	if SERVER then ent:SetDimension(0) end
end)