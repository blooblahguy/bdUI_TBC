-- Module
local module_name = "Buffs"
bdUI[module_name] = CreateFrame("frame", module_name, UIParent)
local mod = bdUI[module_name]

-- Config
local config = bdConfig:helper_config()
config:add("enabled", {
	type = "checkbox",
	value = true,
	label = "Enable",
})
config:add("size", {
	type = "slider",
	min = 12,
	max = 60,
	value = 28,
	step = 2,
	label = "Buff Size"
})
config:add("spacing", {
	type = "slider",
	min = 0,
	max = 12,
	value = 2,
	step = 1,
	label = "Spacing"
})
config:add("perrow", {
	type = "slider",
	min = 1,
	max = 40,
	value = 20,
	step = 1,
	label = "Buffs Per Row"
})

--===============================================
-- Custom functionality
-- place custom functionality here
--===============================================
function mod:create_anchor(name)
	local anchor = CreateFrame("frame", name, UIParent)

	anchor:SetBackdrop({bgFile = 'Interface\\Buttons\\WHITE8x8'})
    anchor:SetSize(config.size)
    anchor:EnableMouse(true)
    anchor:SetMovable(true)
    anchor:SetUserPlaced(false)
    anchor:SetFrameStrata("BACKGROUND")
    anchor:SetClampedToScreen(true)
    anchor:SetAlpha(0)

	return anchor
end

-- make a button pretty
function mod:style(name, index)
	local button = _G[name..index]
	button:SetSize(config.size)
	if (button.skinned) then return end

	local icon = _G[name..index.."Icon"]
	local border = _G[name..index.."Border"]
	local duration = _G[name..index.."Duration"]
	local count = _G[name..index.."Count"]

	bdUI:set_backdrop(button)

	count:ClearAllPoints()
	count:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 2, 1)
	count:SetDrawLayer("OVERLAY")
	count:SetFont(bdUI.media.font, bdUI.media.fontsize, bdUI.media.fontoutline)
	count:SetJustifyH("LEFT")
	count:SetJustifyV("BOTTOM")

	duration:ClearAllPoints()
	duration:SetPoint("TOP", button, "BOTTOM", 0, -4)
	duration:SetDrawLayer("OVERLAY")
	duration:SetFont(bdUI.media.font, bdUI.media.fontsize, bdUI.media.fontoutline)

	icon:SetTexCoord(.1, .9, .1, .9)
    icon:SetDrawLayer("OVERLAY")

	bdUI:set_highlight(button, icon)

	if border then border:Hide() end

	button.skinned = true
end

-- Initial setup of all auras
function mod:setup_auras()
	BUFF_ACTUAL_DISPLAY = 0
	for i = 1, BUFF_MAX_DISPLAY do
		if BuffButton_Update("BuffButton", i, "HELPFUL") then
			BUFF_ACTUAL_DISPLAY = BUFF_ACTUAL_DISPLAY + 1
			self:style("BuffButton", i)
		end
	end

	for i = 1, DEBUFF_MAX_DISPLAY do
		if BuffButton_Update("DebuffButton", i, "HARMFUL") then
			DEBUFF_ACTUAL_DISPLAY = DEBUFF_ACTUAL_DISPLAY + 1
			self:style("DebuffButton", i)
		end
	end

	self:update_enchants()
end

-- Runs for all buffs on anchor change
local function update_auras(name, index, filter)
	local button = _G[name..index]
	local rows = ceil(BUFF_ACTUAL_DISPLAY / config.perrow)

	mod:style(name, index)

	local row = math.floor(config.perrow / index)

	if (filter == "HELPFUL") then
		button:ClearAllPoints()

		if index > 1 and (math.modf(index, config.perrow) == 1) then
			if index == config.perrow + 1 then
				button:SetPoint("RIGHT", mod.buff_anchor, "RIGHT", 0, -(config.size + (config.spacing + bdUI.border)))
			else
				button:SetPoint("TOPRIGHT", _G[name..(index - BUFFS_PER_ROW)], "TOPRIGHT", 0, 0)
			end
		elseif index == 1 then
			mainhand, _, _, offhand = GetWeaponEnchantInfo()
			if mainhand and offhand then
				button:SetPoint("RIGHT", TempEnchant2, "LEFT", -(config.spacing + bdUI.border), 0)
			elseif (mainhand and not offhand) or (offhand and not mainhand) then
				button:SetPoint("RIGHT", TempEnchant1, "LEFT", -(config.spacing + bdUI.border), 0)
			else
				button:SetPoint("TOPRIGHT", mod.buff_anchor, "TOPRIGHT", 0, 0)
			end
		else
			button:SetPoint("RIGHT", _G[name..(index - 1)], "LEFT", -(config.spacing + bdUI.border), 0)
		end

		if index > (config.perrow * 2) then
			button:Hide()
		else
			button:Show()
		end

	else
		button:ClearAllPoints()
		if index == 1 then
			button:SetPoint("BOTTOMRIGHT", mod.debuff_anchor, "BOTTOMRIGHT", 0, 0)
		else
			button:SetPoint("RIGHT", _G[name..(index - 1)], "LEFT", -(config.spacing + bdUI.border), 0)
		end

		if index > config.perrow then
			button:Hide()
		else
			button:Show()
		end
	end
