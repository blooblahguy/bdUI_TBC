-- Module
local module_name = "bdNameplates"
bdUI[module_name] = CreateFrame("frame", module_name, bdParent)
bdUI[module_name].config = {}
local mod = bdUI[module_name]

-- Config
local config = bdUI[module_name].config
config.enabled = false
config.width = 160
config.height = 15
config.level = false
config.target = true


--===============================================
-- Custom functionality
-- place custom functionality here
--===============================================
local combat = false
local numChildren = 0
local plateID = 0
local created_plates = {}
local offset = 2
local total = 0

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

-- Scan for plates
function mod:OnUpdate(elapsed)

	local count = select("#", WorldFrame:GetChildren(WorldFrame))
	if count ~= numChildren then
		local frame, region
		for i = numChildren + 1, count do
			frame = select(i, WorldFrame:GetChildren(WorldFrame))
			region = select(2, frame:GetRegions())

			if (not created_plates[frame] and region and region:GetObjectType() == "Texture" and region:GetTexture() == [=[Interface\Tooltips\Nameplate-Border]=]) then
				mod:register_nameplate(frame)
			end
		end
		numChildren = count
	end

	total = total + elapsed
	if (total > 0.1) then
		total = 0
		for k, frame in pairs(created_plates) do
			-- mod:update_nameplate(frame)
		end
	end
end


-- register nameplate
function mod:register_nameplate(frame)
	plateID = plateID + 1
	local healthbar, castbar = frame:GetChildren()
	local border, castbar_border, castbar_icon, highlight, name, level, bossicon, raidicon = frame:GetRegions()

	local unitframe = {}
	unitframe.frame = frame
	unitframe.health = healthbar
	unitframe.castbar = castbar
	unitframe.name = name
	unitframe.level = level
	unitframe.raidicon = raidicon
	unitframe.bossicon = bossicon

	-- Hide Blizzard panel and icon
	mod:remove_element(level)
	mod:remove_element(bossicon)
	mod:remove_element(border)
	mod:remove_element(castbar_border)

	mod:skin_nameplate(unitframe)
	frame:HookScript('OnShow', mod.update_nameplate)
	mod.update_nameplate(frame)

	created_plates[frame] = true
end


--===============================================
-- Load Module
-- runs when saved variable are available
--===============================================
local function load()
	if (not config.enabled) then return end

	mod:SetScript("OnUpdate", mod.OnUpdate)
	mod:RegisterEvent("PLAYER_REGEN_ENABLED")
	mod:RegisterEvent("PLAYER_REGEN_DISABLED")
	mod:SetScript('OnEvent', function(self, event) 
		if(event == 'PLAYER_REGEN_DISABLED') then
			combat = true
		elseif(event == 'PLAYER_REGEN_ENABLED') then
			combat = false
		end
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