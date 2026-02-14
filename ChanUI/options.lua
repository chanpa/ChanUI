local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")

local function GetRangeSlider(options)
	return {
		type = "range",
		name = options.name,
		width = options.width or "full",
		min = options.min or -3000,
		softMin = options.softMin or -1500,
		softMax = options.softMax or 1500,
		max = options.max or 3000,
		step = options.step or 1,
		get = options.get,
		set = options.set,
	}
end

local function GetFontSelector(dbentry, updater)
	local settings = {
		type = "group",
		name = "Font Settings",
		args = {},
	}

	local fonts = LSM:List("font")
	settings.args.name = {
		type = "select",
		name = "Font",
		itemControl = "DDI-Font",
		desc = "The font to use.",
		values = fonts,
		order = 1,
		get = function()
			for i, v in next, fonts do
				if v == dbentry.name then
					return i
				end
			end
		end,
		set = function(_, value)
			dbentry.name = fonts[value]
			updater()
		end,
	}

	settings.args.outline = {
		type = "select",
		name = "Outline",
		style = "dropdown",
		desc = "Outline mode of the text",
		values = {
			[""] = "None",
			["OUTLINE"] = "Outline",
			["THICKOUTLINE"] = "Thick Outline",
			["MONOCHROME,OUTLINE"] = "Monochrome Outline",
			["MONOCHROME,THICKOUTLINE"] = "Monochrome Thick Outline",
		},
		order = 2,
		get = function()
			return dbentry.outline
		end,
		set = function(_, value)
			dbentry.outline = value
			updater()
		end,
	}

	settings.args.size = {
		type = "range",
		name = "Font Size",
		desc = "Set the font size",
		min = 6,
		max = 100,
		step = 1,
		order = 3,
		get = function()
			return dbentry.size
		end,
		set = function(_, value)
			dbentry.size = value
			updater()
		end,
	}

	return settings
end

local function GetBorderSelector(updaters)
	local settings = {
		type = "group",
		name = "Border",
		args = {},
	}

	if updaters.name then
		settings.args.name = {
			type = "select",
			name = "Frame borders",
			width = "full",
			dialogControl = "LSM30_Border",
			values = LSM:HashTable("border"),
			order = 1,
			get = updaters.name.get,
			set = updaters.name.set,
		}
	end

	if updaters.size then
		settings.args.size = {
			type = "range",
			name = "Border size",
			width = "full",
			min = 0,
			max = 30,
			step = 1,
			order = 2,
			get = updaters.size.get,
			set = updaters.size.set,
		}
	end

	if updaters.inset then
		settings.args.inset = {
			type = "range",
			name = "Border inset",
			width = "full",
			min = 0,
			max = 30,
			step = 1,
			order = 3,
			get = updaters.inset.get,
			set = updaters.inset.set,
		}
	end

	if updaters.color then
		settings.args.color = {
			type = "color",
			name = "Border color",
			width = "full",
			hasAlpha = true,
			order = 4,
			get = updaters.color.get,
			set = updaters.color.set,
		}
	end

	return settings
end

local function GetTextureSelector(dbentry, updater)
	return {
		type = "group",
		name = "Backdrop Settings",
		args = {
			texture = {
				type = "select",
				name = "Backdrop texture",
				width = "full",
				order = 1,
				values = LSM:HashTable("background"),
				dialogControl = "LSM30_Background",
				get = function()
					return dbentry.texture
				end,
				set = function(_, value)
					dbentry.texture = value
					updater()
				end
			},
			color = {
				type = "color",
				name = "Backdrop color",
				width = "full",
				hasAlpha = true,
				order = 2,
				get = function()
					return unpack(dbentry.color)
				end,
				set = function(_, r, g, b, a)
					dbentry.color = { r, g, b, a }
					updater()
				end,
			},
		},
	}
