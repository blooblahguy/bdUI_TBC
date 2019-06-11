-- Module
local module_name = "Error Block"
bdUI[module_name] = CreateFrame("frame", module_name, bdParent)
local m = bdUI[module_name]

-- Config
local config = {}
config.enabled = true


--===============================================
-- Custom functionality
-- place custom functionality here
--===============================================
local filter = {
	[ERR_OUT_OF_CHI or ''] = true,					-- Not enough chi
	[ERR_OUT_OF_RAGE] = true,
	[ERR_OUT_OF_FOCUS] = true,						-- Not enough focus
	[ERR_OUT_OF_RUNES or ''] = true,				-- Not enough runes
	[ERR_OUT_OF_ENERGY] = true,						-- Not enough energy
	[ERR_OUT_OF_RUNIC_POWER or ''] = true,				-- Not enough runic power
	[ERR_ABILITY_COOLDOWN] = true,					-- Ability is not ready yet.
	[ERR_GENERIC_NO_TARGET] = true,					-- You have no target.
	[ERR_INVALID_ATTACK_TARGET] = true, 			-- You cannot attack that target.
	[ERR_NO_ATTACK_TARGET] = true, 					-- There is nothing to attack.
	[ERR_CLIENT_LOCKED_OUT] = true,					-- You can't do that right now.
	[ERR_ATTACK_MOUNTED] = true,					-- Can't attack while mounted.
	[ERR_ATTACK_STUNNED] = true,					-- Can't attack while stunned.
	[ERR_SPELL_COOLDOWN] = true,					-- Spell is not ready yet.
	[ERR_BADATTACKPOS] = true,						-- You are too far away!
	[ERR_BADATTACKFACING] = true,					-- You are facing the wrong way!
	[ERR_MUST_EQUIP_ITEM] = true,					-- You must equip that item to use it.
	[SPELL_FAILED_STUNNED] = true,					-- Can't do that while stunned
	[SPELL_FAILED_BAD_TARGETS] = true,				-- Invalid target
	[SPELL_FAILED_BAD_IMPLICIT_TARGETS] = true,		-- No target
	[SPELL_FAILED_TARGETS_DEAD] = true,				-- Your target is dead	
	[SPELL_FAILED_UNIT_NOT_INFRONT] = true,			-- Target needs to be in front of you.
	[SPELL_FAILED_CUSTOM_ERROR_153 or ''] = true,			-- You have insufficient Blood Charges.
	[SPELL_FAILED_CUSTOM_ERROR_154 or ''] = true, 		-- No fully depleted runes.
	[SPELL_FAILED_CUSTOM_ERROR_159 or ''] = true,			-- Both Frost Fever and Blood Plague must be present on the target.
	[SPELL_FAILED_SPELL_IN_PROGRESS] = true,		-- Another action is in progress	
}
filter['You cannot attack that target.'] = true
filter['There is nothing to attack.'] = true
filter['Already looted'] = true
filter['that item is still being rolled for.'] = true




--===============================================
-- Load Module
-- runs when saved variable are available
--===============================================
local function load()
	if (not config.enabled) then return end

	local orig = UIErrorsFrame:GetScript("OnEvent")
	
	UIErrorsFrame:SetScript("OnEvent", function(self, event, msg, ...)
		if event == "UI_ERROR_MESSAGE" then
			if filter[msg] then
				return
			end
		end
		return orig(self, event, msg, ...)
	end)
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