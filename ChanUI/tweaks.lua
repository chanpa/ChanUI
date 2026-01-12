local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")


function CUI:HideExpansionSummary()
    if self.db.profile.tweaks.hideExpansionSummaryButton and ExpansionLandingPageMinimapButton then
        ExpansionLandingPageMinimapButton:Hide()
    end
end

function CUI:MoveHousingControlsFrame()
    if not HousingControlsFrame then return end
    
    local anchor = self.db.profile.tweaks.housingControlsFrame.anchor
    local relX = self.db.profile.tweaks.housingControlsFrame.relX
    local relY = self.db.profile.tweaks.housingControlsFrame.relY
    HousingControlsFrame:ClearAllPoints()
    HousingControlsFrame:SetPoint(anchor, UIParent, anchor, relX, relY)
end

function CUI:UpdateChat()
    self:Print("Update chat")
    local padding = -8
    for i = 1, NUM_CHAT_WINDOWS do
        local f = _G["ChatFrame"..i]
        if not f then return end
        local hideThese = {"Background", "RightTexture", "TopTexture", "ResizeButton", "BottomTexture"}
        for _, t in pairs(hideThese) do
            local fbg = _G["ChatFrame"..i..t]
            fbg:Hide()
        end

        self:SetFont(
            f,
            CUI.db.profile.tweaks.chat.font.name,
            CUI.db.profile.tweaks.chat.font.size,
            CUI.db.profile.tweaks.chat.font.outline
        )
        if not f.SetBackdrop then
            Mixin(f, BackdropTemplateMixin)
        end
        f:SetBackdrop({
            bgFile = "Interface/Buttons/WHITE8X8",
            edgeFile = LSM:Fetch("border", CUI.db.profile.tweaks.chat.border.name),
            tile = true,
            edgeSize = CUI.db.profile.tweaks.chat.border.size,
            tileSize = 32,
            insets = {
                left = CUI.db.profile.tweaks.chat.border.inset,
                right = CUI.db.profile.tweaks.chat.border.inset,
                top = CUI.db.profile.tweaks.chat.border.inset,
                bottom = CUI.db.profile.tweaks.chat.border.inset
            }
        })
        local r, g, b, a = unpack(CUI.db.profile.tweaks.chat.backdrop.color)
        f:SetBackdropColor(r, g, b, a)
        r, g, b, a = unpack(CUI.db.profile.tweaks.chat.border.color)
        f:SetBackdropBorderColor(r, g, b, a)
        f.FontStringContainer:SetPoint("TOPLEFT", f, padding)
        f.FontStringContainer:SetPoint("BOTTOMRIGHT", f, padding)
    end
end