end

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
			end,
		},
		enableChatOptions = {
			type = "toggle",
			name = "Enable chat options",
			desc = "Hide chat backgrounds and choose font",
			get = function()
				return CUI.db.profile.tweaks.enableChatOptions
			end,
			set = function(_, value)
				CUI.db.profile.tweaks.enableChatOptions = value
				-- todo enable ability to restore chat
			end,
		},
		chat = {
			type = "group",
			name = "Chat",
			disabled = function()
				return not CUI.db.profile.tweaks.enableChatOptions
			end,
			args = {
				font = GetFontSelector(CUI.db.profile.tweaks.chat.font, CUI.UpdateChat),
			},
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
						["CENTER"] = "CENTER",
					},
					get = function()
						return CUI.db.profile.tweaks.housingControlsFrame.anchor
					end,
					set = function(_, value)
						CUI.db.profile.tweaks.housingControlsFrame.anchor = value
						CUI:MoveHousingControlsFrame()
					end,
				},
				relX = GetRangeSlider({
					name = "Relative X position",
					get = function()
						return CUI.db.profile.tweaks.housingControlsFrame.relX
					end,
					set = function(_, value)
						CUI.db.profile.tweaks.housingControlsFrame.relX = value
						CUI:MoveHousingControlsFrame()
					end,
				}),
				relY = GetRangeSlider({
					name = "Relative Y position",
					get = function()
						return CUI.db.profile.tweaks.housingControlsFrame.relY
					end,
					set = function(_, value)
						CUI.db.profile.tweaks.housingControlsFrame.relY = value
						CUI:MoveHousingControlsFrame()
					end,
				}),
			},
		},
	}
end

local function GetGuildlistOptions(dbentry)
	return {
		header = {
			type = "group",
			name = "Header settings",
			args = {
				font = GetFontSelector(dbentry.header.font, function()
					CUI:SetGuildiesFont()
					CUI:SetGuildiesText()
				end),
				border = GetBorderSelector({
					name = {
						get = function()
							return dbentry.header.border.name
						end,
						set = function(_, value)
							dbentry.header.border.name = value
							CUI:SetGuildiesRootStyle()
							CUI:SetGuildiesText()
						end,
					},
					size = {
						get = function()
							return dbentry.header.border.size
						end,
						set = function(_, value)
							dbentry.header.border.size = value
							CUI:SetGuildiesRootStyle()
							CUI:SetGuildiesText()
						end,
					},
					inset = {
						get = function()
							return dbentry.header.border.inset
						end,
						set = function(_, value)
							dbentry.header.border.inset = value
							CUI:SetGuildiesRootStyle()
							CUI:SetGuildiesText()
						end,
					},
					color = {
						get = function()
							return unpack(dbentry.header.border.color)
						end,
						set = function(_, r, g, b, a)
							dbentry.header.border.color = { r, g, b, a }
							CUI:SetGuildiesRootStyle()
							CUI:SetGuildiesText()
						end,
					},
				}),
				backdrop = GetTextureSelector(dbentry.header.backdrop, CUI.SetGuildiesRootStyle),
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
								["CENTER"] = "CENTER",
							},
							get = function()
								return dbentry.header.positioning.anchor
							end,
							set = function(_, value)
								dbentry.header.positioning.anchor = value
								CUI:SetGuildiesRootPosition()
							end,
						},
						frameAnchor = {
							type = "select",
							name = "Frame anchor",
							desc = "Which part of the Friendlist to anchor to the anchor above",
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
								["CENTER"] = "CENTER",
							},
							get = function()
								return dbentry.header.positioning.frameAnchor
							end,
							set = function(_, value)
								dbentry.header.positioning.frameAnchor = value
								CUI:SetGuildiesRootPosition()
							end,
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
								return dbentry.header.positioning.relX
							end,
							set = function(_, value)
								dbentry.header.positioning.relX = value
								CUI:SetGuildiesRootPosition()
							end,
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
								return dbentry.header.positioning.relY
							end,
							set = function(_, value)
								dbentry.header.positioning.relY = value
								CUI:SetGuildiesRootPosition()
							end,
						},
					},
				},
			},
		},
		list = {
			type = "group",
			name = "List settings",
			args = {
				font = GetFontSelector(dbentry.list.font, CUI.SetGuildlistFont),
				border = GetBorderSelector({
					name = {
						get = function()
							return dbentry.list.border.name
						end,
						set = function(_, value)
							dbentry.list.border.name = value
							CUI:SetGuildiesRootStyle()
							CUI:SetGuildiesText()
						end,
					},
					size = {
						get = function()
							return dbentry.list.border.size
						end,
						set = function(_, value)
							dbentry.list.border.size = value
							CUI:SetGuildiesRootStyle()
							CUI:SetGuildiesText()
						end,
					},
					inset = {
						get = function()
							return dbentry.list.border.inset
						end,
						set = function(_, value)
							dbentry.list.border.inset = value
							CUI:SetGuildiesRootStyle()
							CUI:SetGuildiesText()
						end,
					},
					color = {
						get = function()
							return unpack(dbentry.list.border.color)
						end,
						set = function(_, r, g, b, a)
							dbentry.list.border.color = { r, g, b, a }
							CUI:SetGuildiesRootStyle()
							CUI:SetGuildiesText()
						end,
					},
				}),
				backdrop = GetTextureSelector(dbentry.list.backdrop, CUI.SetGuildiesRootStyle),
			},
		},
	}
