--[[======================================================




	curse.com/
	bdConfigLib Main Usage

	bdConfigLib:RegisterModule(settings, configuration, "savedVariable")

	settings
		name : name of the module in the configuration window
		command : /command that opens configuration to your module
		init : function callback for when configuration is initialized
		callback : function callback for when a configuration changes
		returnType : By default it retuns your direct save table, but you can return the persistent and profile versions or "both" if needed
	configuration : table of the configuration options for this module
		tab
		text
		list
		dropdown
	savedVariable : Per character SavedVariable as a STRING ie SavedVariableName = "SavedVariableName"




========================================================]]

local addonName, addon = ...
addonName = addonName or "bdUI"
addon = addon or {}

local _G = _G
local version = 11

if _G.bdConfigLib and _G.bdConfigLib.version >= version then
	bdConfigLib = _G.bdConfigLib
	return -- a newer or same version has already been created, ignore this file
end

--[[======================================================
	Create Library
========================================================]]
_G.bdConfigLib = {}
_G.bdConfigLibProfiles = {}
_G.bdConfigLibSave = {}

bdConfigLib = _G.bdConfigLib
bdConfigLibSave = _G.bdConfigLibSave
bdConfigLibProfiles = _G.bdConfigLibProfiles
bdConfigLibProfiles.Selected = "default"
bdConfigLibProfiles.Profiles = {}
bdConfigLibProfiles.SavedVariables = {}
bdConfigLib.version = version



