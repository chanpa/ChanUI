CUI = LibStub("AceAddon-3.0"):NewAddon("ChanUI", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

function CUI:OnInitialize()
	CUI:InitializeAce()
end

function CUI:OnEnable()
	self:EnableTweaks()
	self:EnableFriendlist()
	self:EnableGuildlist()
end

---@param fs FontString
function CUI:SetFont(fs, fontName, fontSize, fontOutline)
	fs:SetFont(LSM:Fetch("font", fontName) or "Arial Narrow", fontSize, fontOutline)
end

function CUI:ColorText(hex, message)
	if not message then
		return
	end
	return "|c" .. hex .. tostring(message) .. "|r"
end

function CUI:RGBPercToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

