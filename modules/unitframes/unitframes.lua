-- Module
local module_name = "bdUnitframes"
bdUI[module_name] = CreateFrame("frame", module_name, bdParent)
local m = bdUI[module_name]
local oUF = bdUI.oUF
local LMH = LibStub("LibMobHealth-4.0")
oUF.colors.power[0] = {46/255, 130/255, 215/255}

-- Config
local config = {}
config.enabled = true
config.playertargetwidth = 200
config.playertargetheight = 18
config.playertargetpowerheight = 2
config.targetoftargetwidth = 100
config.targetoftargetheight = 14
config.inrangealpha = 1
config.outofrangealpha = 0.5
config.castbarheight = 12
config.padding = 2


--===============================================
-- Custom functionality
-- place custom functionality here
--===============================================
local additional_elements = {
	castbar = function(self, unit, align)
		local font_size = math.restrict(config.castbarheight * 0.85, 8, 14)

		self.Castbar = CreateFrame("StatusBar", nil, self)
		self.Castbar:SetFrameLevel(3)
		self.Castbar:SetStatusBarTexture(bdUI.media.flat)
		self.Castbar:SetStatusBarColor(.1, .4, .7, 1)
		self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -4)
		self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -(4 + config.castbarheight))
		
		self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
		self.Castbar.Text:SetFont(bdUI.media.font, font_size, "OUTLINE")
		self.Castbar.Text:SetJustifyV("MIDDLE")

		self.Castbar.Icon = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		self.Castbar.Icon:SetDrawLayer('ARTWORK')
		self.Castbar.Icon.bg = self.Castbar:CreateTexture(nil, "BORDER")
		self.Castbar.Icon.bg:SetTexture(bdUI.media.flat)
		self.Castbar.Icon.bg:SetVertexColor(unpack(bdUI.media.border))
		self.Castbar.Icon.bg:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -bdUI.border, bdUI.border)
		self.Castbar.Icon.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", bdUI.border, -bdUI.border)

		self.Castbar.SafeZone = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.SafeZone:SetVertexColor(0.85, 0.10, 0.10, 0.20)
		self.Castbar.SafeZone:SetTexture(bdUI.media.flat)

		self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY")
		self.Castbar.Time:SetFont(bdUI.media.font, font_size, "OUTLINE")

		-- Positioning
		if (align == "right") then
			self.Castbar.Time:SetPoint("RIGHT", self.Castbar, "RIGHT", -config.padding, 0)
			self.Castbar.Time:SetJustifyH("RIGHT")
			self.Castbar.Text:SetPoint("LEFT", self.Castbar, "LEFT", config.padding, 0)
			self.Castbar.Icon:SetPoint("TOPLEFT", self.Castbar,"TOPRIGHT", config.padding*2, 0)
			self.Castbar.Icon:SetSize(config.castbarheight * 1.5, config.castbarheight * 1.5)
		else
			self.Castbar.Time:SetPoint("LEFT", self.Castbar, "LEFT", config.padding, 0)
			self.Castbar.Time:SetJustifyH("LEFT")
			self.Castbar.Text:SetPoint("RIGHT", self.Castbar, "RIGHT", -config.padding, 0)
			self.Castbar.Icon:SetPoint("TOPRIGHT", self.Castbar,"TOPLEFT", -config.padding*2, 0)
			self.Castbar.Icon:SetSize(config.castbarheight * 1.5, config.castbarheight * 1.5)
		end

		bdUI:set_backdrop(self.Castbar)
	end,

	resting = function(self, unit)
		local size = math.restrict(self:GetHeight() * 0.75, 8, 14)

		-- Resting indicator
		self.RestingIndicator = self.Health:CreateTexture(nil, "OVERLAY")
		self.RestingIndicator:SetPoint("LEFT", self.Health, config.padding, 2)
		self.RestingIndicator:SetSize(size, size)
		self.RestingIndicator:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
		self.RestingIndicator:SetTexCoord(0, 0.5, 0, 0.421875)
	end,

	combat = function(self, unit)
		local size = math.restrict(self:GetHeight() * 0.75, 8, 14)

		-- Resting indicator
		self.CombatIndicator = self.Health:CreateTexture(nil, "OVERLAY")
		self.CombatIndicator:SetPoint("RIGHT", self.Health, -config.padding, 2)
		self.CombatIndicator:SetSize(size, size)
		self.CombatIndicator:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
		self.CombatIndicator:SetTexCoord(.5, 1, 0, .49)
	end,

	power = function(self, unit)
		-- Power
		self.Power = CreateFrame("StatusBar", nil, self)
		self.Power:SetStatusBarTexture(bdUI.media.flat)
		self.Power:ClearAllPoints()
		self.Power:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, bdUI.border)
		self.Power:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, bdUI.border)
		self.Power:SetHeight(config.playertargetpowerheight)
		self.Power.frequentUpdates = true
		self.Power.colorPower = true
		self.Power.Smooth = true
		bdUI:set_backdrop(self.Power)
	end,

	buffs = function(self, unit)
		-- Auras
		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetPoint("BOTTOMLEFT", self.Power, "TOPLEFT", 0, 4)
		self.Buffs:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 4)
		self.Buffs:SetSize(config.playertargetwidth, 60)
		self.Buffs.size = 18
		self.Buffs.initialAnchor  = "BOTTOMLEFT"
		self.Buffs.spacing = bdUI.border
		self.Buffs.num = 20
		self.Buffs['growth-y'] = "UP"
		self.Buffs['growth-x'] = "RIGHT"
		self.Buffs.PostCreateIcon = function(buffs, button)
			bdUI:set_backdrop(button)
			button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			button:SetAlpha(0.8)
		end
	end,

	debuffs = function(self, unit)
		-- Auras
		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs:SetPoint("BOTTOMLEFT", self.Power, "TOPLEFT", 0, 4)
		self.Debuffs:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 4)
		self.Debuffs:SetSize(config.playertargetwidth, 60)
		self.Debuffs.size = 18
		self.Debuffs.initialAnchor  = "BOTTOMRIGHT"
		self.Debuffs.spacing = bdUI.border
		self.Debuffs.num = 20
		self.Debuffs['growth-y'] = "UP"
		self.Debuffs['growth-x'] = "LEFT"
		self.Debuffs.PostCreateIcon = function(Debuffs, button)
			bdUI:set_backdrop(button)
			button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			button:SetAlpha(0.8)
		end
	end,

	auras = function(self, unit)
		-- Auras
		self.Auras = CreateFrame("Frame", nil, self)
		self.Auras:SetPoint("BOTTOMLEFT", self.Power, "TOPLEFT", 0, 4)
		self.Auras:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 0, 4)
		self.Auras:SetSize(config.playertargetwidth, 60)
		self.Auras.size = 18
		self.Auras.initialAnchor  = "BOTTOMLEFT"
		self.Auras.spacing = bdUI.border
		self.Auras.num = 20
		self.Auras['growth-y'] = "UP"
		self.Auras['growth-x'] = "RIGHT"
		self.Auras.PostCreateIcon = function(Debuffs, button)
			bdUI:set_backdrop(button)
			button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			button:SetAlpha(0.8)
		end
	end,
}

