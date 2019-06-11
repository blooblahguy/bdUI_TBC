--================================================
-- Event & Action System
bdUI.actions = bdUI.actions or {}
bdUI.events = bdUI.events or {}
bdUI.eventer = CreateFrame("frame", nil, bdParent)
--================================================
	function bdUI:do_action(action, ...)
		if (bdUI.actions[action]) then
			for k, v in pairs(bdUI.actions[action]) do
				v(...)
			end
		end
	end

	function bdUI:add_action(action, callback)
		local action = {strsplit(",", action)} or {action}

		for k, e in pairs(action) do
			e = strtrim(e)
			if (not bdUI.actions[e]) then
				bdUI.actions[e] = {}
			end
			table.insert(bdUI.actions[e], callback)
		end
	end

	-- register events in a single frame
	function bdUI:RegisterEvent(event, callback)
		local event = {strsplit(",", event)} or {event}

		for k, e in pairs(event) do
			e = strtrim(e)
			if (not bdUI.events[e]) then
				bdUI.events[e] = {}
			end
			table.insert(bdUI.events[e], callback)
			bdUI.eventer:RegisterEvent(e)
		end
	end
	function bdUI:UnregisterEvent(event, callback)
		if (bdUI.events[event]) then
			for k, v in pairs(bdUI.events[event]) do
				if v == callback then
					table.remove(bdUI.events[event], k)
					return
				end
			end
		end
	end

	bdUI.eventer:SetScript("OnEvent", function(self, ...)
		if (bdUI.events[event]) then
			for k, v in pairs(bdUI.events[event]) do
				v(...)
			end
		end
	end)


--================================================
-- Developer Helpers
--================================================
	-- Print to chat (for old clients)
	print = print or function(message)
		DEFAULT_CHAT_FRAME:AddMessage(message)
	end
	function bdUI:print(message)
		print(bdUI.colorString.."UI: "..message)
	end

	-- math clamp
	function math.clamp( _in, low, high )
		return math.min( math.max( _in, low ), high )
	end

	function math.restrict(_in, low, high)
		if (_in < low) then _in = low end
		if (_in > high) then _in = high end
		return _in
	end

	function bdUI:RGBColorGradient(...)
		local relperc, r1, g1, b1, r2, g2, b2 = colorsAndPercent(...)
		if(relperc) then
			return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
		else
			return r1, g1, b1
		end
	end

	-- no operation function
	noop = function() end

	-- slash commands
	function bdUI:set_slash_command(name, func, ...)
		SlashCmdList[name] = func
		for i = 1, select('#', ...) do
			_G['SLASH_'..name..i] = '/'..select(i, ...)
		end
	end

	-- reload
	bdUI:set_slash_command('ReloadUI', ReloadUI, 'rl', 'reset')
	-- readycheck
	bdUI:set_slash_command('DoReadyCheck', DoReadyCheck, 'rc', 'ready')
	-- lock/unlock
	bdUI:set_slash_command('ToggleLock', bdMove.toggle_lock, 'bdlock')
	bdUI:set_slash_command('ResetPositions', bdMove.reset_positions, 'bdreset')
	-- framename
	bdUI:set_slash_command('Frame', function()
		print(GetMouseFocus():GetName())
	end, 'frame')
	-- texture
	bdUI:set_slash_command('Texture', function()
		local type, id, book = GetCursorInfo();
		print((type=="item") and GetItemIcon(id) or (type=="spell") and GetSpellTexture(id,book) or (type=="macro") and select(2,GetMacroInfo(id)))
	end, 'texture')
	-- itemid
	bdUI:set_slash_command('ItemID', function()
		local infoType, info1, info2 = GetCursorInfo(); 
		if infoType == "item" then 
			print( info1 );
		end
	end, 'item')
	-- tt functionality, thanks phanx for simple script
	bdUI:set_slash_command('TellTarget', function()
		if UnitIsPlayer("target") and (UnitIsUnit("player", "target") or UnitCanCooperate("player", "target")) then
			SendChatMessage(message, "WHISPER", nil, GetUnitName("target", true))
		end
	end, 'tt', 'wt')

	-- Dump table to chat
	function dump (tbl, indent)
		if not indent then indent = 0 end
		for k, v in pairs(tbl) do
			formatting = string.rep("     ", indent) .. k .. ": "
			if type(v) == "table" then
				print(formatting)
				-- dump(v, indent+1)
			elseif type(v) == 'boolean' then
				print(formatting .. tostring(v))      
			elseif type(v) == 'userdata' then
				print(formatting .. "userdata")
			elseif type(v) ~= 'function' then
				-- print(type(v))
				print(formatting .. v)
			end
		end
	end

	RGBToHex = RGBToHex or function(r, g, b)
		r = r <= 255 and r >= 0 and r or 0
		g = g <= 255 and g >= 0 and g or 0
		b = b <= 255 and b >= 0 and b or 0
		return string.format("%02x%02x%02x", r, g, b)
	end

	RGBPercToHex = RGBPercToHex or function(r, g, b)
		r = r <= 1 and r >= 0 and r or 0
		g = g <= 1 and g >= 0 and g or 0
		b = b <= 1 and b >= 0 and b or 0
		return string.format("%02x%02x%02x", r*255, g*255, b*255)
	end

	GetQuadrant = GetQuadrant or function(frame)
		local x,y = frame:GetCenter()
		local hhalf = (x > UIParent:GetWidth()/2) and "RIGHT" or "LEFT"
		local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
		return vhalf..hhalf, vhalf, hhalf
	end


