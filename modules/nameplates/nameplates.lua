-- Module
local mod = bdUI["bdNameplates"]
local config = bdUI["bdNameplates"].config

function mod:update_nameplate()

	-- 		local barFrames = frame.barFrames
-- 		local nameFrame = frame.nameFrame
		
-- 		if(UnitName('target') and frame:GetAlpha() == 1) then
-- 			barFrames:SetAlpha(1)
-- 		else
-- 			barFrames:SetAlpha(0.5)
-- 		end
		
-- 		--local name = nameFrame.name:GetText()
-- 		--print(name)
		
-- 		local red, green, blue = nameFrame.name:GetTextColor()
-- 		local tapped = ((red > 0.50) and (red < 0.51)) and ((green > 0.50) and (green < 0.51)) and ((blue > 0.50) and (blue < 0.51))
-- 		if(not tapped) then
-- 			if(barFrames.hostile) then
-- 				barFrames.hp:SetStatusBarColor(1, 0, 0)
-- 			end
			
-- 			if(combat) then
-- 				if(barFrames.hostile) then
-- 					if(frame.region:IsShown()) then
-- 						local r, g, b = frame.region:GetVertexColor()
-- 						if(g + b == 0) then
-- 							barFrames.hp:SetStatusBarColor(1, 0, 0)
-- 						else
-- 							barFrames.hp:SetStatusBarColor(1, 1, 0.3)
-- 						end
-- 					else
-- 						barFrames.hp:SetStatusBarColor(0.3, 1, 0.3)
-- 					end
-- 				end
-- 			end
-- 		end
end
function mod:skin_nameplate(frame)
		-- frame.frame:SetSize(config.width, config.height + 20)
		-- frame.frame:SetScale(bdUI.scale)

		--Health
		frame.health:SetStatusBarTexture(bdUI.media.flat)
		frame.health:SetSize(config.width, config.height)
		frame.health:ClearAllPoints()
		frame.health:SetPoint('BOTTOM', frame.frame)

		--Name
		frame.name:ClearAllPoints()
		frame.name:SetPoint('BOTTOM', frame.health, 'TOP', 0, 2)
		frame.name:SetFont(bdUI.media.font, 14, "OUTLINE")
		frame.name:SetShadowOffset(0, 0)

		-- Raid Icon
		frame.raidicon:ClearAllPoints()
		frame.raidicon:SetPoint('LEFT', frame.health, 'RIGHT', 2, 0)
		frame.raidicon:SetSize(config.height+4, config.height+4)

		local hpbg = frame.health:CreateTexture(nil, 'BORDER')
		hpbg:SetPoint("TOPLEFT", frame.health, -2, 2)
		hpbg:SetPoint("BOTTOMRIGHT", frame.health, 2, -2)
		hpbg:SetTexture(bdUI.media.flat)
		hpbg:SetVertexColor(unpack(bdUI.media.border))
		
		-- local hpbg2 = frame.health:CreateTexture(nil, 'BORDER')
		-- hpbg2:SetAllPoints(frame.health)
		-- hpbg2:SetTexture(bdUI.media.flat)
		-- hpbg2:SetVertexColor(unpack(bdUI.media.backdrop))

		-- -- Cast Bar --
		-- local cbbg = f.barFrames.cb:CreateTexture(nil, 'BACKGROUND')
		-- cbbg:SetPoint('BOTTOMRIGHT', offset, -offset)
		-- cbbg:SetPoint('TOPLEFT', -offset, offset)
		-- cbbg:SetTexture(0, 0, 0)
		-- f.barFrames.cb.bg = cbbg

		-- local cbbg2 = f.barFrames.cb:CreateTexture(nil, 'BORDER')
		-- cbbg2:SetAllPoints(f.barFrames.cb)
		-- cbbg2:SetTexture(.1, .1, .1)
		
		-- f.barFrames.hp:SetScale(UIParent:GetScale())
		-- f.barFrames.cb:SetScale(UIParent:GetScale())
		
		-- f.barFrames.cb.icon:SetTexCoord(.1, .9, .1, .9)
		-- f.barFrames.cb.icon:SetDrawLayer("ARTWORK")
		
		-- local cbiconbg = f.barFrames.cb:CreateTexture(nil, 'BACKGROUND')
		-- cbiconbg:SetTexture(0, 0, 0)
		-- cbiconbg:SetHeight((config.height * 2) + 6)
		-- cbiconbg:SetWidth((config.height * 2) + 6)
		-- cbiconbg:SetPoint('BOTTOMRIGHT', f.barFrames.cb, 'BOTTOMLEFT', 0, -2)

		-- f.barFrames.cb:HookScript('OnShow', UpdateCastbar)
		-- f.barFrames.cb:HookScript('OnSizeChanged', UpdateCastbar)
		-- f.barFrames.cb:HookScript('OnUpdate', UpdateCastbar)

		-- f.barFrames.cb:SetStatusBarTexture(bdUI.media.flat)
	
		
		-- if(config.level) then
		-- 	f.barFrames.bossicon = bossicon
		-- 	f.barFrames.elite = elite
		-- 	f.barFrames.level = level
		-- end

-- 		UpdateObjects(f)
-- 		UpdateCastbar(f.barFrames.cb)
end