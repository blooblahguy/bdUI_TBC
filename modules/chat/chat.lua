local module_name = "Chat"
local mod = bdUI[module_name]

local config = {}
config.enabled = true

local function load()
	-- fonts
	CHAT_FONT_HEIGHTS = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}
	ChatFontNormal:SetFont(bdUI.media.font, 14)
	ChatFontNormal:SetShadowOffset(1,1)
	ChatFontNormal:SetShadowColor(0,0,0)

	--tabs
	CHAT_FRAME_FADE_TIME = 0
	CHAT_FRAME_FADE_OUT_TIME = 0
	CHAT_TAB_SHOW_DELAY = 0
	CHAT_TAB_HIDE_DELAY = 0
	CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
	CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
	CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
	CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
	CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
	CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1

	-- Global strings filter
	CHAT_WHISPER_GET = "F %s "
	CHAT_WHISPER_INFORM_GET = "T %s "
	CHAT_BN_WHISPER_GET = "F %s "
	CHAT_BN_WHISPER_INFORM_GET = "T %s "
	CHAT_BATTLEGROUND_GET = "|Hchannel:Battleground|hBG.|h %s: "
	CHAT_BATTLEGROUND_LEADER_GET = "|Hchannel:Battleground|hBGL.|h %s: "
	CHAT_GUILD_GET = "|Hchannel:Guild|hG.|h %s: "
	CHAT_OFFICER_GET = "|Hchannel:Officer|hO.|h %s: "
	CHAT_PARTY_GET = "|Hchannel:Party|hP.|h %s: "
	CHAT_PARTY_LEADER_GET = "|Hchannel:Party|hPL.|h %s: "
	CHAT_PARTY_GUIDE_GET = "|Hchannel:Party|hPG.|h %s: "
	CHAT_RAID_GET = "|Hchannel:Raid|hR.|h %s: "
	CHAT_RAID_LEADER_GET = "|Hchannel:Raid|hRL.|h %s: "
	CHAT_RAID_WARNING_GET = "|Hchannel:RaidWarning|hRW.|h %s: "
	CHAT_INSTANCE_CHAT_GET = "|Hchannel:Battleground|hI.|h %s: "
	CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:Battleground|hIL.|h %s: "
	YOU_LOOT_MONEY_GUILD = YOU_LOOT_MONEY
	LOOT_MONEY_SPLIT_GUILD = LOOT_MONEY_SPLIT

	-- Better money loot
	COPPER_AMOUNT_SYMBOL = COPPER_AMOUNT_SYMBOL or 'c'
	SILVER_AMOUNT_SYMBOL = SILVER_AMOUNT_SYMBOL or 's'
	GOLD_AMOUNT_SYMBOL = GOLD_AMOUNT_SYMBOL or 'g'
	COPPER_AMOUNT = "%d|cFF954F28"..COPPER_AMOUNT_SYMBOL.."|r";
	SILVER_AMOUNT = "%d|cFFC0C0C0"..SILVER_AMOUNT_SYMBOL.."|r";
	GOLD_AMOUNT = "%d|cFFF0D440"..GOLD_AMOUNT_SYMBOL.."|r";
	YOU_LOOT_MONEY = "+%s";
	LOOT_MONEY_SPLIT = "+%s";

	-- Sticky channels (oldschool)
	ChatTypeInfo.EMOTE.sticky = 1
	ChatTypeInfo.YELL.sticky = 1
	ChatTypeInfo.OFFICER.sticky = 1
	ChatTypeInfo.RAID_WARNING.sticky = 1
	ChatTypeInfo.WHISPER.sticky = 1
	ChatTypeInfo.CHANNEL.sticky = 1

	-- Enable Classcolor
	local function color_name(self, event, msg, ...)
		msg = msg or self -- backwards compatibility
		local test = msg:gsub("[^a-zA-Z%s]",'')
		
		local words = {strsplit(' ',test)}
		for i = 1, #words do
			local w = words[i]
			
			if (w and not (w == "player" or w == "target") and UnitName(w) and UnitIsPlayer(w)) then
				local class = select(2, UnitClass(w))
				local colors = RAID_CLASS_COLORS[class]
				if (colors) then
					msg = gsub(msg, w, "|cff"..RGBPercToHex(colors.r,colors.g,colors.b).."%1|r")
				end
			end
		end
		
		return false, msg, ...
	end
	ToggleChatColorNamesByClassGroup = ToggleChatColorNamesByClassGroup or noop
	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", color_name)

	-- do all the default chat channels
	-- Hide side buttons
	ChatFrameMenuButton:Hide()
	ChatFrameMenuButton.Show = noop
	for i = 1, NUM_CHAT_WINDOWS do
		local chatframe = _G["ChatFrame"..i]
		mod:skin_chat(chatframe)
	end
end

local function callback()

end

bdUI:register_module(module_name, load, config, unload)