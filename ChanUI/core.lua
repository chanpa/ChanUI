ChanUI = LibStub("AceAddon-3.0"):NewAddon("ChanUI", "AceConsole-3.0", "AceEvent-3.0")


function ChanUI:OnInitialize()
    ChanUI:InitializeConfig()
    ChanUI:Print("hello")
end