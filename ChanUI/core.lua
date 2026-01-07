CUI = LibStub("AceAddon-3.0"):NewAddon("ChanUI", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local LSM = LibStub("LibSharedMedia-3.0")


function CUI:OnInitialize()
    CUI:InitializeAce()
    CUI:Print("Loaded Chan UI")
end

function CUI:OnEnable()
    -- tweaks
    self:HookScript(ExpansionLandingPageMinimapButton, "OnShow", "HideExpansionSummary")

    -- socials
    self:CreateFriends()
end

---@param fs FontString
function CUI:SetFont(fs)
    fs:SetFont(
        LSM:Fetch("font", self.db.profile.font.name),
        self.db.profile.font.size,
        self.db.profile.font.outline
    )
end

---@param fs FontString
function CUI:UpdateFont(fs)
    self:SetFont(fs)
    self:UpdateText(nil, fs)
end

---@param fs FontString
function CUI:UpdateText(message, fs, padding)
    local parent = fs:GetParent()
    message = message or fs:GetText()
    padding = padding or 5

    fs:SetText(message)
    local w = fs:GetUnboundedStringWidth()
    local h = fs:GetStringHeight()

    parent:SetSize(w + padding, h + padding)
    fs:SetSize(parent:GetWidth(), parent:GetHeight())
end