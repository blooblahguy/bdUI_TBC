local bdUI, c, p = bdUI:unpack()

-- Module
local module_name = "Name"
bdUI[module_name] = CreateFrame("frame", module_name, bdParent)
bdUI[module_name].config = {}
local mod = bdUI[module_name]

-- Config
local config = bdUI[module_name].config
config.enabled = true


--===============================================
-- Custom functionality
-- place custom functionality here
--===============================================





--===============================================
-- Load Module
-- runs when saved variable are available
--===============================================
local function load()
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
bdUI:register_module(name, load, config, callback)