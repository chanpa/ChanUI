local CUI = CUI


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