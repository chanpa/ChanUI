CUI = LibStub("AceAddon-3.0"):NewAddon("ChanUI", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")


function CUI:OnInitialize()
    CUI:InitializeConfig()
    CUI:Print("Loaded Chan UI")
end

function CUI:OnEnable()
    self:HookScript(ExpansionLandingPageMinimapButton, "OnShow", "HideExpansionSummary")
end