--================================================
-- Add / extend object functionality.
-- Mostly for expansion backwards compatibility
--================================================
	local function extend(object)
		local mt = getmetatable(object).__index
		if not object.SetSize then mt.SetSize = function(self, width, height) height = height or width; self:SetWidth(width) self:SetHeight(height) end end
		if not object.IsForbidden then mt.IsForbidden = noop end
		-- if not object.Point then mt.Point = Point end
		-- if not object.SetOutside then mt.SetOutside = SetOutside end
		-- if not object.SetInside then mt.SetInside = SetInside end
		-- if not object.SetTemplate then mt.SetTemplate = SetTemplate end
		-- if not object.CreateBackdrop then mt.CreateBackdrop = CreateBackdrop end
		-- if not object.CreateShadow then mt.CreateShadow = CreateShadow end
		-- if not object.Kill then mt.Kill = Kill end
		-- if not object.Width then mt.Width = Width end
		-- if not object.Height then mt.Height = Height end
		-- if not object.FontTemplate then mt.FontTemplate = FontTemplate end
		-- if not object.StripTextures then mt.StripTextures = StripTextures end
		-- if not object.StripTexts then mt.StripTexts = StripTexts end
		-- if not object.StyleButton then mt.StyleButton = StyleButton end
		-- if not object.CreateCloseButton then mt.CreateCloseButton = CreateCloseButton end
		-- if not object.GetNamedChild then mt.GetNamedChild = GetNamedChild end
		-- if not object.DisabledPixelSnap then
		-- 	if mt.SetSnapToPixelGrid then hooksecurefunc(mt, 'SetSnapToPixelGrid', WatchPixelSnap) end
		-- 	if mt.SetStatusBarTexture then hooksecurefunc(mt, 'SetStatusBarTexture', DisablePixelSnap) end
		-- 	if mt.SetColorTexture then hooksecurefunc(mt, 'SetColorTexture', DisablePixelSnap) end
		-- 	if mt.SetVertexColor then hooksecurefunc(mt, 'SetVertexColor', DisablePixelSnap) end
		-- 	if mt.CreateTexture then hooksecurefunc(mt, 'CreateTexture', DisablePixelSnap) end
		-- 	if mt.SetTexCoord then hooksecurefunc(mt, 'SetTexCoord', DisablePixelSnap) end
		-- 	if mt.SetTexture then hooksecurefunc(mt, 'SetTexture', DisablePixelSnap) end
		-- 	mt.DisabledPixelSnap = true
		-- end
	end

	local handled = {['Frame'] = true}
	local object = CreateFrame('Frame')
	extend(object)
	extend(object:CreateTexture())
	extend(object:CreateFontString())
	-- extend(object:CreateMaskTexture())

	local object = EnumerateFrames()
	while object do
		if (not object.IsForbidden or not object:IsForbidden()) and not handled[object:GetObjectType()] then
			extend(object)
			handled[object:GetObjectType()] = true
		end

		object = EnumerateFrames(object)
	end


--================================================
-- Combat Helpers
--================================================
	function bdUI:two_hander()
		local x = 0; 
		local wb, ws = false, false

		for b = 0, 4 do 
			for s = 1, GetContainerNumSlots(b) do 
				local i = GetContainerItemLink(b, s) 
				if i then 
					local n, _, r, L, _, t, z, _, e = GetItemInfo(i); 
					if e == "INVTYPE_2HWEAPON" and L > x then
						wb = b
						ws = s
						x = L;
					end 
				end 
			end
		end 

		if (wb and wb > 0 and ws and ws > 0) then
			PickupContainerItem(wb, ws);
			AutoEquipCursorItem();
		end
	end

	function bdUI:sword_board()
		local x = 0;
		local y = 0; 
		local sb, ss, wb, ws = false, false, false, false

		for b = 0, 4 do
			for s = 1, GetContainerNumSlots(b) do 
				local i = GetContainerItemLink(b, s) 
				if i then 
					local n, _, r, L, _, t, z, _, e = GetItemInfo(i); 
					if e == "INVTYPE_WEAPON" and L > x then
						wb = b
						ws = s
						x = L
					end 

					if e == "INVTYPE_SHIELD" and L > y then 
						sb = b
						ss = s
						y = L;
					end
				end
			end
		end
		
		if (ss and ss > 0 and ws and ws > 0) then
			PickupContainerItem(wb,ws);
			AutoEquipCursorItem();
			PickupContainerItem(sb,ss);
			AutoEquipCursorItem();
		end
	end