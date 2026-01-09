CUI = LibStub("AceAddon-3.0"):NewAddon("ChanUI", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

function CUI:OnInitialize()
    CUI:InitializeAce()
end

function CUI:OnEnable()
    -- tweaks
    self:HookScript(ExpansionLandingPageMinimapButton, "OnShow", "HideExpansionSummary")
    self:RegisterEvent("HOUSE_EDITOR_AVAILABILITY_CHANGED", "MoveHousingControlsFrame")

    -- socials
    self:ShowSocials()
    self:RegisterEvent("FRIENDLIST_UPDATE", "UpdateFriends")
    self:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE", "UpdateFriends")
    self:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE", "UpdateFriends")
    self:RegisterEvent("BN_FRIEND_INFO_CHANGED", "UpdateFriends")
    self:RegisterEvent("BN_INFO_CHANGED", "UpdateFriends")
end

---@param fs FontString
function CUI:SetFont(fs)
    fs:SetFont(
        LSM:Fetch("font", self.db.profile.font.name) or "Arial Narrow",
        self.db.profile.font.size,
        self.db.profile.font.outline
    )
end

function CUI:ColorText(hex, message)
	if not message then return end
    return "|c"..hex..tostring(message).."|r"
end

function CUI:DumpObject(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. self:DumpObject(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function CUI:RGBPercToHex(r, g, b)
    r = r <= 1 and r >= 0 and r or 0
    g = g <= 1 and g >= 0 and g or 0
    b = b <= 1 and b >= 0 and b or 0
    return string.format("%02x%02x%02x", r*255, g*255, b*255)
end