end

local function GetFriendlistOptions(dbentry)
	return {
		header = {
			type = "group",
			name = "Header settings",
			args = {
				font = GetFontSelector(dbentry.header.font, function()
					CUI:SetFriendsFont()
					CUI:SetFriendsText()
				end),
				border = GetBorderSelector({
					name = {
						get = function()
							return dbentry.header.border.name
						end,
						set = function(_, value)
							dbentry.header.border.name = value
							CUI:SetFriendsRootStyle()
							CUI:SetFriendsText()
						end,
					},
					size = {
						get = function()
							return dbentry.header.border.size
						end,
						set = function(_, value)
							dbentry.header.border.size = value
							CUI:SetFriendsRootStyle()
							CUI:SetFriendsText()
						end,
					},
					inset = {
						get = function()
							return dbentry.header.border.inset
						end,
						set = function(_, value)
							dbentry.header.border.inset = value
							CUI:SetFriendsRootStyle()
							CUI:SetFriendsText()
						end,
					},
					color = {
						get = function()
							return unpack(dbentry.header.border.color)
						end,
						set = function(_, r, g, b, a)
							dbentry.header.border.color = { r, g, b, a }
							CUI:SetFriendsRootStyle()
							CUI:SetFriendsText()
						end,
					},
				}),
				backdrop = GetTextureSelector(dbentry.header.backdrop, CUI.SetFriendsRootStyle),
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
								["CENTER"] = "CENTER",
							},
							get = function()
								return dbentry.header.positioning.anchor
							end,
							set = function(_, value)
								dbentry.header.positioning.anchor = value
								CUI:SetFriendsRootPosition()
							end,
						},
						frameAnchor = {
							type = "select",
							name = "Frame anchor",
							desc = "Which part of the Friendlist to anchor to the anchor above",
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
								["CENTER"] = "CENTER",
							},
							get = function()
								return dbentry.header.positioning.frameAnchor
							end,
							set = function(_, value)
								dbentry.header.positioning.frameAnchor = value
								CUI:SetFriendsRootPosition()
							end,
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
								return dbentry.header.positioning.relX
							end,
							set = function(_, value)
								dbentry.header.positioning.relX = value
								CUI:SetFriendsRootPosition()
							end,
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
								return dbentry.header.positioning.relY
							end,
							set = function(_, value)
								dbentry.header.positioning.relY = value
								CUI:SetFriendsRootPosition()
							end,
						},
					},
				},
			},
		},
		list = {
			type = "group",
			name = "List settings",
			args = {
				font = GetFontSelector(dbentry.list.font, CUI.SetFriendlistFont),
				border = GetBorderSelector({
					name = {
						get = function()
							return dbentry.list.border.name
						end,
						set = function(_, value)
							dbentry.list.border.name = value
							CUI:SetFriendsRootStyle()
							CUI:SetFriendsText()
						end,
					},
					size = {
						get = function()
							return dbentry.list.border.size
						end,
						set = function(_, value)
							dbentry.list.border.size = value
							CUI:SetFriendsRootStyle()
							CUI:SetFriendsText()
						end,
					},
					inset = {
						get = function()
							return dbentry.list.border.inset
						end,
						set = function(_, value)
							dbentry.list.border.inset = value
							CUI:SetFriendsRootStyle()
							CUI:SetFriendsText()
						end,
					},
					color = {
						get = function()
							return unpack(dbentry.list.border.color)
						end,
						set = function(_, r, g, b, a)
							dbentry.list.border.color = { r, g, b, a }
							CUI:SetFriendsRootStyle()
							CUI:SetFriendsText()
						end,
					},
				}),
				backdrop = GetTextureSelector(dbentry.list.backdrop, CUI.SetFriendsRootStyle),
			},
		},
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
			end,
		},
		enableGuildlist = {
			type = "toggle",
			name = "Enable  Guildlist",
			get = function()
				return CUI.db.profile.socials.enableGuildlist
			end,
			set = function(_, value)
				CUI.db.profile.socials.enableGuildlist = value
			end,
		},
		friendlist = {
			type = "group",
			name = "Friendlist",
			childGroups = "tab",
			disabled = function()
				return not CUI.db.profile.socials.enableFriendlist
			end,
			args = GetFriendlistOptions(CUI.db.profile.socials.friendlist),
		},
		guildlist = {
			type = "group",
			name = "Guildlist",
			childGroups = "tab",
			disabled = function()
				return not CUI.db.profile.socials.enableGuildlist
			end,
			args = GetGuildlistOptions(CUI.db.profile.socials.guildlist),
		},
	}
