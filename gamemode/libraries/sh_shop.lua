shop = shop or {}
shop.Items = shop.Items or {}
shop.Categories = shop.Categories or {}

local function defineItem(sName, tItem)
	if (not istable(tItem)) then ErrorNoHalt("Attempted to register invalid item type.") return end
	if (shop.Items[sName]) then ErrorNoHalt("Attempted to register duplicate item. Name "..sName) return end
	
	shop.Items[sName] = tItem
end

local ply = FindMetaTable("Player")
function ply:ownsItem(sName) 
	local items = self.Items or {}
	return items[sName]
end

function ply:getEquipedPerCategory(sCategory)
	local sCategory = sCategory or " "
	local items = {}
	if (SERVER) then items = self.equipedItems else items = self.Equiped end
	local temp = {}

	for k,v in pairs(items or {}) do
		if (shop.Items[k] && shop.Items[k].category == sCategory) then
			temp[k] = true
		end
	end

	return temp
end

shop.Categories["Player Models"] = {
	maxEquiped = 1,
	image = "icon16/user.png"
}

shop.Categories["Player Color"] = {
	maxEquiped = 1,
	image = "icon16/cake.png"
}



local models = {}
models["Charple"] = "models/player/charple.mdl"
models["Alyx"] = "models/player/alyx.mdl"
models["Leet"] = "models/player/leet.mdl"
models["Phoenix"] = "models/player/phoenix.mdl"

for k,v in pairs(models) do
	defineItem(k, {
		category = "Player Models",
		price = 100,
		canSell = true,
		sell = 50,
		description = "A smexy player model.",
		display = {
			type = "model",
			path = v
		},
		onEquip = function(item, ply)
			ply._oldModel = ply:GetModel() //the model isn't set yet, i need to fix this.	


			timer.Simple(0.1, function()
				ply:SetModel(Model(v)) //let the default model get set blah
			end)

			hook.Add("PlayerSpawn", "PlayerSpawn:Model_"..ply:SteamID(), function(p)				
				if (p == ply) then timer.Simple(0.1, function() p:SetModel(Model(v)) end) end
				
				print(v)
			end)
		end,
		onHolster = function(item, ply)
			hook.Remove("PlayerSpawn", "PlayerSpawn:Model_"..ply:SteamID())
			ply:SetModel(ply._oldModel)
			print("REMOVED MODEL")
			ply._oldModel = nil
		end,
		canBuy = function(ply)

		end
	})
end

defineItem("Rainbow", {
	category = "Player Color",
	price = 100,
	canSell = true,
	sell = 50,
	//allowedGroups = {"user"},
	description = "Become fucking amazing.",
	display = {
		type = "material", //material or model.
		path = "icon16/wand.png" //path to it duhhh
	},
	onEquip = function(tItemObject, ply) //called when the player equips the item.
		ply._oldColor = ply:GetColor()

		local id = ply:SteamID()

		hook.Add("Think", "Think:Test_"..id, function()
			if (!IsValid(ply)) then hook.Remove("Thinnk", "Think:Test_"..id) end

			local time = CurTime()
			local r = math.abs(math.sin(time * 2) * 255)
			local g = math.abs(math.sin(time * 2 + 2) * 255)
			local b = math.abs(math.sin(time * 2 + 4) * 255)
			ply:SetColor(Color( r, g, b ))
		end)
	end,
	onHolster = function(tItemObject, ply) //called when the player dequips the item.
		hook.Remove("Think", "Think:Test_"..ply:SteamID())
		ply:SetColor(ply._oldColor)
		ply._oldColor = nil
	end,
	canBuy = function(ply) //called before the player buys the item. Return true or false.

	end
})