local custom_layout = {
	player = function(self, unit)
		additional_elements.castbar(self, unit, "left")
		additional_elements.resting(self, unit)
		additional_elements.combat(self, unit)
		additional_elements.power(self, unit)
		additional_elements.buffs(self, unit)

		self.Buffs.CustomFilter = function(element, unit, button, name, rank, texture, count, debuffType, duration, expiration)
			if (UnitIsUnit(unit, "player") and duration ~= 0 and duration < 180) then
				return true 
			end

			return false
		end

		self:SetSize(config.playertargetwidth, config.playertargetheight)

		self.Name:SetPoint("TOPRIGHT", self.Power, "TOPLEFT", -4, bdUI.border)
		self.Curhp:SetPoint("RIGHT", self.Health, "LEFT", -4, -4)
	end,
	target = function(self, unit)
		additional_elements.castbar(self, unit, "right")
		additional_elements.power(self, unit)
		additional_elements.buffs(self, unit)
		additional_elements.debuffs(self, unit)

		self.Debuffs.initialAnchor  = "BOTTOMLEFT"
		self.Debuffs['growth-x'] = "RIGHT"
		-- self.Auras.CustomFilter = function(element, unit, button, name, rank, texture, count, debuffType, duration, expiration)
		-- 	print(unit)
		-- 	print(duration)
		-- end

		self.Buffs:ClearAllPoints()
		self.Buffs:SetPoint("BOTTOMLEFT", self.Power, "TOPRIGHT", 6, 4)
		self.Buffs:SetSize(80, 60)
		self.Buffs.size = 12
		
		self:SetSize(config.playertargetwidth, config.playertargetheight)

		self.Name:SetPoint("TOPLEFT", self.Power, "TOPRIGHT", 4, bdUI.border)
		self.Curhp:SetPoint("LEFT", self.Health, "RIGHT", 4, -4)
	end,
	targettarget = function(self, unit)
		self:SetSize(config.targetoftargetwidth, config.targetoftargetheight)

		self.Name:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self.Name:SetTextHeight(math.clamp(config.targetoftargetheight * 0.75, 0, 13))
	end,
	pet = function(self, unit)
		self:SetSize(config.targetoftargetwidth, config.targetoftargetheight)
	end,
	focus = function(self, unit)
		additional_elements.castbar(self, unit)
		additional_elements.power(self, unit)

		self:SetSize(config.playertargetwidth, config.playertargetheight)
	end
}

