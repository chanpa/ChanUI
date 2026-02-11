CUI = LibStub("AceAddon-3.0"):NewAddon("ChanUI", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local function registerMedia()
	LSM:Register("background", "Outer Highlight", [[Interface\Addons\ChanUI\Media\background\outer_highlight.tga]])
	LSM:Register("border", "Round", [[Interface\Addons\ChanUI\Media\border\round.tga]])
	LSM:Register("border", "Outer Shadow", [[Interface\Addons\ChanUI\Media\border\outer_shadow.tga]])

	LSM:Register("font", "Expressway", [[Interface\Addons\ChanUI\Media\font\Expressway.ttf]])

	LSM:Register("statusbar", "MaUIv3", [[Interface\Addons\ChanUI\Media\statusbar\MaUIv3.tga]])
	LSM:Register("statusbar", "MaUIv3Left", [[Interface\Addons\ChanUI\Media\statusbar\MaUIv3Left.tga]])
	LSM:Register("statusbar", "MaUIv3Right", [[Interface\Addons\ChanUI\Media\statusbar\MaUIv3Right.tga]])
	LSM:Register("statusbar", "Melli 6px", [[Interface\Addons\ChanUI\Media\statusbar\Melli6px.tga]])
	LSM:Register("statusbar", "Smallbar", [[Interface\Addons\ChanUI\Media\statusbar\o13.tga]])
	LSM:Register("statusbar", "Smallbar Left", [[Interface\Addons\ChanUI\Media\statusbar\r14.tga]])
	LSM:Register("statusbar", "Smallbar Right", [[Interface\Addons\ChanUI\Media\statusbar\r28.tga]])
	LSM:Register("statusbar", "ToxiUI-clean", [[Interface\Addons\ChanUI\Media\statusbar\ToxiUI-clean.tga]])
	LSM:Register("statusbar", "ToxiUI-dark", [[Interface\Addons\ChanUI\Media\statusbar\ToxiUI-dark.tga]])
	LSM:Register("statusbar", "ToxiUI-half", [[Interface\Addons\ChanUI\Media\statusbar\ToxiUI-half.tga]])
end

function CUI:OnInitialize()
	CUI:InitializeAce()
	registerMedia()
end

function CUI:OnEnable()
	self:EnableTweaks()
	self:EnableFriendlist()
	self:EnableGuildlist()
end

---@param fs FontString
function CUI:SetFont(fs, fontName, fontSize, fontOutline, context)
	local font = LSM:Fetch("font", fontName)
	if font then
		local objectName = "ChanUI-Font-".. context
		local fontObject = _G[objectName] or CreateFont(objectName)
		fontObject:SetFont(font, fontSize, fontOutline)
		fs:SetFontObject(fontObject)
	end
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


---Get the value from the path
---@param tbl table
---@param path string
function CUI:GetNestedValue(tbl, path)
	for key in path:gmatch("[^.]+") do
		tbl = tbl[key]
		if not tbl then return nil end
	end

	return tbl
end