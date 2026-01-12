local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")

local function GetTweakOptions()
    return {
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
        },
        housingControlsFrame = {
            type = "group",
            name = "Housing controls",
            args = {
                anchor = {
                    type = "select",
                    name = "Anchor point",
                    desc = "Where to anchor the list",
                    width = "full",
                    values = {
                        ["TOP"] = "TOP",
                        ["RIGHT"] = "RIGHT",
                        ["BOTTOM"] = "BOTTOM",
                        ["LEFT"] = "LEFT",
                        ["TOPRIGHT"] = "TOPRIGHT",
                        ["TOPLEFT"] = "TOPLEFT",
                        ["BOTTOMLEFT"] = "BOTTOMLEFT",
                        ["BOTTOMRIGHT"] = "BOTTOMRIGHT",
                        ["CENTER"] = "CENTER"
                    },
                    get = function()
                        return CUI.db.profile.tweaks.housingControlsFrame.anchor
                    end,
                    set = function(_, value)
                        CUI.db.profile.tweaks.housingControlsFrame.anchor = value
                        CUI:MoveHousingControlsFrame()
                    end
                },
                relX = {
                    type = "range",
                    name = "Relative X position",
                    width = "full",
                    softMin = -1500,
                    min = -3000,
                    max = 3000,
                    softMax = 1500,
                    step = 1,
                    get = function()
                        return CUI.db.profile.tweaks.housingControlsFrame.relX
                    end,
                    set = function(_, value)
                        CUI.db.profile.tweaks.housingControlsFrame.relX = value
                        CUI:MoveHousingControlsFrame()
                    end
                },
                relY = {
                    type = "range",
                    name = "Relative Y position",
                    width = "full",
                    softMin = -1500,
                    min = -3000,
                    max = 3000,
                    softMax = 1500,
                    step = 1,
                    get = function()
                        return CUI.db.profile.tweaks.housingControlsFrame.relY
                    end,
                    set = function(_, value)
                        CUI.db.profile.tweaks.housingControlsFrame.relY = value
                        CUI:MoveHousingControlsFrame()
                    end
                }
            }
        }
    }
end

