local CUI = ChanUI
local LSM = LibStub("LibSharedMedia-3.0")

local defaultValues = {
    profile = {
        hideExpansionSummary = false,
    }
}
local options = {
    name = "Chan UI",
    handler = CUI,
    type = "group",
    args = {
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


function CUI:InitializeConfig()
    self.db = LibStub("AceDB-3.0"):New("ChanUIDB", defaultValues)

    -- config
    LibStub("AceConfig-3.0"):RegisterOptionsTable("ChanUI", options, {"cui", "chanui"})
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ChanUI", "ChanUI")
end