-- event system
bd_action_events = bd_action_events or {}
function bd_add_action(event, func)
	local events = strsplit(",", event) or {event}
	events = type(events) == "table" and events or {event}

	for i = 1, #events do
		e = events[i]
		if (not bd_action_events[e]) then
			bd_action_events[e] = {}
		end
		bd_action_events[e][#bd_action_events[e]+1] = func
	end
end
function bd_do_action(event,...)
	if (bd_action_events[event]) then
		for k, v in pairs(bd_action_events[event]) do
			v(...)
		end
	end
end


-- Primary function
local function RegisterModule(self, settings, configuration, savedVariable)
	local enabled, loaded = IsAddOnLoaded(addonName)
	if (not loaded and not bdConfigLib.ProfileSetup) then
		debug("Addon", addonName, "saved variables not loaded yet, make sure you wrap your addon inside of an ADDON_LOADED event.")
		return
	end

	if (not settings.name) then 
		debug("When addind a module, you must include a name in the settings table.")
		return
	end
	if (not configuration) then 
		debug("When addind a module, you must include a configuration table to outline it's options.")
		return
	end
	if (bdConfigLib.modules[settings.name]) then
		debug("There is already a module loaded with the name "..settings.name..". Please choose a unique name for the module")
		return
	end
	if (type(savedVariable) ~= "string") then
		debug(settings.name.." tried to include saved variable as a table reference. Saved variable must be a string. i.e savedVariable should be \"saveVariable\"")
		return
	end

	-- see if we can upgrade font object here
	FindBetterFont()

	--[[======================================================
		Create Module Frame and Methods
	========================================================]]
	local module = {}
	module.settings = settings
	module.name = settings.name
	module.persistent = settings.persistent
	-- module.configuration = configuration
	-- module.savedVariable = savedVariable
	do
		module.tabs = {}
		module.tabContainer = false
		module.pageContainer = false
		module.link = false
		module.lastTab = false
		module.active = false

		function module:Select()
			if (module.active) then return end

			-- Unselect all modules
			for name, otherModule in pairs(bdConfigLib.modules) do
				otherModule:Unselect()

				for k, t in pairs(otherModule.tabs) do
					t:Unselect()
				end
			end

			-- Show this module
			module.active = true
			module.link.active = true
			module.link:OnLeave()
			module.tabContainer:Show()

			-- Select first tab
			module.tabs[1]:Select()

			-- If there aren't additional tabs, act like non exist and fill up space
			local current_tab = module.tabs[#module.tabs]
			if (current_tab.text:GetText() == "General") then
				module.tabContainer:Hide()
				current_tab.page.scrollParent:SetHeight(bdConfigLib.dimensions.height - bdConfigLib.media.borderSize)
			end
		end

		-- for when hiding
		function module:Unselect()
			module.tabContainer:Hide()
			module.active = false
			module.link.active = false
			module.link:OnLeave()
		end

		-- Create page and tabs container
		do
			local tabContainer = CreateFrame("frame", nil, bdConfigLib.window.right)
			tabContainer:SetPoint("TOPLEFT")
			tabContainer:SetPoint("TOPRIGHT")
			tabContainer:Hide()
			tabContainer:SetHeight(bdConfigLib.dimensions.header)
			CreateBackdrop(tabContainer)
			local r, g, b, a = unpack(bdConfigLib.media.background)
			tabContainer.bd_border:Hide()
			tabContainer.bd_background:SetVertexColor(r, g, b, 0.5)

			module.tabContainer = tabContainer
		end
	end

	-- Caps/hide the scrollbar as necessary
	-- also resize the page
	function module:SetPageScroll()
		-- now that all configs have been created, loop through the tabs
		for index, tab in pairs(module.tabs) do
			local page = tab.page
		
			local height = 0
			if (page.rows) then
				for k, container in pairs(page.rows) do
					height = height + container:GetHeight() + 10
				end
			end

			-- size based on if there are tabs or scrollbars
			local scrollHeight = 0
			if (#module.tabs > 1) then
				scrollHeight = math.max(dimensions.height, height + dimensions.header) - dimensions.height + 1			
				page.scrollParent:SetPoint("TOPLEFT", page.parent, "TOPLEFT", 0, - dimensions.header)
				page.scrollParent:SetHeight(page.scrollParent:GetParent():GetHeight() - dimensions.header)
			else
				scrollHeight = math.max(dimensions.height, height) - dimensions.height + 1
			end

			-- make the scrollbar only scroll the height of the page
			page.scrollbar:SetMinMaxValues(1, scrollHeight)

			if (scrollHeight <= 1) then
				page.noScrollbar = true
				page.scrollbar:Hide()
			else
				page.noScrollbar = false
				page.scrollbar:Show()
			end
		end
	end

	--[[======================================================
		Module main frames have been created
		1: CREATE / SET SAVED VARIABLES
			This includes setting up profile support
			Persistent config (non-profile)
			Defaults
	========================================================]]
	_G[savedVariable] = _G[savedVariable] or {}
	local svc = _G[savedVariable]

	-- persistent
	svc.persistent = svc.persistent or {}
	svc.persistent[settings.name] = svc.persistent[settings.name] or {}
	if (not svc.persistent.Auras and _G[savedVariable].Auras ~= nil) then
		svc.persistent.Auras = {}
		svc.persistent.Auras = Mixin(svc.persistent.Auras, _G[savedVariable].Auras)
	end

	-- profiles
	svc.profiles = svc.profiles or {}
	if (BD_profiles ~= nil) then
		svc.profiles = Mixin(svc.profiles, BD_profiles)
		BD_profiles = nil
	end

	-- user
	svc.users = svc.users or {}
	svc.users[UnitName("player")] = svc.users[UnitName("player")] or {}
	svc.user = svc.users[UnitName("player")] or {}
	if (BD_user ~= nil) then
		svc.user = Mixin(svc.user, BD_user)
		BD_user = nil
	end

	-- user
	svc.user.name = UnitName("player")
	svc.user.profile = svc.user.profile or "default"
	svc.user.spec_profile = svc.user.spec_profile or {}
	svc.user.spec_profile[1] = svc.user.spec_profile[1] or {}
	svc.user.spec_profile[2] = svc.user.spec_profile[2] or {}
	svc.user.spec_profile[3] = svc.user.spec_profile[3] or {}
	svc.user.spec_profile[4] = svc.user.spec_profile[4] or {}


	-- profile
	svc.profiles = svc.profiles or {}
	svc.profiles[svc.user.profile] = svc.profiles[svc.user.profile] or {}
	svc.profiles[svc.user.profile][settings.name] = svc.profiles[svc.user.profile][settings.name] or {}

	-- single profile target
	svc.profile = svc.profiles[svc.user.profile]
	svc.profile.positions = svc.profile.positions or {}

	-- shortcut to corrent save table
	if (settings.persistent) then
		module.save = svc.persistent[settings.name]
	else
		module.save = svc.profile[settings.name]
	end

	--[[======================================================
		2: CREATE INPUTS AND DEFAULTS
			This includes setting up profile support
			Persistent config (non-profile)
			Defaults
	========================================================]]
	for k, conf in pairs(configuration) do
		-- loop through the configuration table to setup, tabs, sliders, inputs, etc.
		for option, info in pairs(conf) do
			if (info.type) then
				if (settings.persistent) then
					-- if variable is `persistent` its not associate with a profile
					
					if (svc.persistent[settings.name][option] == nil) then
						if (info.value == nil) then
							info.value = {}
						end

						svc.persistent[settings.name][option] = info.value
					end
				else
					-- this is a per-character configuration
					-- print(settings.name, option)
					-- print(svc.profile[settings.name])
					svc.profile[settings.name] =  svc.profile[settings.name] or {}
					if (svc.profile[settings.name][option] == nil) then
						if (info.value == nil) then
							info.value = {}
						end

						svc.profile[settings.name][option] = info.value
					end
				end

				-- force blank callbacks if not set
				info.callback = info.callback or settings.callback or function() return end
				
				-- If the very first entry is not a tab, then create a general tab/page container
				if (info.type ~= "tab" and #module.tabs == 0) then
					module:CreateTab("General")
				end

				-- Master Call (slider = bdConfigLib.SliderElement(config, module, option, info))
				local method = string.lower(info.type):gsub("^%l", string.upper).."Element"
				if (bdConfigLib[method]) then
					bdConfigLib[method](bdConfigLib, module, option, info)
				else
					debug("No module defined for "..method.." in "..settings.name)
				end
			end
		end
	end
	

	--[[======================================================
		3: SETUP DISPLAY AND STORE MODULE
			If we only made 1 tab, hide the tabContianer an
			make the page take up the extra space
	========================================================]]
	module:SetPageScroll()

	-- store in config
	bdConfigLib.modulesIndex[#bdConfigLib.modulesIndex + 1] = module
	bdConfigLib.modules[settings.name] = module

	if (settings.init) then
		setting.init(module)
	end
	
	-- profile stuff
	if (not bdConfigLib.ProfileSetup) then
		bdConfigLibProfiles.SavedVariables[savedVariable] = true
		bd_do_action("update_profiles");
	end

	-- return config
	if (not settings.returnType) then
		return module.save
	elseif (settings.returnType == "both") then
		return svc
	elseif (settings.returnType == "profile") then
		return svc.profile
	elseif (settings.returnType == "persistent") then
		return svc.persistent[settings.name]
	end
end

--[[========================================================
	Load the Library Up
	For anyone curious, I use `do` statements just to 
	keep the code dileniated and easy to read.
==========================================================]]
do
	-- returns a list of modules currently loaded
	function bdConfigLib:GetSave(name)
		if (self.modules[name]) then
			return self.modules[name].save
		else
			return false
		end
	end
	function bdConfigLib:Toggle()
		if (not bdConfigLib.toggled) then
			bdConfigLib.window:Show()
		else
			bdConfigLib.window:Hide()
		end
		bdConfigLib.toggled = not bdConfigLib.toggled
	end

	-- create tables
	bdConfigLib.modules = {}
	bdConfigLib.modulesIndex = {}
	bdConfigLib.lastLink = false
	bdConfigLib.firstLink = false

	-- create frame objects
	bdConfigLib.window = CreateFrames()
	-- Selects first module, hides column if only 1
	bdConfigLib.window:SetScript("OnShow", function()
		bdConfigLib.modulesIndex[1]:Select()
	end)

	-- associate RegisterModule function
	bdConfigLib.RegisterModule = RegisterModule
end



--[[========================================================
	PROFILES
	Modules that are added that aren't persistent are 
	automatically stored inside of a profile, and those
	profiles are common between SavedVariables
==========================================================]]
do
	-- add a profile to every saved variable inside of bdConfigLib
	function bdConfigLib:AddProfile(value)
		for savedVariable, v in pairs(bdConfigLibProfiles.SavedVariables) do
			local save = _G[savedVariable]
			if (save.user.profile == value) then
				print("Profile named "..value.." already exists. Profile names must be unique.")
				return 
			else
				save.profiles[value] = save.profile
				bdConfigLibProfiles.Selected = value
				bd_do_action("update_profiles")
			end
		end
	end

	-- the trick here is changing profiles for all saved variables stored inside bdConfigLib
	function bdConfigLib:ChangeProfile(value)
		for savedVariable, v in pairs(bdConfigLibProfiles.SavedVariables) do
			local save = _G[savedVariable]
			save.user.profile = value
			save.profile = save.profiles[value]
			-- print(save.profile)
			bdConfigLibProfiles.Selected = value

			bdCore:triggerEvent("profile_changed")
		end
	end

	-- delete a profile inside of every saved variable in bdConfigLib
	function bdConfigLib:DeleteProfile()
		for savedVariable, v in pairs(bdConfigLibProfiles.SavedVariables) do
			local save = _G[savedVariable]
			if (save.user.profile == "default") then
				print("You cannot delete the default profile, but you're free to modify it.")
				return 
			else
				save.profile = nil
				bdConfigLibProfiles.Selected = nil
				bd_do_action("update_profiles")
			end
		end
	end

	-- return a table of profile names
	function bdConfigLib:UpdateProfiles(dropdown)
		bdConfigLibProfiles.Profiles = {}
		local profile_table = {}

		for savedVariable, v in pairs(bdConfigLibProfiles.SavedVariables) do
			local save = _G[savedVariable]

			bdConfigLibProfiles.Selected = save.user.profile
			for profile, config in pairs(save.profiles) do
				profile_table[profile] = true
			end

		end

		for k, v in pairs(profile_table) do
			table.insert(bdConfigLibProfiles.Profiles, k)
		end

		dropdown:populate(bdConfigLibProfiles.Profiles, bdConfigLibProfiles.Selected)
	end

	-- make new profile form
	local name, realm = UnitName("player")
	realm = GetRealmName()
	local placeholder = name.."-"..realm

	-- how many specs does this class have
	local class = select(2, UnitClass("player"));
	local specs = 3
	if (class == "DRUID") then
		specs = 4
	elseif (class == "DEMONHUNTER") then
		specs = 2
	end

	local profile_settings = {}
	profile_settings[#profile_settings+1] = {intro = {
		type = "text",
		value = "You can use profiles to store configuration per character and spec automatically, or save templates to use when needed. Changing profiles may require a UI reload."
	}}
	-- create new profile
	profile_settings[#profile_settings+1] = {createprofile = {
		type = "textbox",
		value = placeholder,
		button = "Create & Copy",
		description = "Create New Profile: ",
		tooltip = "Your currently selected profile.",
		callback = function(self, value) bdConfigLib:AddProfile(value) end
	}}

	-- select / delete profiles
	profile_settings[#profile_settings+1] = {currentprofile = {
		type = "dropdown",
		label = "Current Profile",
		value = bdConfigLibProfiles.Selected,
		options = bdConfigLibProfiles.Profiles,
		override = true,
		update = function(self, dropdown) bdConfigLib:UpdateProfiles(dropdown) end,
		update_action = "update_profiles",
		tooltip = "Your currently selected profile.",
		callback = function(self, value) bdConfigLib:ChangeProfile(value) end
	}}
	profile_settings[#profile_settings+1] = {deleteprofile = {
		type = "button",
		value = "Delete Current Profile",
		callback = bdConfigLib.DeleteProfile
	}}
	profile_settings[#profile_settings+1] = {clear = {
		type = "clear"
	}}
	-- loop through and display spec dropdowns (@todo)
	for i = 1, specs do
		-- profile_settings[#profile_settings+1] = {["spec"..i] = {
		-- 	type = "dropdown",
		-- 	label = "Spec "..i.." Profile"
		-- 	value = bdConfigLibProfiles.Selected,
		-- 	override = true,
		-- 	options = bdConfigLibProfiles.Profiles,
		-- 	update = function(self, dropdown) bdConfigLib:UpdateProfiles(dropdown) end,
		-- 	update_action = "update_profiles",
		-- 	tooltip = "Your currently selected profile.",
		-- 	callback = function(self, value) bdConfigLib:ChangeProfile(value) end
		-- }}
	end


	bdConfigLib.ProfileSetup = true
	bdConfigLib:RegisterModule({
		name = "Profiles"
		, persistent = true
	}, profile_settings, "bdConfigLibProfiles")
	bdConfigLib.ProfileSetup = nil
end


-- for testing, pops up config on reload for easy access :)
-- bdConfigLib:Toggle()