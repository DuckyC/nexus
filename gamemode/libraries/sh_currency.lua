local Player = FindMetaTable("Player")

/* Returns the player's current nexi level. */
function Player:GetNexi()
	if (CLIENT and not self.Nexi) then self.Nexi = self:GetNWInt("Nexi") end

	return self.Nexi or 0
end

/* Determines whether the player can afford the price */
function Player:canAfford(amt)
	if (CLIENT and not self.Nexi) then self.Nexi = self:GetNWInt("Nexi") end
	
	local cur = self.Nexi or 0

	if (cur - amt < 0) then return false end
	return true
end

if (SERVER) then

	util.AddNetworkString("Nexi_UpdateCL")

	/* Syncs the player's client-side nexi levels with that of the server. */
	function Player:syncNexi()
		self:SetNWInt("Nexi", self.Nexi or 0)
	end

	/* Gives nexi to the player. */
	function Player:addNexi(amt)
		local cur = self.Nexi or 0
		local new = cur + tonumber(amt) or 0

		self.Nexi = new
		self:syncNexi()
		self:saveNexi()
	end

	/* Takes away nexi from the player. Takes string or number. */
	function Player:takeNexi(amt)
		local cur = self.Nexi or 0
		local new = cur - tonumber(amt) or 0

		self.Nexi = new
		self:syncNexi()
		self:saveNexi()
	end

	/* Sets a player's nexi level */
	function Player:setNexi(amt)

		self.Nexi = tonumber(amt) or 0
		self:syncNexi()
		self:saveNexi()
	end

	/* Saves the player's nexi */
	function Player:saveNexi()
		local nexi = self.Nexi or 0

		self:SetPData("Nexi", nexi);
	end

	/* Loads the player's nexi */
	function Player:loadNexi()
		local nexi = self:GetPData("Nexi", 0)

		self.Nexi = nexi
		self:syncNexi()
	end

	hook.Add("PlayerInitialSpawn", "PlayerInitialSpawn:LoadNexi", function(ply)
		ply:setNexi(100000000)
		ply:loadNexi()
	end)

	hook.Add("PlayerDisconnected", "PlayerDisconnected:SaveNexi", function(ply)
		ply:saveNexi()
	end)
end