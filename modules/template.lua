-- Module
local module_name = "Name"
bdUI[module_name] = CreateFrame("frame", module_name, bdParent)
local mod = bdUI[module_name]

-- Config
local config = bdConfig:helper_config()
config:add("enabled", {
	type = "checkbox",
	value = true,
	label = "Enable",
})


--===============================================
-- Custom functionality
-- place custom functionality here
--===============================================





--===============================================
-- Load Module
-- runs when saved variable are available
--===============================================
local function load()
	config = mod.config -- replace config with SV config
	if (not config.enabled) then return end
	
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
bdUI:register_module(module_name, load, config, callback)