end

local defaultOptions = {
	profile = {
		tweaks = {
			hideExpansionSummaryButton = false,
			enableChatOptions = false,
			housingControlsFrame = {
				anchor = "TOP",
				relX = 0,
				relY = -30,
			},
			chat = {
				enable = false,
				font = {
					name = "Arial Narrow",
					size = 14,
					outline = "OUTLINE",
				},
			},
		},
		socials = {
			enableFriendlist = true,
			enableGuildlist = true,
			friendlist = {
				header = {
					positioning = {
						anchor = "TOP",
						frameAnchor = "TOP",
						relX = 0,
						relY = 0,
					},
					font = {
						name = "Arial Narrow",
						size = 16,
						outline = "THICKOUTLINE",
					},
					border = {
						name = "",
						size = 0,
						inset = 0,
						color = { 0, 0, 0, 1 },
					},
					backdrop = {
						color = { 0, 0, 0, 1 },
						texture = "Interface/Buttons/WHITE8X8",
					},
				},
				list = {
					font = {
						name = "Arial Narrow",
						size = 16,
						outline = "THICKOUTLINE",
					},
					border = {
						name = "",
						size = 0,
						inset = 0,
						color = { 0, 0, 0, 1 },
					},
					backdrop = {
						color = { 0, 0, 0, 1 },
						texture = "Interface/Buttons/WHITE8X8",
					},
				},
			},
			guildlist = {
				header = {
					positioning = {
						anchor = "TOP",
						frameAnchor = "TOP",
						relX = 0,
						relY = 0,
					},
					font = {
						name = "Arial Narrow",
						size = 16,
						outline = "THICKOUTLINE",
					},
					border = {
						name = "",
						size = 0,
						inset = 0,
						color = { 0, 0, 0, 1 },
					},
					backdrop = {
						color = { 0, 0, 0, 1 },
						texture = "Interface/Buttons/WHITE8X8",
					},
				},
				list = {
					font = {
						name = "Arial Narrow",
						size = 16,
						outline = "THICKOUTLINE",
					},
					border = {
						name = "",
						size = 0,
						inset = 0,
						color = { 0, 0, 0, 1 },
					},
					backdrop = {
						color = { 0, 0, 0, 1 },
						texture = "Interface/Buttons/WHITE8X8",
					},
				},
			},
		},
	},
}

function CUI:InitializeAce()
	self.db = LibStub("AceDB-3.0"):New("ChanUIDB", defaultOptions, true)

	-- config
	LibStub("AceConfig-3.0"):RegisterOptionsTable("ChanUI", {
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
			},
		},
	})
	_, self.categoryID = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ChanUI", "Chan UI")
	self:RegisterChatCommand("cui", "SlashCommand")
	self:RegisterChatCommand("chanui", "SlashCommand")

	-- profiles
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db, true)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("ChanUIProfiles", profiles)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ChanUIProfiles", "Profiles", "Chan UI")

	self.db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfileChanged")
	self:RegisterEvent("PLAYER_LOGIN")
end

function CUI:ProfileChanged()
	self:UpdateTweaks()
	self:UpdateFriendlist()
	self:UpdateGuildlist()
end

function CUI:SlashCommand(msg)
	if msg == nil or msg:trim() == "" then
		Settings.OpenToCategory(self.categoryID)
	end
end
