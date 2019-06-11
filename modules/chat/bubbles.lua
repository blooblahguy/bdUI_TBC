bdUI.bubbles = CreateFrame("frame", nil, bdParent) 
local config = {}
config.type = "removed"
-- config.type = "skinned"
-- config.type = "none"

local update = 0
local numkids = 0
local bubbles = {}

-- Replaces player names in chat bubbles
local function skin_bubble_names(self)
	local text = self.text:GetText()
	local test = text:gsub("[^a-zA-Z%s]",'')
	local words = {strsplit(" ",test)}
	for i = 1, #words do
		local w = words[i]
		
		if (UnitName(w)) then
			local class = select(2, UnitClass(w))
			local colors = RAID_CLASS_COLORS[class]
			if (colors) then
				text = gsub(text, w, "|cff"..RGBPercToHex(colors.r,colors.g,colors.b).."%1|r")
			end
		end
	end
	self.text:SetText(text)
end

-- skin bubble to look nice
local function skin_bubble(frame)
	for i=1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region:GetObjectType() == "Texture" then
			region.defaulttex = region:GetTexture()
			region:SetTexture(nil)
		elseif region:GetObjectType() == "FontString" then
			frame.text = region
			frame.defaultfont, frame.defaultsize = frame.text:GetFont()
		end
	end
	-- local scale = UIParent:GetEffectiveScale()*2
	local scale = bdUI.scale * 2

	if (not frame.hooked) then
		frame:HookScript("OnShow", skin_bubble_names)	
		frame.hooked = true
	end
	skin_bubble_names(frame)
	
	bdUI:add_action("chat_bubbles_updated",function()
		if (config.type == "none*") then		
			frame.text:SetFont(frame.defaultfont, frame.defaultsize)

			for i=1, frame:GetNumRegions() do
				local region = select(i, frame:GetRegions())
				if region:GetObjectType() == "Texture" then
					region:SetTexture(region.defaulttex)
				end
			end
		elseif (config.type == "removed") then
			frame.text:SetFont(bdUI.media.font, 13, "OUTLINE")
			frame:SetBackdrop({bgFile = bdUI.media.flat})
			frame:SetBackdropColor(0,0,0,0)
			frame:SetBackdropBorderColor(0,0,0,0)
		elseif (config.type == "skinned") then
			frame.text:SetFont(bdUI.media.font, 13, "OUTLINE")
			frame:SetBackdrop({
				bgFile = bdUI.media.flat,
				edgeFile = bdUI.media.flat,
				edgeSize = scale,
				insets = {left = scale, right = scale, top = scale, bottom = scale}
			})
			frame:SetBackdropColor(unpack(bdUI.media.backdrop))
			frame:SetBackdropBorderColor(unpack(bdUI.media.border))
		end
	end)
	
	bdUI:do_action("chat_bubbles_updated")
	tinsert(bubbles, frame)
end

local function is_chat_bubble(frame)
	if frame.IsForbidden and frame:IsForbidden() then return end
	if frame:GetName() then return end
	if not frame:GetRegions() then return end
	if not frame:GetRegions().GetTexture then return end
	return frame:GetRegions():GetTexture() == "Interface\\Tooltips\\ChatBubble-Background"
end

-- Scan for bubbles
bdUI.bubbles:SetScript("OnUpdate", function(self, elapsed)
	update = update + elapsed
	if update > .05 then
		update = 0
		local newnumkids = WorldFrame:GetNumChildren()
		if newnumkids ~= numkids then
			for i=numkids + 1, newnumkids do
				local frame = select(i, WorldFrame:GetChildren())

				if is_chat_bubble(frame) then
					skin_bubble(frame)
				end
			end
			numkids = newnumkids
		end
	end
end)