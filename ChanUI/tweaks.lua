local CUI = CUI


function CUI:HideExpansionSummary()
    if self.db.profile.tweaks.hideExpansionSummaryButton then
        ExpansionLandingPageMinimapButton:Hide()
    end
end