local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")

local defaultValues = {
    profile = {
        tweaks = {
            hideExpansionSummaryButton = false
        },
        font = {
            name = "Arial Narrow",
            size = 16,
            outline = "THICKOUTLINE"
        }
    }
}
local options = {
    name = "Chan UI",
    handler = CUI,
    type = "group",
    args = {
        tweaks = {
            type = "group",
            name = "Tweaks",
            args = {
                hideExpansionSummaryButton = {
                    type = "toggle",
                    name = "Hide Expansion Summary",
                    desc = "Hides the Expansion Summary Button from the minimap",
                    get = function()
                        return CUI.db.profile.tweaks.hideExpansionSummaryButton
                    end,
                    set = function(_, value)
                        CUI.db.profile.tweaks.hideExpansionSummaryButton = value
                        if value then
                            ExpansionLandingPageMinimapButton:Hide()
                        else
                            ExpansionLandingPageMinimapButton:Show()
                        end
                    end
                }
            }
        },
        font = {
            type = "group",
            name = "Font Settings",
            args = {
                name = {
                    type = "select",
                    name = "Font",
                    dialogControl = 'LSM30_Font',
                    desc = "The font to use.",
                    values = LSM:HashTable("font"),
                    get = "GetFontName",
                    set = "SetFontName",
                },
                size = {
                    type = "range",
                    name = "Font Size",
                    desc = "Set the font size",
                    min = 6,
                    max = 100,
                    step = 1,
                    get = "GetFontSize",
                    set = "SetFontSize"
                },
                outline = {
                    type = "select",
                    name = "Outline",
                    desc = "Outline mode of the text",
                    values = {
                        ["OUTLINE"] = "Outline",
                        ["THICKOUTLINE"] = "Thick Outline",
                        ["MONOCHROME, OUTLINE"] = "Monochrome Outline",
                        ["MONOCHROME, THICKOUTLINE"] = "Monochrome Thick Outline"
                    },
                    get = "GetOutline",
                    set = "SetOutline",
                    style = "dropdown"
                }
            },
        },
    },
}


function CUI:InitializeAce()
    self.db = LibStub("AceDB-3.0"):New("ChanUIDB", defaultValues)

    -- config
    LibStub("AceConfig-3.0"):RegisterOptionsTable("ChanUI", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ChanUI", "ChanUI")
    self:RegisterChatCommand("cui", "SlashCommand")
    self:RegisterChatCommand("chanui", "SlashCommand")

    -- profiles
    local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("ChanUI_Profiles", profiles)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ChanUI_Profiles", "Profiles", "ChanUI")
end

function CUI:SlashCommand(msg)
    if msg == nil or msg:trim() == "" then
        Settings.OpenToCategory("ChanUI")
    end
end

function CUI:SetFontName(_, fontName)
    self.db.profile.font.name = fontName
end

function CUI:GetFontName()
    return self.db.profile.font.name
end

function CUI:GetFontSize()
    return self.db.profile.font.size
end


function CUI:SetFontSize(info, fontSize)
    self.db.profile.font.size = fontSize
end


function CUI:GetOutline()
    return self.db.profile.font.outline
end


function CUI:SetOutline(info, fontOutline)
    self.db.profile.font.outline = fontOutline
end