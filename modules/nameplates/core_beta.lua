local bdUI, c, p = bdUI:unpack()

-- Module
local module_name = "bdNameplates"
bdUI[module_name] = CreateFrame("frame", module_name, bdParent)
local mod = bdUI[module_name]

-- Config
local config = {}
config.enabled = true


--===============================================
-- Custom functionality
-- place custom functionality here
--===============================================
local numChildren = 0
local plateID = 0
m.has_target = false
m.created_plates = {}
m.visible_plates = {}
m.healers = {}
local healClasses = {
	["DRUID"] = true,
	["HUNTER"] = false,
	["MAGE"] = false,
	["PALADIN"] = true,
	["PRIEST"] = true,
	["ROGUE"] = false,
	["SHAMAN"] = true,
	["WARLOCK"] = false,
	["WARRIOR"] = false
}
local RaidIconCoordinate = {
	[0] = {[0] = "STAR", [0.25] = "MOON"},
	[0.25] = {[0] = "CIRCLE", [0.25] = "SQUARE"},
	[0.5] = {[0] = "DIAMOND", [0.25] = "CROSS"},
	[0.75] = {[0] = "TRIANGLE", [0.25] = "SKULL"}
}

-- Destroy element off of nameplate
function mod:remove_element(element)
	local objectType = element:GetObjectType()
	if objectType == "Texture" then
		element:SetTexture("")
		element:SetTexCoord(0, 0, 0, 0)
	elseif objectType == "FontString" then
		element:SetWidth(0.001)
	elseif objectType == "StatusBar" then
		element:SetStatusBarTexture("")
	end
	element:Hide()
end

-- Register Nameplates from the WorldFrame
function mod:scan_nameplates()
	local count = select("#", WorldGetChildren(WorldFrame))
	if count ~= numChildren then
		local frame, region
		for i = numChildren + 1, count do
			frame = select(i, WorldGetChildren(WorldFrame))
			region = select(2, frame:GetRegions())

			if (not m.created_plates[frame] and region and region:GetObjectType() == "Texture" and region:GetTexture() == [=[Interface\Tooltips\Nameplate-Border]=]) then
				m:register_nameplate(frame)
			end
		end
		numChildren = count
	end

	for frame in pairs(m.visible_plates) do
		if m.has_target then
			frame.alpha = frame:GetParent():GetAlpha()
		else
			frame.alpha = 1
		end

		frame:GetParent():SetAlpha(1)

		frame.isTarget = m.has_target and frame.alpha == 1
	end
end

-- Main nameplate registration & skinning
function mod:register_nameplate(frame)
	plateID = plateID + 1

	local healthbar, castbar = frame:GetChildren()
	local border, castbar_border, castbar_icon, highlight, name, level, bossicon, raidicon = frame:GetRegions()

	frame.unitFrame = CreateFrame("Frame", format("ElvUI_NamePlate%d", plateID), frame)
	frame.unitFrame:SetAllPoints(frame)
	frame.unitFrame.plateID = plateID
	mod:create_nameplate(frame.unitFrame, plateID)

	self:remove_element(HealthBar)
	self:remove_element(CastBar)
	self:remove_element(CastBarIcon)
	self:remove_element(CastBarBorder)
	self:remove_element(Level)
	self:remove_element(Name)
	self:remove_element(Border)
	self:remove_element(Highlight)
	-- CastBar:Kill()
	CastBarIcon:SetParent(bdUI.hidden)
	BossIcon:SetAlpha(0)

	frame.UnitFrame.oldHealthBar = HealthBar
	frame.UnitFrame.oldCastBar = CastBar
	frame.UnitFrame.oldCastBar.Icon = CastBarIcon
	frame.UnitFrame.oldName = Name
	frame.UnitFrame.oldHighlight = Highlight
	frame.UnitFrame.oldLevel = Level

	RaidIcon:SetParent(frame.UnitFrame)
	frame.UnitFrame.RaidIcon = RaidIcon
	frame.UnitFrame.BossIcon = BossIcon

	self.created_plates[frame] = true
	self.visible_plates[frame.UnitFrame] = true
end


--===============================================
-- Load Module
-- runs when saved variable are available
--===============================================
local function load()
	if (not config.enabled) then return end

	SetCVar("showVKeyCastbar", "1")

	m:SetScript("OnUpdate", m.scan_nameplates)
end

--===============================================
-- Callback on changes / inintialization
-- runs when the configuration changes
--===============================================
local function callback()

end

--===============================================
-- Register with the UI
-- handles a lot of other initialization
--===============================================
bdUI:register_module(name, load, config, callback)