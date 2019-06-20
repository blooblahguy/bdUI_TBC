--================================================
-- Allows for modules to be registered and 
-- automatically loaded / disabled as needed
bdUI.modules = {}
--================================================
function bdUI:register_module(name, load, config, callback)
	if not load then bdUI:print(name.." module lacks load function and can't be enabled.") return end

	local module = {}
	module.load = load
	module.name = name
	module.config = config
	module.callback = callback or noop	

	table.insert(bdUI.modules, module)
end

-- Load specific modules
function bdUI:load_module(name)
	for k, module in pairs(bdUI.modules) do
		if (module.name == name) then
			module:load();
			return;
		end
	end
end

-- Load all modules
function bdUI:load_modules()
	for k, module in pairs(bdUI.modules) do
		bdUI[module.name].config = bdUI.config_instance:register_module(module.name, module.config, module.callback)
		module:load()
		module:callback()
	end
end

bdUI:add_action("loaded", bdUI.load_modules)