local function GetSocialOptions()
    return {
        enableFriendlist = {
            type = "toggle",
            name = "Enable  Friendlist",
            get = function()
                return CUI.db.profile.socials.enableFriendlist
            end,
            set = function(_, value)
                CUI.db.profile.socials.enableFriendlist = value
                if value then
                    CUI:ShowFriends()
                else
                    CUI:HideFriends()
                end
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
            childGroups = "tab",
            disabled = function()
                return not CUI.db.profile.socials.enableFriendlist
            end,
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
                            get = function()
                                return CUI.db.profile.socials.friendlist.font.name
                            end,
                            set = function(_, value)
                                CUI.db.profile.socials.friendlist.font.name = value
                                CUI:SetFont(
                                    CUI.friendsFontString,
                                    CUI.db.profile.socials.friendlist.font.name,
                                    CUI.db.profile.socials.friendlist.font.size,
                                    CUI.db.profile.socials.friendlist.font.outline
                                )
                                CUI:UpdateSocialText(
                                    CUI.friendsFontString,
                                    nil,
                                    CUI:CalculateSocialFramePadding(CUI.db.profile.socials.friendlist.border.inset)
                                )
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
                                return CUI.db.profile.socials.friendlist.font.size
                            end,
                            set = function(_, value)
                                CUI.db.profile.socials.friendlist.font.size = value
                                CUI:SetFont(
                                    CUI.friendsFontString,
                                    CUI.db.profile.socials.friendlist.font.name,
                                    CUI.db.profile.socials.friendlist.font.size,
                                    CUI.db.profile.socials.friendlist.font.outline
                                )
                                CUI:UpdateSocialText(
                                    CUI.friendsFontString,
                                    nil,
                                    CUI:CalculateSocialFramePadding(CUI.db.profile.socials.friendlist.border.inset)
                                )
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
                                return CUI.db.profile.socials.friendlist.font.outline
                            end,
                            set = function(_, value)
                                CUI.db.profile.socials.friendlist.font.outline = value
                                CUI:SetFont(
                                    CUI.friendsFontString,
                                    CUI.db.profile.socials.friendlist.font.name,
                                    CUI.db.profile.socials.friendlist.font.size,
                                    CUI.db.profile.socials.friendlist.font.outline
                                )
                                CUI:UpdateSocialText(
                                    CUI.friendsFontString,
                                    nil,
                                    CUI:CalculateSocialFramePadding(CUI.db.profile.socials.friendlist.border.inset)
                                )
                            end,
                            style = "dropdown"
                        }
                    },
                },
                border = {
                    type = "group",
                    name = "Borders",
                    args = {
                        name = {
                            type = "select",
                            name = "Frame borders",
                            width = "full",
                            dialogControl = "LSM30_Border",
                            values = LSM:HashTable("border"),
                            get = function()
                                return CUI.db.profile.socials.friendlist.border.name
                            end,
                            set = function(_, value)
                                CUI.db.profile.socials.friendlist.border.name = value
                                CUI:UpdateSocialFrameLook(
                                    CUI.friendRoot,
                                    CUI.db.profile.socials.friendlist.border.name,
                                    CUI.db.profile.socials.friendlist.border.size,
                                    CUI.db.profile.socials.friendlist.border.inset,
                                    CUI.db.profile.socials.friendlist.border.color,
                                    CUI.db.profile.socials.friendlist.backdrop.color
                                )
                                CUI:UpdateSocialText(
                                    CUI.friendsFontString,
                                    nil,
                                    CUI:CalculateSocialFramePadding(CUI.db.profile.socials.friendlist.border.inset)
                                )
                            end
                        },
                        size = {
                            type = "range",
                            name = "Border size",
                            width = "full",
                            min = 0,
                            max = 30,
                            step = 1,
                            get = function()
                                return CUI.db.profile.socials.friendlist.border.size
                            end,
                            set = function(_, value)
                                CUI.db.profile.socials.friendlist.border.size = value
                                CUI:UpdateSocialFrameLook(
                                    CUI.friendRoot,
                                    CUI.db.profile.socials.friendlist.border.name,
                                    CUI.db.profile.socials.friendlist.border.size,
                                    CUI.db.profile.socials.friendlist.border.inset,
                                    CUI.db.profile.socials.friendlist.border.color,
                                    CUI.db.profile.socials.friendlist.backdrop.color
                                )
                                CUI:UpdateSocialText(
                                    CUI.friendsFontString,
                                    nil,
                                    CUI:CalculateSocialFramePadding(CUI.db.profile.socials.friendlist.border.inset)
                                )
                            end
                        },
                        inset = {
                            type = "range",
                            name = "Border inset",
                            width = "full",
                            min = 0,
                            max = 30,
                            step = 1,
                            get = function()
                                return CUI.db.profile.socials.friendlist.border.inset
                            end,
                            set = function(_, value)
                                CUI.db.profile.socials.friendlist.border.inset = value
                                CUI:UpdateSocialFrameLook(
                                    CUI.friendRoot,
                                    CUI.db.profile.socials.friendlist.border.name,
                                    CUI.db.profile.socials.friendlist.border.size,
                                    CUI.db.profile.socials.friendlist.border.inset,
                                    CUI.db.profile.socials.friendlist.border.color,
                                    CUI.db.profile.socials.friendlist.backdrop.color
                                )
                                CUI:UpdateSocialText(
                                    CUI.friendsFontString,
                                    nil,
                                    CUI:CalculateSocialFramePadding(CUI.db.profile.socials.friendlist.border.inset)
                                )
                            end
                        },
                        color = {
                            type = "color",
                            name = "Border color",
                            width = "full",
                            hasAlpha = true,
                            get = function()
                                return unpack(CUI.db.profile.socials.friendlist.border.color)
                            end,
                            set = function(_, r, g, b, a)
                                CUI.db.profile.socials.friendlist.border.color = {r, g, b, a}
                                CUI:UpdateSocialFrameLook(
                                    CUI.friendRoot,
                                    CUI.db.profile.socials.friendlist.border.name,
                                    CUI.db.profile.socials.friendlist.border.size,
                                    CUI.db.profile.socials.friendlist.border.inset,
                                    CUI.db.profile.socials.friendlist.border.color,
                                    CUI.db.profile.socials.friendlist.backdrop.color
                                )
                                CUI:UpdateSocialText(
                                    CUI.friendsFontString,
                                    nil,
                                    CUI:CalculateSocialFramePadding(CUI.db.profile.socials.friendlist.border.inset)
                                )
                            end
                        }
                    }
                },
                backdrop = {
                    type = "group",
                    name = "Backdrop",
                    args = {
                        color = {
                            type = "color",
                            name = "Backdrop color",
                            width = "full",
                            hasAlpha = true,
                            get = function()
                                return unpack(CUI.db.profile.socials.friendlist.backdrop.color)
                            end,
                            set = function(_, r, g, b, a)
                                CUI.db.profile.socials.friendlist.backdrop.color = {r, g, b, a}
                                CUI:UpdateSocialFrameLook(
                                    CUI.friendRoot,
                                    CUI.db.profile.socials.friendlist.border.name,
                                    CUI.db.profile.socials.friendlist.border.size,
                                    CUI.db.profile.socials.friendlist.border.inset,
                                    CUI.db.profile.socials.friendlist.border.color,
                                    CUI.db.profile.socials.friendlist.backdrop.color
                                )
                            end
                        }
                    }
                },
                positioning = {
                    type = "group",
                    name = "Positioning",
                    args = {
                        anchor = {
                            type = "select",
                            name = "Anchor point",
                            desc = "Where to anchor the list",
                            width = "full",
                            values = {
                                ["TOP"] = "TOP",
                                ["RIGHT"] = "RIGHT",
                                ["BOTTOM"] = "BOTTOM",
                                ["LEFT"] = "LEFT",
                                ["TOPRIGHT"] = "TOPRIGHT",
                                ["TOPLEFT"] = "TOPLEFT",
                                ["BOTTOMLEFT"] = "BOTTOMLEFT",
                                ["BOTTOMRIGHT"] = "BOTTOMRIGHT",
                                ["CENTER"] = "CENTER"
                            },
                            get = function()
                                return CUI.db.profile.socials.friendlist.positioning.anchor
                            end,
                            set = function(_, value)
                                CUI.db.profile.socials.friendlist.positioning.anchor = value
                                CUI:UpdateSocialFramePosition(
                                    CUI.friendsFontString,
                                    CUI.db.profile.socials.friendlist.positioning.anchor,
                                    CUI.db.profile.socials.friendlist.positioning.relX,
                                    CUI.db.profile.socials.friendlist.positioning.relY
                                )
                            end
                        },
                        relX = {
                            type = "range",
                            name = "Relative X position",
                            width = "full",
                            softMin = -1500,
                            min = -3000,
                            max = 3000,
                            softMax = 1500,
                            step = 1,
                            get = function()
                                return CUI.db.profile.socials.friendlist.positioning.relX
                            end,
                            set = function(_, value)
                                CUI.db.profile.socials.friendlist.positioning.relX = value
                                CUI:UpdateSocialFramePosition(
                                    CUI.friendsFontString,
                                    CUI.db.profile.socials.friendlist.positioning.anchor,
                                    CUI.db.profile.socials.friendlist.positioning.relX,
                                    CUI.db.profile.socials.friendlist.positioning.relY
                                )
                            end
                        },
                        relY = {
                            type = "range",
                            name = "Relative Y position",
                            width = "full",
                            softMin = -1500,
                            min = -3000,
                            max = 3000,
                            softMax = 1500,
                            step = 1,
                            get = function()
                                return CUI.db.profile.socials.friendlist.positioning.relY
                            end,
                            set = function(_, value)
                                CUI.db.profile.socials.friendlist.positioning.relY = value
                                CUI:UpdateSocialFramePosition(
                                    CUI.friendsFontString,
                                    CUI.db.profile.socials.friendlist.positioning.anchor,
                                    CUI.db.profile.socials.friendlist.positioning.relX,
                                    CUI.db.profile.socials.friendlist.positioning.relY
                                )
                            end
                        }
                    }
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
end

local defaultOptions = {
    profile = {
        tweaks = {
            hideExpansionSummaryButton = false,
            housingControlsFrame = {
                anchor = "TOP",
                relX = 0,
                relY = -30
            }
        },
        socials = {
            enableFriendlist = true,
            enableGuildlist = true,
            friendlist = {
                positioning = {
                    anchor = "TOP",
                    relX = 0,
                    relY = 0
                },
                font = {
                    name = "Arial Narrow",
                    size = 16,
                    outline = "THICKOUTLINE"
                },
                border = {
                    name = "",
                    size = 0,
                    inset = 0,
                    color = {0, 0, 0, 1}
                },
                backdrop = {
                    color = {0, 0, 0, 1}
                },
            },
            guildlist = {
                someoption = true,
            }
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
            childGroups = "tab",
            args = GetTweakOptions(),
        },
        socials = {
            type = "group",
            name = "Socials",
            args = GetSocialOptions(),
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