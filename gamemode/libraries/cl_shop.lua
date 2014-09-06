
net.Receive("Shop_UpdateClientItems", function()
	local items = net.ReadString() or " "
	local equiped = net.ReadString() or " "

	timer.Create("timers_r_gay", 0.1, 0, function()
		if (LocalPlayer() and IsValid(LocalPlayer())) then
			LocalPlayer().Items = util.JSONToTable(items)
			LocalPlayer().Equiped = util.JSONToTable(equiped)
			timer.Destroy("timers_r_gay")
			MsgN("UPDATED")
		end
	end)
end)

local function createShopGUI()
	local function getItemsForCategory(sCat)
		local tbl = {}

		for k,v in pairs(shop.Items) do
			if (v.category == sCat) then
				tbl[k] = v
			end
		end

		return tbl
	end

	local frame = vgui.Create("DFrame")
	frame:SetSize(ScrW() / 2, ScrH() / 2)
	frame:Center()
	frame:SetTitle(" ")
	frame:MakePopup()
	frame:ShowCloseButton(false)

	local catScroll = vgui.Create("DScrollPanel", frame)
	catScroll:SetSize(100, frame:GetTall() - 5)
	catScroll:SetPos(0, 5)

	local catList = vgui.Create("DIconLayout")
	catScroll:AddItem(catList)
	catList:SetSize(catScroll:GetWide(), catScroll:GetTall())
	catList:SetPos(0, 0)
	catList:SetSpaceY(0)

	local itScroll = vgui.Create("DScrollPanel", frame)
	itScroll:SetSize(frame:GetWide() - 105, frame:GetTall() - 35)
	itScroll:SetPos(105, 0)

	local itList = vgui.Create("DIconLayout")
	itScroll:AddItem(itList)
	itList:SetSize(itScroll:GetWide() - 10, itScroll:GetTall())
	itList:SetPos(0, 0)
	itList:SetSpaceY(1)

	local close = vgui.Create("DButton", frame)
	close:SetSize(150, 25)
	close:SetPos(frame:GetWide() - close:GetWide() - 5, frame:GetTall() - close:GetTall() - 5)
	close:SetText("Close")
	function close:DoClick()
		frame:Remove()
	end

	local function populateItemList(items)
		itList:Clear()

		for k,v in pairs(items) do
			local pnl = vgui.Create("DPanel", itList)
			pnl:SetSize(itList:GetWide(), 75)

			local it = vgui.Create("DLabel", pnl)
			it:SetPos(0, 5)
			it:SetText(k)
			it:SizeToContents()
			it:CenterHorizontal()
			it:SetTextColor(Color(0, 0, 0, 255))

			local sell = vgui.Create("DLabel", pnl)
			
			local txt = "Cost: "..v.price.." Nexi"
			if (v.canSell and LocalPlayer():ownsItem(k)) then
				txt = "Refund: "..v.sell.." Nexi"
			elseif (!v.canSell and LocalPlayer():ownsItem(k)) then
				txt = "No refund"
			end

			surface.SetFont(it:GetFont())
			local w,h = surface.GetTextSize(txt)

			local costp = vgui.Create("DPanel", pnl)
			costp:SetPos(pnl:GetWide() - 150 - 5, 0)
			costp:SetSize(150, 25)


			local cost = vgui.Create("DLabel", costp)
			cost:SetPos(0, 5)
			cost:SetText(txt)
			cost:SizeToContents()
			cost:SetTextColor(Color(0, 0, 0, 255))
			cost:CenterHorizontal()

			if (v.display.type == "material") then

				local mat = vgui.Create("DPanel", pnl)
				mat:SetSize(65, 65)
				mat:SetPos(5, 5)
				function mat:Paint(width, height)
					surface.SetMaterial(Material(v.display.path, "noclamp"))
					surface.SetDrawColor(Color(255, 255, 255, 255))
					surface.DrawTexturedRect(0, 0, width, height)
				end

			elseif (v.display.type == "model") then

				local mod = vgui.Create("DModelPanel", pnl)
				mod:SetSize(65, 65)
				mod:SetPos(5, 5)
				mod:SetModel(Model(v.display.path))

			end

			local desc = vgui.Create("DLabel", pnl)
			desc:SetPos(75, 30)
			desc:SetSize(pnl:GetWide() - 75 - 155, pnl:GetTall() - 40)
			desc:SetText(v.description or "No description")
			desc:SetWrap(true)
			desc:SetTextColor(Color(0, 0, 0, 255))


			if (LocalPlayer():ownsItem(k)) then
				local eq = vgui.Create("DButton", pnl)
				eq:SetSize(150, 25)
				eq:SetPos(pnl:GetWide() - eq:GetWide() - 5, pnl:GetTall() - eq:GetTall() - 30)
				
				local t = "Equip"
				local eqi = LocalPlayer():getEquipedPerCategory(v.category)

				if (eqi[k]) then
					t = "Holster"
				else
					local catMax = shop.Categories[v.category].maxEquiped
					if (#eqi + 1 > catMax) then
						eq:SetDisabled(true)
						eq:SetToolTip("You can't equip any more for this category!")							
					end
				end

				function eq:DoClick()
					if (eqi[k]) then
						net.Start("Shop_HolsterItem")
							net.WriteString(k)
						net.SendToServer()
					else
						net.Start("Shop_EquipItem")
							net.WriteString(k)
						net.SendToServer()
					end
				end

				
				eq:SetText(t)

				local sell = vgui.Create("DButton", pnl)
				sell:SetSize(150, 25)
				sell:SetText("Sell")
				sell:SetPos(pnl:GetWide() - sell:GetWide() - 5, pnl:GetTall() - sell:GetTall() - 5)

				if (!v.canSell) then
					sell:SetDisabled(true)
					sell:SetToolTip("This item is un-sellable!")
				end

				function sell:DoClick()
					net.Start("Shop_SellItem")
						net.WriteString(k)
					net.SendToServer()
				end

			else
			
				local buy = vgui.Create("DButton", pnl)
				buy:SetSize(150, 25)
				buy:SetText("Buy")
				buy:SetPos(pnl:GetWide() - buy:GetWide() - 5, pnl:GetTall() - buy:GetTall() - 5)

				if (!LocalPlayer():canAfford(v.price)) then
					buy:SetDisabled(true)
					buy:SetText("You can't afford this!")
				end

				function buy:DoClick()
					net.Start("Shop_BuyItem")
						net.WriteString(k)
					net.SendToServer()
				end
			end
		end
	end

	local ct = 0
	for k,v in pairs(shop.Categories or {}) do
		local catBtn = vgui.Create("DButton", catList)
		catBtn:SetSize(catList:GetWide(), 25)
		catBtn:SetText(k)
		if (v.image) then
			catBtn:SetImage(v.image)
		end
		function catBtn:DoClick()
			local items = getItemsForCategory(k)
			
			populateItemList(items)
		end

		if (ct == 0) then
			local items = getItemsForCategory(k)

			populateItemList(items)
		end
	end
end
concommand.Add("shop", createShopGUI)