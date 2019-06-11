local bags = bdUI.bags

--==================================================
-- Mail Helper Buttons
--==================================================
local open_all = CreateFrame("Button", nil, MailFrame, "UIPanelButtonTemplate")
open_all:SetPoint("TOPLEFT", MailFrame, "TOPLEFT", 80, -44)
open_all:SetText("Open All")
open_all:SetWidth(70)
open_all:SetHeight(24)
open_all:SetScript("OnClick", function()
	CheckInbox() 
	for m = GetInboxNumItems(), 1, -1 do 
		TakeInboxItem( m )
		TakeInboxMoney( m )
	end
end)

local open_money = CreateFrame("Button", nil, MailFrame, "UIPanelButtonTemplate")
open_money:SetPoint("TOPRIGHT", MailFrame, "TOPRIGHT", -50, -44)
open_money:SetText("Open Money")
open_money:SetWidth(94)
open_money:SetHeight(24)
open_money:SetScript("OnClick", function()
	CheckInbox() 
	for m = GetInboxNumItems(), 1, -1 do 
		TakeInboxMoney( m ) 
	end
end)

--==================================================
-- Sell Junk
--==================================================
bdUI:RegisterEvent('MERCHANT_SHOW', function()
	if CanMerchantRepair() then
		local cost = GetRepairAllCost()
		if GetGuildBankWithdrawMoney() >= cost then
			RepairAllItems(1)
		elseif GetMoney() >= cost then
			RepairAllItems()
		end
	end

	local profit = 0
	for bag = 0, 4 do
		for slot = 0, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link and select(3, GetItemInfo(link)) == 0 then
				local price = select(11, GetItemInfo(link))
				if (price) then
					profit = profit + price
				end
				UseContainerItem(bag, slot)
			end
		end
	end
	if (profit > 0) then
		print(("Sold all trash for %d|cFFF0D440"..GOLD_AMOUNT_SYMBOL.."|r %d|cFFC0C0C0"..SILVER_AMOUNT_SYMBOL.."|r %d|cFF954F28"..COPPER_AMOUNT_SYMBOL.."|r"):format(profit / 100 / 100, (profit / 100) % 100, profit % 100));
	end
end)

--==================================================
-- Fast Loot
--==================================================
bdUI:RegisterEvent("LOOT_OPENED", function()
	-- local autoLoot = GetCVar("autoLootDefault") == "0" or true

	if (not IsShiftKeyDown()) then
		local numitems = GetNumLootItems()
        for i = 1, numitems do
            LootSlot(i)
        end
	end
end)