local loader = CreateFrame("frame", nil, bdParent)
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, addon)
	if (addon == bdUI.name) then
		loader:UnregisterEvent("ADDON_LOADED")
		bdUI:do_action("preload")

		BDUI_SAVE = BDUI_SAVE or {}
		bdUI.config = BDUI_SAVE
		bdMove:set_save("BDUI_SAVE")
		bdMove.spacing = 10

		bdUI:print("Loaded. Enjoy.")
		bdUI:do_action("loaded")
	end
end)