end

function mod:update_buff(name, index, filter)

end
function mod:update_debuff(name, index, filter)

end

function mod:update_enchants(name, index, filter)
	TemporaryEnchantFrame:ClearAllPoints()
	TemporaryEnchantFrame:SetPoint("TOPRIGHT", mod.buff_anchor, "TOPRIGHT", 0, 0)

	for i = 1, 2 do
		_G["TempEnchant"..i]:ClearAllPoints()
		if i == 1 then
			_G["TempEnchant"..i]:SetPoint("TOPRIGHT", mod.buff_anchor, "TOPRIGHT")
		else
			_G["TempEnchant"..i]:SetPoint("RIGHT", TempEnchant1, "LEFT", -(config.spacing + bdUI.border), 0)
		end

		self:style("TempEnchant", i)
	end
end

local function update_colors(name, index, filter)
	local color, debuffType
	local buffIndex = GetPlayerBuff(index, filter)
	local buff = _G[name..index]

	if buffIndex ~= 0 then
		if filter == "HARMFUL" then
			debuffType = GetPlayerBuffDispelType(buffIndex)

			if debuffType then
				color = DebuffTypeColor[debuffType]
			else
				color = bdUI.media.red
			end

			-- buff.border:SetVertexColor(unpack(color))

			buff.border:SetVertexColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
		end
	end
end



--===============================================
-- Load Module
-- runs when saved variable are available
--===============================================
local function load()
	config = mod.config
	if (not config.enabled) then return end

	BUFF_WARNING_TIME = 0

	mod.buff_anchor = mod:create_anchor("Buffs")
	mod.buff_anchor:SetBackdropColor(unpack(bdUI.media.green))
	mod.buff_anchor:SetPoint("TOPRIGHT", Minimap.background, "TOPLEFT", -10, -2)
	bdMove:set_moveable(mod.buff_anchor)

	mod.debuff_anchor = mod:create_anchor("Debuffs")
	mod.debuff_anchor:SetBackdropColor(unpack(bdUI.media.red))
	mod.debuff_anchor:SetPoint("CENTER", bdParent, "CENTER", 0, -200)
	bdMove:set_moveable(mod.debuff_anchor)

	mod.weapon_anchor = mod:create_anchor("Weapons")
	mod.weapon_anchor:SetBackdropColor(unpack(bdUI.media.blue))
	mod.weapon_anchor:SetPoint("BOTTOMRIGHT", Minimap.background, "BOTTOMLEFT", -10, 2)

	-- Hook events
	BuffFrame_UpdateAllBuffAnchors = BuffFrame_UpdateAllBuffAnchors or noop -- for older clients
	DebuffButton_UpdateAnchors = DebuffButton_UpdateAnchors or noop -- for older clients
	hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", update_auras)
	hooksecurefunc("DebuffButton_UpdateAnchors", update_auras)

	hooksecurefunc("BuffButton_UpdateAnchors", update_auras) -- For positioning
	-- hooksecurefunc("BuffButton_OnUpdate", mod.update_auras) -- For timers
	hooksecurefunc("BuffButton_Update", update_colors) -- For colors

	-- displays who cast the aura
	GameTooltip.SetUnitAura = GameTooltip.SetUnitAura or noop
	hooksecurefunc(GameTooltip, "SetUnitAura", function(self, unit, index, filter)
		local caster = select(8, UnitAura(unit, index, filter))
		local name = caster and UnitName(caster)
		if name then
			self:AddDoubleLine("Cast by:", name, nil, nil, nil, 1, 1, 1)
			self:Show()
		end
	end)

	mod:setup_auras()
end

--===============================================
-- Callback on changes / inintialization
-- runs when the configuration changes
--===============================================
local function callback()
	mod:setup_auras()
end

bdUI:register_module(module_name, load, config, callback)


local function MoveFunc(frame)
    if movebars==1 then
        frame:SetAlpha(1)
        frame:RegisterForDrag("LeftButton","RightButton")
        frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
        frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
        frame:SetFrameStrata("DIALOG")
    elseif movebars==0 then
        frame:SetAlpha(0)
        frame:SetScript("OnDragStart", function(self) self:StopMovingOrSizing() end)
        frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
        frame:SetFrameStrata("BACKGROUND")
    end
end


local function updateTime(button, timeLeft)
	local duration = _G[button:GetName().."Duration"]
	if SHOW_BUFF_DURATIONS == "1" and timeLeft then
		duration:SetTextColor(1, 1, 1)
		local d, h, m, s = ChatFrame_TimeBreakDown(timeLeft);
		if d > 0 then
			duration:SetFormattedText("%1dd", d)
		elseif h > 0 then
			duration:SetFormattedText("%1dh", h)
		elseif m > 0 then
			duration:SetFormattedText("%1dm", m)
		else
			duration:SetFormattedText("%1d", s)
		end
	end
end