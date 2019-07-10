-- Module
local module_name = "Chat"
bdUI[module_name] = CreateFrame("frame", module_name, bdParent)
local mod = bdUI[module_name]


local tabs = {"Left","Middle","Right","SelectedLeft","SelectedRight","SelectedMiddle","HighlightLeft","HighlightMiddle","HighlightRight"}

--================================================================
-- Alt-click invite
--================================================================
local DefaultSetItemRef = SetItemRef
function SetItemRef(link, ...)
	local type, value = link:match("(%a+):(.+)")
	--print(type)w
	if IsAltKeyDown() and type == "player" then
		InviteUnit(value:match("([^:]+)"))
	elseif (type == "url") then
		local eb = LAST_ACTIVE_CHAT_EDIT_BOX or ChatFrame1EditBox or ChatFrameEditBox
		if not eb then return end
		eb:Show()
		eb:SetText(value)
		eb:SetFocus()
		eb:HighlightText()
	else
		return DefaultSetItemRef(link, ...)
	end
end

--================================================================
-- Main message filterer
--================================================================
local function add_message(self, text, ...)
	-- Remove player brackets
	text = text:gsub("|Hplayer:([^%|]+)|h%[([^%]]+)%]|h", "|Hplayer:%1|h%2|h")
	
	text = text:gsub("<Away>", "")
	text = text:gsub("<Busy>", "")

	-- Strip yells: says: from chat
	text = text:gsub("|Hplayer:([^%|]+)|h(.+)|h says:", "|Hplayer:%1|h%2|h:");
	text = text:gsub("|Hplayer:([^%|]+)|h(.+)|h yells:", "|Hplayer:%1|h%2|h:");

	-- Whispers are now done with globals
	--text = text:gsub("|Hplayer:([^%|]+)|h(.+)|h whispers:", "F |Hplayer:%1|h%2|h:")
	--text = text:gsub("^To ", "T ")
	text = text:gsub("Guild Message of the Day:", "GMotD -")
	text = text:gsub("has come online.", "+")
	text = text:gsub("has gone offline.", "-")
		
	--channel replace (Trade and custom)
	--text = text:gsub("%[(%d0?)%. .-%]", "%1") -- removes channel #
	--text = text:gsub("^|Hchannel:[^%|]+|h%[[^%]]+%]|h ", "") -- clears all channel names
	text = text:gsub('|h%[(%d+)%. .-%]|h', '|h%1.|h')
	
	--url search
	text = text:gsub('([wWhH][wWtT][wWtT][%.pP]%S+[^%p%s])', '|cffffffff|Hurl:%1|h[%1]|h|r')

	if (strfind(text, "Arena Queue: Team Joined") ~= nil) then
		-- print("areana")
		text = "";
	end
	-- else
		return self.DefaultAddMessage(self, text, ...)
end

--=================================================================
-- Skin editbox
--=================================================================
local function skin_editbox(editbox, anchor)
	if (editbox.skinned) then return end

	local tex = {editbox:GetRegions()}
	local name = editbox:GetName()
	anchor = anchor or _G['ChatFrame1']
	
	bdUI:set_backdrop(editbox)
	editbox:SetAltArrowKeyMode(false)

	local left = _G[name.."Left"]
	local right = _G[name.."Right"]
	local mid = _G[name.."Mid"]
	if (left) then left:Hide() end
	if (right) then right:Hide() end
	if (mid) then mid:Hide() end

	for t = 6, #tex do tex[t]:SetAlpha(0) end

	editbox:ClearAllPoints()
	if (anchor:GetName() == "ChatFrame2") then
		editbox:SetPoint("BOTTOM", anchor,"TOP",0,34)
	else
		editbox:SetPoint("BOTTOM", anchor,"TOP",0,10)
	end
	editbox:SetPoint("LEFT", anchor, -8, 0)
	editbox:SetPoint("RIGHT", anchor, 8, 0)

	editbox.skinned = true
end

--==================================================================
-- Scrollwheel on chat
--==================================================================
local scroll = function(self, dir)
	if(dir > 0) then
		if(IsControlKeyDown()) then 
			self:ScrollToTop() 
		else 
			self:ScrollUp()
			if (IsShiftKeyDown()) then
				self:ScrollUp()
			end
		end
	else
		if(IsControlKeyDown()) then 
			self:ScrollToBottom() 
		else 
			self:ScrollDown() 
			if (IsShiftKeyDown()) then
				self:ScrollDown()
			end
		end
	end
end

--==================================================================
-- Make frame pretty
--==================================================================
function mod:skin_chat(frame)
	if not frame then return end

	local name = frame:GetName()

	-- Hook message filtering
	local index = string.gsub(name,"ChatFrame","")
	if (index ~= 2) then
		frame.DefaultAddMessage = frame.AddMessage
		frame.AddMessage = mod.add_message
	end
	
	--main chat frame
	frame:SetFrameStrata("LOW")
	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:SetMaxResize(UIParent:GetWidth()/2, UIParent:GetHeight()/2)
	frame:SetMinResize(100, 50)
	frame:SetFading(false)
	frame:SetScript("OnMouseWheel", scroll)
	frame:EnableMouseWheel(true)

	_G[name..'UpButton']:Hide()
	_G[name..'UpButton'].Show = noop
	_G[name..'DownButton']:Hide()
	_G[name..'DownButton'].Show = noop
	_G[name..'BottomButton']:Hide()
	_G[name..'BottomButton'].Show = noop

	-- resize button
	local resize = _G[name..'ResizeButton']
	if (resize) then
		resize:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 9,-5)
		resize:SetScale(.4)
		resize:SetAlpha(0.7)
	end

	-- to do: find out how best to display chat actionables, instead of just hiding them all
	local thumb = _G[name..'ThumbTexture']
	if (thumb) then
		thumb:Hide()
	end
	
	-- kill textures
	for g = 1, #CHAT_FRAME_TEXTURES do
		_G[name..CHAT_FRAME_TEXTURES[g] ]:SetTexture(nil)
	end
	
	-- tab style
	local tab = _G[name..'Tab']
	local tabtext = _G[tab:GetName().."Text"]
	tabtext:SetFont(bdUI.media.font, 14, "thinoutline")
	tabtext:SetTextColor(1,1,1)
	tabtext:SetVertexColor(1,1,1)
	tabtext:SetAlpha(.5)
	tabtext:SetShadowOffset(0,0)
	tabtext:SetShadowColor(0,0,0,0)
	tabtext.SetTextColor = noop
	tabtext.SetVertexColor = noop
	
	local glow = _G[name.."Glow"]
	if (glow) then
		glow:SetTexture(bdUI.media.flat)
		glow:SetVertexColor(unpack(bdUI.media.blue))
		glow.SetVertexColor = noop
		glow.SetTextColor = noop
	end
	
	for index, value in pairs(tabs) do
		local texture = _G[name..'Tab'..value]
		if (texture) then
			texture:SetTexture("")
		end
	end
	hooksecurefunc(frame,"Show",function(self)
		_G[self:GetName().."TabText"]:SetAlpha(1)
	end)
	hooksecurefunc(frame,"Hide",function(self)
		_G[self:GetName().."TabText"]:SetAlpha(.5)
	end)
	
	--hide button frame
	local buttonframe = _G[name..'ButtonFrame']
	if (buttonframe) then
		buttonframe:Hide()
		buttonframe.Show = noop
	end
	
	--editbox
	local editbox = _G[name..'EditBox'] or ChatFrameEditBox
	skin_editbox(editbox)
end