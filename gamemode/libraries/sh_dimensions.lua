local ENTITY = FindMetaTable("Entity")

function ENTITY:GetDimension()
	return self.dimension or 0
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
	util.AddNetworkString( "nx_dimension_ent" )

	local function BroadcastDimension(ent)
		if !IsValid(ent) then return end 
		net.Start("nx_dimension_ent")
			net.WriteEntity(ent)
			net.WriteInt(ent:GetDimension(), 16)
		net.Broadcast()
	end

	local function SendAllDimensions(ply)
		net.Start("nx_dimension_all")
			local allents = ents.GetAll()
			net.WriteInt(#allents,16)
			for k,v in pairs(allents) do
				net.WriteEntity(v)
				net.WriteInt(v.dimension, 16)
			end
		net.Send(ply)
	end

	function ENTITY:SetDimension(dimension)
		self.dimension = dimension or 0
		BroadcastDimension(self)
		if self:IsPlayer() then 
			for k,v in pairs(self:GetWeapons()) do
				v.dimension = dimension or 0
			end
		end
	end
	
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

	local lp = LocalPlayer()
	local function SetDrawAndShadow(ent)
		if IsValid(ent) and !ent:IsPlayer() and ent:GetClass() != "viewmodel" then
			local bool = lp:ShouldInteract(ent)
			ent:DrawShadow(bool)
			ent:SetNoDraw(!bool)
		end
		if ent == lp then
			for k,v in pairs(ents.GetAll()) do
				if v == lp or v == game.GetWorld() then continue end
				SetDrawAndShadow(v)
			end
		end
	end
	local function HandleEntity(ent, dimension)
		ent.dimension = dimension
		SetDrawAndShadow(ent)
		if ent:IsPlayer() then
			for k,v in pairs(ent:GetWeapons()) do
				v.dimension = dimension or 0
				SetDrawAndShadow(v)
			end
		end
	end
	net.Receive("nx_dimension_ent", function()
		local ent = net.ReadEntity()
		local dimension = net.ReadInt(16)
		HandleEntity(ent, dimension)
		print("Received dimension for",ent, dimension)
	end)
	net.Receive("nx_dimension_all", function()
		local amnt = net.ReadInt(16)
		for i=1, amnt do
			local ent = net.ReadEntity()
			local dimension = net.ReadInt(16)
			HandleEntity(ent, dimension)
		end
		print("Received #"..amnt.." entity dimensions")
	end)

	
	function GM:PrePlayerDraw( ply2 )
		return !lp:ShouldInteract(ply2)
	end
	function GM:PlayerFootstep(  ply2 )
		return !lp:ShouldInteract(ply2)
	end
	function GM:DrawPhysgunBeam( ply2)
		return lp:ShouldInteract(ply2)
	end
end

function GM:ShouldCollide( ent1, ent2 ) return ent1:ShouldInteract(ent2) end
function GM:CanPlayerEnterVehicle( ent1, ent2 ) return ent1:ShouldInteract(ent2)  end
function GM:GravGunPickupAllowed( ent1, ent2 ) return ent1:ShouldInteract(ent2)  end
function GM:PlayerCanHearPlayersVoice( ent1, ent2 ) return ent1:ShouldInteract(ent2)  end
function GM:PlayerShouldTakeDamage( ent1, ent2 ) return ent1:ShouldInteract(ent2)  end
function GM:PhysgunPickup( ent1, ent2 ) return ent1:ShouldInteract(ent2)  end
function GM:GravGunPunt( ent1, ent2 ) return ent1:ShouldInteract(ent2)  end
function GM:OnEntityCreated(ent) ent:SetCustomCollisionCheck(true) end