local function layout(self, unit)
	self:RegisterForClicks('AnyDown')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)

	-- Health
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetStatusBarTexture(bdUI.media.smooth)
	self.Health:SetAllPoints(self)
	self.Health.frequentUpdates = true
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.colorSmooth = true
	self.Health.Smooth = true
	bdUI:set_backdrop(self.Health)

	-- Name & Text
	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
	self.Name:SetFont(bdUI.media.font, 13, "OUTLINE")

	self.Status = self.Health:CreateFontString(nil, "OVERLAY")
	self.Status:SetFont(bdUI.media.font, 10, "OUTLINE")
	self.Status:SetPoint("CENTER", self.Health, "CENTER")
	
	self.Curhp = self.Health:CreateFontString(nil, "OVERLAY")
	self.Curhp:SetFont(bdUI.media.font, 10, "OUTLINE")
	self.Curhp.frequentUpdates = 0.1

	-- Raid Icon
	self.RaidTargetIndicator = self.Health:CreateTexture(nil, "OVERLAY", nil, 1)
	self.RaidTargetIndicator:SetSize(12, 12)
	self.RaidTargetIndicator:SetPoint('CENTER', self, 0, 0)

	-- Tags
	oUF.Tags.Events['curhp'] = 'UNIT_HEALTH_FREQUENT UNIT_HEALTH UNIT_MAXHEALTH'
	oUF.Tags.Methods['curhp'] = function(unit)
		local hp, hpMax = UnitHealth(unit), UnitHealthMax(unit)
		if (not UnitIsPlayer(unit)) then
			hp, hpMax = math.max(LMH:GetUnitCurrentHP(unit), hp), math.max(LMH:GetUnitMaxHP(unit), hpMax)
		end
		local hpPercent = hp / hpMax
		if hpMax == 0 then return end
		local r, g, b = bdUI:ColorGradient(hpPercent, 1,0,0, 1,1,0, 1,1,1)
		local hex = RGBPercToHex(r, g, b)
		local perc = table.concat({"|cFF", hex, bdUI:round(hpPercent * 100, 2), "|r"}, "")

		return table.concat({bdUI:numberize(hp), "-", perc}, " ")
	end

	oUF.Tags.Events["status"] = "UNIT_HEALTH  UNIT_CONNECTION  CHAT_MSG_SYSTEM"
	oUF.Tags.Methods["status"] = function(unit)
		if not UnitIsConnected(unit) then
			return "offline"		
		elseif UnitIsDead(unit) then
			return "dead"		
		elseif UnitIsGhost(unit) then
			return "ghost"
		end
	end

	self:Tag(self.Curhp, '[curhp]')
	self:Tag(self.Name, '[name]')
	self:Tag(self.Status, '[status]')

	-- frame specific layouts
	custom_layout[unit](self, unit)
end


--===============================================
-- Load Module
-- runs when saved variable are available
--===============================================
local function load()
	if (not config.enabled) then return end

	oUF:RegisterStyle("bdUnitFrames", layout)
	oUF:SetActiveStyle("bdUnitFrames")

	-- player
	local player = oUF:Spawn("player")
	player:SetPoint("RIGHT", bdParent, "CENTER", -(config.playertargetwidth/2+2), -220)
	bdMove:set_moveable(player)

	-- target
	local target = oUF:Spawn("target")
	target:SetPoint("LEFT", UIParent, "CENTER", (config.playertargetwidth/2+2), -220)
	bdMove:set_moveable(target)

	-- targetoftarget
	local targettarget = oUF:Spawn("targettarget")
	targettarget:SetPoint("LEFT", UIParent, "CENTER", (config.playertargetwidth/2+2), -220-config.playertargetheight-config.castbarheight-20)
	bdMove:set_moveable(targettarget)

	-- pet
	-- local pet = oUF:Spawn("pet")
	-- pet:SetPoint("LEFT", UIParent, "CENTER", -(config.playertargetwidth/2+2), -220-config.playertargetheight-config.castbarheight-20)
	-- pet:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 0, -config.castbarheight-2)
	-- -- bdCore:makeMovable(pet)

	-- -- focus
	-- local focus = oUF:Spawn("focus")
	-- focus:SetPoint("TOP", UIParent, "TOP", 0, -30)
	-- bdCore:makeMovable(focus)
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