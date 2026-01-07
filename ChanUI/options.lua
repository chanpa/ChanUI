local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")

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
                    get = function()
                        return CUI.db.profile.font.name
                    end,
                    set = function(_, value)
                        CUI.db.profile.font.name = value
                        CUI:UpdateFont(CUI.friendsFontString)
                    end
                },
                size = {
                    type = "range",
                    name = "Font Size",
                    desc = "Set the font size",
                    min = 6,
                    max = 100,
                    step = 1,
                    get = function()
                        return CUI.db.profile.font.size
                    end,
                    set = function(_, value)
                        CUI.db.profile.font.size = value
                        CUI:UpdateFont(CUI.friendsFontString)
                    end,
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
                    get = function()
                        return CUI.db.profile.font.outline
                    end,
                    set = function(_, value)
                        CUI.db.profile.font.outline = value
                        CUI:UpdateFont(CUI.friendsFontString)
                    end,
                    style = "dropdown"
                }
            },
        },
        socials = {
            type = "group",
            name = "Socials",
            args = {
                enableFriendlist = {
                    type = "toggle",
                    name = "Enable  Friendlist",
                    get = function()
                        return CUI.db.profile.socials.enableFriendlist
                    end,
                    set = function(_, value)
                        CUI.db.profile.socials.enableFriendlist = value
                    end
                },
                enableGuildlist = {
                    type = "toggle",
                    name = "Enable  Guildlist",
                    get = function()
                        return CUI.db.profile.socials.enableGuildlist
                    end,
                    set = function(_, value)
                        CUI.db.profile.socials.enableGuildlist = value
                    end
                },
                friendlist = {
                    type = "group",
                    name = "Friendlist",
                    disabled = function()
                        return not CUI.db.profile.socials.enableFriendlist
                    end,
                    args = {
                        someoption = {
                            type = "toggle",
                            name = "Some option",
                            get = function()
                                return CUI.db.profile.socials.friendlist.someoption
                            end,
                            set = function(_, value)
                                CUI.db.profile.socials.friendlist.someoption = value
                            end
                        }
                    }
                },
                guildlist = {
                    type = "group",
                    name = "Guildlist",
                    disabled = function()
                        return not CUI.db.profile.socials.enableGuildlist
                    end,
                    args = {
                        someoption = {
                            type = "toggle",
                            name = "Some option",
                            get = function()
                                return CUI.db.profile.socials.guildlist.someoption
                            end,
                            set = function(_, value)
                                CUI.db.profile.socials.guildlist.someoption = value
                            end
                        }
                    }
                }
            }
        }
    },
}

local defaultOptions = {
    profile = {
        tweaks = {
            hideExpansionSummaryButton = false
        },
        font = {
            name = "Arial Narrow",
            size = 16,
            outline = "THICKOUTLINE"
        },
        socials = {
            enableFriendlist = true,
            enableGuildlist = true,
            friendlist = {
                someoption = true,
            },
            guildlist = {
                someoption = true,
            }
        }
    }
}


function CUI:InitializeAce()
    self.db = LibStub("AceDB-3.0"):New("ChanUIDB", defaultOptions)

    -- config
    LibStub("AceConfig-3.0"):RegisterOptionsTable("ChanUI", options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ChanUI", "ChanUI")
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