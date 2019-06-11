bdUI = {}
bdUI[1] = CreateFrame("Frame", nil, UIParent) -- core ui
bdUI[2] = {} -- config
bdUI[3] = {} -- profile
bdUI.oUF = oUF.oUF
bdUI.name = debugstack():match[[\AddOns\(.-)\]]

function bdUI:unpack()
	return self[1], self[2], self[3]
end

--===================================================================
-- Basic Config
--===================================================================
bdUI.media = {
	flat = "Interface\\Buttons\\WHITE8x8",
	smooth = "Interface\\Addons\\bdUI_TBC\\media\\smooth.tga",
	arial = "fonts\\ARIALN.ttf",
	font = "Interface\\Addons\\bdUI_TBC\\media\\myriad.ttf",
	bold = "Interface\\Addons\\bdUI_TBC\\media\\homizio_bold.ttf",
	arrow = "Interface\\Addons\\bdUI_TBC\\media\\arrow.blp",
	arrowup = "Interface\\Addons\\bdUI_TBC\\media\\arrowup.blp",
	arrowdown = "Interface\\Addons\\bdUI_TBC\\media\\arrowdown.blp",
	shadow = "Interface\\Addons\\bdUI_TBC\\media\\shadow.blp",
	fonts = {},
	fontsize = 14,
	fontoutline = "THINOUTLINE",
	backgrounds = {},
	border = {.06, .08, .09, 1},
	backdrop = {.11,.15,.18, 1},
	red = {['r'] = .62, ['g'] = .17, ['b'] = .18, ['a'] = 1},
	blue = {['r'] = .2, ['b'] = .4, ['g'] = 0.8, ['a'] = 1},
	green = {['r'] = .1, ['b'] = .7, ['g'] = 0.3, ['a'] = 1},
}

--===================================================================
-- Scale & Alt-UIParent 
--===================================================================
bdUI.colorString = '|cffA02C2Fbd|r'
bdUI.scale = 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)")
bdUI.ui_scale = GetCVar("uiScale") or 1
bdUI.pixel = bdUI.scale / bdUI.ui_scale
bdUI.border = bdUI. pixel * 2

bdParent = CreateFrame("frame", "bdUIParent", UIParent)
bdParent:SetPoint("TOPLEFT", UIParent)
bdParent:SetPoint("BOTTOMRIGHT", UIParent)
bdParent:SetScale(bdUI.scale)

bdUI.hidden = CreateFrame("frame", nil, nil)
bdUI.hidden:Hide()
bdUI.hidden:SetAlpha(0)
bdUI.hidden:SetScale(0.001)
bdUI.hidden.Show = function() return end

--===================================================================
-- Fonts
--===================================================================
bdUI.font_large = CreateFont("BDUI_LARGE")
bdUI.font_large:SetFont(bdUI.media.font, 15)
bdUI.font_large:SetShadowColor(0, 0, 0)
bdUI.font_large:SetShadowOffset(0, 0)

bdUI.font_medium = CreateFont("BDUI_MEDIUM")
bdUI.font_medium:SetFont(bdUI.media.font, 13)
bdUI.font_medium:SetShadowColor(0, 0, 0)
bdUI.font_medium:SetShadowOffset(0, 0)

bdUI.font_small = CreateFont("BDUI_MONO")
bdUI.font_small:SetFont(bdUI.media.font, 11)
bdUI.font_small:SetShadowColor(0, 0, 0)
bdUI.font_small:SetShadowOffset(0, 0)

--===================================================================
--Return game version, so that we can have cross version compatibility when possible
--===================================================================
local versions = {}
versions[20400] = "tbc"
function bdUI:get_game_version()
	local version, build, date, tocversion = GetBuildInfo()

	local game = 0
	local vers = 0

	for k, v in pairs(versions) do
		if (k < tocversion and k > vers) then 
			vers = k 
			game = v
		end
	end

	return game
end