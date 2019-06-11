--================================================
-- Media Functions
--================================================
function bdUI:set_backdrop(parent, resize, padding)
	if (parent.background) then return end
	padding = padding or 0
	local border = bdUI.border

	frame = CreateFrame("frame", nil, parent)
	frame:SetAllPoints(parent)
	frame:SetFrameStrata("BACKGROUND")

	parent.background = frame:CreateTexture(nil, "BORDER", nil, 1)
	parent.background:SetTexture(bdUI.media.flat)
	parent.background:SetPoint("TOPLEFT", frame, "TOPLEFT", -padding, padding)
	parent.background:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", padding, -padding)
	parent.background:SetVertexColor(unpack(bdUI.media.backdrop))
	parent.background.protected = true
	parent.background.SetFrameLevel = bdUI.noop
	
	parent.border = frame:CreateTexture(nil, "BACKGROUND", nil, 0)
	parent.border:SetTexture(bdUI.media.flat)
	parent.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -(padding + border), (padding + border))
	parent.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", (padding + border), -(padding + border))
	parent.border:SetVertexColor(unpack(bdUI.media.border))
	parent.border.SetFrameLevel = bdUI.noop
	parent.border.protected = true
end

function bdUI:set_highlight(frame, icon)
	if frame.SetHighlightTexture and not frame.highlighter then
		icon = icon or frame
		local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetTexture(1, 1, 1, 0.1)
		highlight:SetAllPoints(icon)

		frame.highlighter = highlight
		frame:SetHighlightTexture(highlight)
	end
end

function bdUI:ColorGradient(perc, ...)
	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end
	
	local num = select('#', ...) / 3

	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

-- lua doesn't have a good function for round
function bdUI:round(num, idp)
	local mult = 10^(idp or 0)
	return floor(num * mult + 0.5) / mult
end

function bdUI:numberize(v)
	if v <= 9999 then return v end
	if v >= 1000000000 then
		local value = string.format("%.1fb", v/1000000000)
		return value
	elseif v >= 1000000 then
		local value = string.format("%.1fm", v/1000000)
		return value
	elseif v >= 10000 then
		local value = string.format("%.1fk", v/1000)
		return value
	end
end

function bdUI:gradient(perc)
	if perc <= 0.5 then
		return 255, perc*510, 0
	else
		return 510 - perc*510, 255, 0
	end
end

-- user functions
function RGBPercToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r*255, g*255, b*255)
end