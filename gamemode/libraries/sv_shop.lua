util.AddNetworkString("Shop_BuyItem")
util.AddNetworkString("Shop_SellItem")
util.AddNetworkString("Shop_GiftItem")
util.AddNetworkString("Shop_EquipItem")
util.AddNetworkString("Shop_HolsterItem")
util.AddNetworkString("Shop_UpdateClientItems")

local Player = FindMetaTable("Player")

function Player:ShopNotify(text)
	self:PrintMessage(HUD_PRINTTALK, text)
end

function Player:equipItem(sName)
	if (not self.equipedItems) then self.equipedItems = {} end
	if (not self:canEquip(sName)) then self:ShopNotify("You can't equip this!") return end
	
	local item = shop.Items[sName]
	if (not item) then self:ShopNotify("Item not found!") return end
	
	self.equipedItems[sName] = true
	item.onEquip(item, self)
	self:updateClientItems()
end

function Player:holsterItem(sName)
	if (not self:getEquiped(sName)) then return end
	
	local item = shop.Items[sName]

	if (not item) then self:ShopNotify("Item not found!") return end

	self.equipedItems[sName] = nil
	item.onHolster(item, self)
	self:updateClientItems()
end

function Player:getEquiped(sName)
	return self.equipedItems[sName]
end

function Player:getEquipedPerCategory(sCategory)
	local sCategory = sCategory or " "
	local items = self.equipedItems or {}
	local temp = {}

	for k,v in pairs(items) do
		if (shop.Items[k] && shop.Items[k].category == sCategory) then
			temp[k] = true
		end
	end

	return temp
end

function Player:canEquip(sName)
	local equiped = self.equipedItems or {}

	local item = shop.Items[sName] or {}
	local all = self:getEquipedPerCategory(item.category)

	if (equiped[sName]) then return false end
	if (#all + 1 > shop.Categories[item.category].maxEquiped) then return false end

	return true
end

function Player:canBuy(sName)
	local item = shop.Items[sName]
	if (not item) then return false, "Item not found!" end

	local price = item.price or 0
	if (not self:canAfford(price)) then return false, "you can't afford it!" end
	
	local groups = item.allowedGroups
	if (groups and not groups[self:GetNWString("UserGroup")]) then return false, "you aren't the right group!" end
	
	return true
end

function Player:canSell(sName)
	local item = shop.Items[sName]
	if (not item) then return false, "item not found!" end
	if (not item.canSell) then return false, "this item is non-sellable!" end
	if (not self.Items[sName]) then return false, "you don't own this!" end
	
	return true
end

function Player:updateClientItems()
	local items = util.TableToJSON(self.Items)
	local equiped = util.TableToJSON(self.equipedItems)
	//print(items, equiped)
	net.Start("Shop_UpdateClientItems")
		net.WriteString(items) //yes i know this is horrible :v
		net.WriteString(equiped) //but i will change it to a much more efficient way later.
	net.Send(self)
end

function Player:saveItems()
	if (not file.IsDir("nexus_items", "DATA")) then file.CreateDir("nexus_items") end
	
	local tbl = {}
	for k,v in pairs(self.Items) do
		if (self.equipedItems[k]) then
			tbl[k] = true

			continue
		end
		tbl[k] = false
	end

	local item_data = util.TableToJSON(tbl)

	local id = self:UniqueID()
	if (file.Exists("nexus_items/"..id..".txt", "DATA")) then file.Delete("nexus_items/"..id..".txt") end

	file.Write("nexus_items/"..id..".txt", item_data)
end

function Player:loadItems()
	local item_data = file.Read("nexus_items/"..self:UniqueID()..".txt", "DATA")
	if (not item_data) then self:ShopNotify("Failed to properly load item data! Notify a dev!") return end

	local items = util.JSONToTable(item_data)
	if (not items) then self:ShopNotify("Failed to parse item data! Notify a dev!") return end
	
	self.Items = {}
	self.equipedItems = {}

	for k,v in pairs(items) do
		if (v) then 
			hook.Add("PlayerSpawn", "Player:Spawn_"..self:SteamID().."_"..k, function(ply)
				local item = shop.Items[k]

				item.onEquip(item, self)
				self:updateClientItems()

				hook.Remove("PlayerSpawn", "Player:Spawn_"..self:SteamID().."_"..k)
			end)
			self.equipedItems[k] = true
		end
		self.Items[k] = true
	end

	self:updateClientItems()
end

function Player:buyItem(name)
	if (not self.Items) then self.Items = {} end

	self.Items[name] = true
	self:equipItem(name)
	self:updateClientItems()
	self:takeNexi(shop.Items[name].price or 0)

	self:PrintMessage(HUD_PRINTTALK, "You bought "..name.." for "..(shop.Items[name].price or 0).." Nexi!")
end

function Player:sellItem(name)
	if (not self.Items) then self.Items = {} end

	self.Items[name] = nil
	self:holsterItem(name)
	self:updateClientItems()
	self:addNexi(shop.Items[name].sell or 0)

	self:PrintMessage(HUD_PRINTTALK, "You have successfully sold "..name.." for "..(shop.Items[name].sell or 0).." Nexi!")
end

net.Receive("Shop_BuyItem", function(l, ply)
	local name = net.ReadString()

	if (!shop.Items[name]) then ply:ShopNotify("No item found with the name "..name) return end
	
	local canbuy, reason = ply:canBuy(name)
	if (not canbuy) then ply:ShopNotify("You can't buy this item because "..reason) return end

	ply:saveItems()
	ply:buyItem(name)
end)

net.Receive("Shop_SellItem", function(l, ply)
	local name = net.ReadString()

	if (!shop.Items[name]) then ply:ShopNotify("No item found with the name "..name) return end
	
	local cansell, reason = ply:canSell(name)
	if (not cansell) then ply:ShopNotify("You can't sell this item because "..reason) return end
	
	ply:saveItems()
	ply:sellItem(name)
end)

net.Receive("Shop_EquipItem", function(l, ply)
	local name = net.ReadString()

	ply:equipItem(name)
end)

net.Receive("Shop_HolsterItem", function(l, ply)
	local name = net.ReadString()

	ply:holsterItem(name)
end)

hook.Add("PlayerInitialSpawn", "PlayerInitialSpawn:Loaditems", function(ply)
	ply:loadItems()
	ply:setNexi(1000000)
end)

hook.Add("PlayerDisconnected", "PlayerDisconnected:SaveItems", function(ply)
	for k,v in pairs(ply.equipedItems) do
		shop.Items[k].onHolster(shop.Items[k], ply)
	end

	ply:saveItems()
end)