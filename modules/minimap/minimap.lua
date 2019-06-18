-- Config
bdUI.minimap = CreateFrame("frame", nil, bdParent)
bdUI.minimap.config = {}

local config = bdUI.minimap.config
config.enabled = true
config.size = 300
config.buttonsize = 24


--===============================================
-- Load Module
-- runs when saved variable are available
--===============================================
local function load()
	-- make minimap shape square
	function GetMinimapShape() return "SQUARE" end

	local inset = ((config.size * .25) / 2)

	-- Rectangle
	Minimap.background = CreateFrame("frame", "bdMinimap", Minimap)
	Minimap.background:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
	Minimap.background:SetBackdrop({bgFile = bdUI.media.flat, edgeFile = bdUI.media.flat, edgeSize = bdUI.border})
	Minimap.background:SetBackdropColor(0,0,0,0)
	Minimap.background:SetBackdropBorderColor(unpack(bdUI.media.border))
	Minimap.background:SetWidth(config.size)
	Minimap.background:SetHeight(config.size*.75)
	Minimap:SetMaskTexture("Interface\\Addons\\bdUI_TBC\\media\\rectangle.tga")
	Minimap:SetWidth(config.size)
	Minimap:SetHeight(config.size)
	Minimap:EnableMouse(true)
	Minimap:ClearAllPoints()
	Minimap:SetPoint("TOPRIGHT", bdParent, "TOPRIGHT", -32, -10)
	bdMove:set_moveable(Minimap, nil, 0, 0)

	Minimap.SetHitRectInsets = Minimap.SetHitRectInsets or noop
	Minimap.SetClampRectInsets = Minimap.SetClampRectInsets or noop
	Minimap.SetArchBlobRingScalar = Minimap.SetArchBlobRingScalar or noop
	Minimap.SetQuestBlobRingScalar = Minimap.SetQuestBlobRingScalar or noop

	Minimap:SetHitRectInsets(0, 0, -inset, inset)
	Minimap:SetClampRectInsets(0, 0, -inset, inset)
	Minimap:SetArchBlobRingScalar(0);
	Minimap:SetQuestBlobRingScalar(0);

	-- Zone
	Minimap.zone = CreateFrame("frame", nil, Minimap)
	Minimap.zone:Hide()
	Minimap.zone.text = Minimap.zone:CreateFontString(nil)
	Minimap.zone.text:SetFontObject("BDUI_MEDIUM")
	Minimap.zone.text:SetPoint("TOPLEFT", Minimap.background, "TOPLEFT", 8, -8)
	Minimap.zone.text:SetJustifyH("LEFT")
	Minimap.zone.subtext = Minimap.zone:CreateFontString(nil)
	Minimap.zone.subtext:SetFontObject("BDUI_MEDIUM")
	Minimap.zone.subtext:SetPoint("TOPRIGHT", Minimap.background, "TOPRIGHT", -8, -8)
	Minimap.zone.subtext:SetJustifyH("RIGHT")
	Minimap.zone:RegisterEvent("ZONE_CHANGED")
	Minimap.zone:RegisterEvent("ZONE_CHANGED_INDOORS")
	Minimap.zone:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	Minimap.zone:RegisterEvent("PLAYER_ENTERING_WORLD")
	Minimap.zone:SetScript("OnEvent", function(self, event)
		Minimap.zone.text:SetText(GetZoneText())
		Minimap.zone.subtext:SetText(GetSubZoneText())
	end)
	-- Minimap.background:EnableMouse(true)
	Minimap:SetScript("OnEnter", function()
		Minimap.zone:Show()
	end)
	Minimap:SetScript("OnLeave", function()
		Minimap.zone:Hide()
	end)

	-- Clock
	if (not IsAddOnLoaded("Blizzard_TimeManager")) then
		LoadAddOn('Blizzard_TimeManager')
	end
	TimeManagerClockButton:SetAlpha(1)
	TimeManagerClockButton:Show()
	select(1, TimeManagerClockButton:GetRegions()):Hide()
	TimeManagerClockButton:ClearAllPoints()
	TimeManagerClockButton:SetPoint("BOTTOMLEFT", Minimap.background, "BOTTOMLEFT", 5, -2)
	TimeManagerClockButton.SetPoint = noop
	TimeManagerClockTicker:SetFont(bdUI.media.font, 14,"OUTLINE")
	TimeManagerClockTicker:SetAllPoints(TimeManagerClockButton)
	TimeManagerClockTicker.SetPoint = noop
	TimeManagerClockTicker:SetJustifyH('LEFT')
	TimeManagerClockTicker:SetShadowColor(0,0,0,0)

	-- Right click calendar
	Minimap:SetScript('OnMouseUp', function (self, button)
		if button == 'RightButton' then
			ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, Minimap.background, (Minimap:GetWidth()), (Minimap.background:GetHeight()-2))
			GameTooltip:Hide()
		elseif button == 'MiddleButton' then
			if not IsAddOnLoaded("Blizzard_Calendar") then
				LoadAddOn('Blizzard_Calendar')
			end
			Calendar_Toggle()
		else
			Minimap_OnClick(self)
		end
	end)

	-- Better fail frame and function
	bdUI:RegisterEvent("MAIL_INBOX_UPDATE, MAIL_CLOSED", function(self, event)
		if (event == "MAIL_CLOSED") then
			CheckInbox();
		else
			InboxFrame_Update()
			OpenMail_Update()
		end
	end)
	MiniMapMailIcon:SetTexture(nil)
	MiniMapMailFrame.mail = MiniMapMailFrame:CreateFontString(nil,"OVERLAY")
	MiniMapMailFrame.mail:SetFont(bdUI.media.font, 16)
	MiniMapMailFrame.mail:SetText("M")
	MiniMapMailFrame.mail:SetJustifyH("CENTER")
	MiniMapMailFrame.mail:SetPoint("CENTER",MiniMapMailFrame,"CENTER",1,-1)
	MiniMapMailBorder:Hide()

	-- Dropdown position & scroll zoom
	function dropdownOnClick(self)
		GameTooltip:Hide()
		DropDownList1:ClearAllPoints()
		DropDownList1:SetPoint('TOPLEFT', Minimap.background, 'TOPRIGHT', 2, 0)
	end

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript('OnMouseWheel', function(self, delta)
		if delta > 0 then
			MinimapZoomIn:Click()
		elseif delta < 0 then
			MinimapZoomOut:Click()
		end
	end)

	-- Hide textures
	local frames = {
		"MiniMapVoiceChatFrame", -- out in BFA
		"MiniMapWorldMapButton",
		"MinimapZoneTextButton",
		"MiniMapMailBorder",
		"MiniMapInstanceDifficulty",
		"MinimapNorthTag",
		"MinimapZoomOut",
		"MinimapZoomIn",
		"MinimapBackdrop",
		"GameTimeFrame",
		"GuildInstanceDifficulty",
		"MiniMapChallengeMode",
		"MinimapBorderTop",
		"MinimapBorder",
		-- "MiniMapTracking",
		"MinimapToggleButton",
	}
	for i = 1, (getn(frames)) do
		if (_G[frames[i]]) then
			_G[frames[i]]:Hide()
			_G[frames[i]].Show = noop
		end
	end

	-- Fixes some bugs with the mailframe updating properly
	local mailupdate = CreateFrame("frame")
	mailupdate:RegisterEvent("MAIL_CLOSED")
	mailupdate:RegisterEvent("MAIL_INBOX_UPDATE")
	mailupdate:SetScript("OnEvent",function(self, event)
		if (event == "MAIL_CLOSED") then
			CheckInbox();
		else
			InboxFrame_Update()
			OpenMail_Update()
		end
	end)


	bdUI.minimap:create_button_frame()
end

--===============================================
-- Callback on changes / inintialization
-- runs when the configuration changes
--===============================================
local function callback()

end

bdUI:register_module("Minimap", load, config, callback)




