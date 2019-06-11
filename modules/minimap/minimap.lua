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
	-- Minimap:SetHitRectInsets(0, 0, config.size/8, config.size/8)
	-- Minimap:SetClampRectInsets(0, 0, -config.size/4, -config.size/4)
	Minimap:EnableMouse(true)
	-- Minimap:SetArchBlobRingScalar(0);
	-- Minimap:SetQuestBlobRingScalar(0);
	Minimap:ClearAllPoints()
	Minimap:SetPoint("TOPRIGHT", bdParent, "TOPRIGHT", -30, -10)

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




