local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")

local function GetRangeSlider(name, getFunc, setFunc)
	return {
		type = "range",
		name = name,
		width = "full",
		softMin = -1500,
		min = -3000,
		max = 3000,
		softMax = 1500,
		step = 1,
		get = getFunc,
		set = setFunc,
	}
end

local function GetFontSelector(updaters)
	local settings = {
		type = "group",
		name = "Font Settings",
		args = {}
	}

	if updaters.name then
		settings.args.name = {
			type = "select",
			name = "Font",
			dialogControl = "LSM30_Font",
			desc = "The font to use.",
			values = LSM:HashTable("font"),
			get = updaters.name.get,
			set = updaters.name.set,
		}
	end

	if updaters.size then
		settings.args.size = {
			type = "range",
			name = "Font Size",
			desc = "Set the font size",
			min = 6,
			max = 100,
			step = 1,
			get = updaters.size.get,
			set = updaters.size.set,
		}
	end

	if updaters.outline then
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
			get = updaters.outline.get,
			set = updaters.outline.set,
		}
	end
	return settings
end

local function GetBorderSelector(
	nameGetFunc,
	nameSetFunc,
	sizeGetFunc,
	sizeSetFunc,
	insetGetFunc,
	insetSetFunc,
	colorGetFunc,
	colorSetFunc
)
	return {
		type = "group",
		name = "Borders",
		args = {
			name = {
				type = "select",
				name = "Frame borders",
				width = "full",
				dialogControl = "LSM30_Border",
				values = LSM:HashTable("border"),
				get = nameGetFunc,
				set = nameSetFunc,
			},
			size = {
				type = "range",
				name = "Border size",
				width = "full",
				min = 0,
				max = 30,
				step = 1,
				get = sizeGetFunc,
				set = sizeSetFunc,
			},
			inset = {
				type = "range",
				name = "Border inset",
				width = "full",
				min = 0,
				max = 30,
				step = 1,
				get = insetGetFunc,
				set = insetSetFunc,
			},
			color = {
				type = "color",
				name = "Border color",
				width = "full",
				hasAlpha = true,
				get = colorGetFunc,
				set = colorSetFunc,
			},
		},
	}
end

local function GetTextureSelector(colorGetFunc, colorSetFunc)
	return {
		type = "group",
		name = "Backdrop Settings",
		args = {
			color = {
				type = "color",
				name = "Backdrop color",
				width = "full",
				hasAlpha = true,
				get = colorGetFunc,
				set = colorSetFunc,
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
				font = GetFontSelector({
					name = {
						get = function()
							return CUI.db.profile.tweaks.chat.font.name
						end,
						set = function(_, value)
							CUI.db.profile.tweaks.chat.font.name = value
							CUI:UpdateChat()
						end
					},
					size = {
						get = function()
							return CUI.db.profile.tweaks.chat.font.size
						end,
						set = function(_, value)
							CUI.db.profile.tweaks.chat.font.size = value
							CUI:UpdateChat()
						end
					},
					outline = {
						get = function()
							return CUI.db.profile.tweaks.chat.font.outline
						end,
						set = function(_, value)
							CUI.db.profile.tweaks.chat.font.outline = value
							CUI:UpdateChat()
						end
					},
				})
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
				relX = GetRangeSlider("Relative X position", function()
					return CUI.db.profile.tweaks.housingControlsFrame.relX
				end, function(_, value)
					CUI.db.profile.tweaks.housingControlsFrame.relX = value
					CUI:MoveHousingControlsFrame()
				end),
				relY = GetRangeSlider("Relative Y position", function()
					return CUI.db.profile.tweaks.housingControlsFrame.relY
				end, function(_, value)
					CUI.db.profile.tweaks.housingControlsFrame.relY = value
					CUI:MoveHousingControlsFrame()
				end),
			},
		},
	}
end

local function GetGuildlistOptions(tbl_name)
	return {
		header = {
			type = "group",
			name = "Header settings",
			args = {
				font = GetFontSelector({
					name = {
						get = function()
							return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.font.name
						end,
						set = function(_, value)
							CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.font.name = value
							CUI:SetGuildiesFont()
							CUI:SetGuildiesText()
						end
					},
					size = {
						get = function()
							return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.font.size
						end,
						set = function(_, value)
							CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.font.size = value
							CUI:SetGuildiesFont()
							CUI:SetGuildiesText()
						end
					},
					outline = {
						get = function()
							return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.font.outline
						end,
						set = function(_, value)
							CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.font.outline = value
							CUI:SetGuildiesFont()
							CUI:SetGuildiesText()
						end
					},
				}),
				border = GetBorderSelector(function()
					return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.border.name
				end, function(_, value)
					CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.border.name = value
					CUI:SetGuildiesRootStyle()
					CUI:SetGuildiesText()
				end, function()
					return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.border.size
				end, function(_, value)
					CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.border.size = value
					CUI:SetGuildiesRootStyle()
					CUI:SetGuildiesText()
				end, function()
					return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.border.inset
				end, function(_, value)
					CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.border.inset = value
					CUI:SetGuildiesRootStyle()
					CUI:SetGuildiesText()
				end, function()
					return unpack(CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.border.color)
				end, function(_, r, g, b, a)
					CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.border.color = { r, g, b, a }
					CUI:SetGuildiesRootStyle()
					CUI:SetGuildiesText()
				end),
				backdrop = GetTextureSelector(function()
					return unpack(CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.backdrop.color)
				end, function(_, r, g, b, a)
					CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.backdrop.color = { r, g, b, a }
					CUI:SetGuildiesRootStyle()
				end),
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
								return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.positioning.anchor
							end,
							set = function(_, value)
								CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.positioning.anchor = value
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
								return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.positioning.frameAnchor
							end,
							set = function(_, value)
								CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.positioning.frameAnchor = value
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
								return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.positioning.relX
							end,
							set = function(_, value)
								CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.positioning.relX = value
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
								return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.positioning.relY
							end,
							set = function(_, value)
								CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.positioning.relY = value
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
				font = GetFontSelector({
					name = {
						get = function()
							return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.font.name
						end,
						set = function(_, value)
							CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.font.name = value
							CUI:SetGuildlistFont()
						end,
					},
					outline = {
						get = function()
							return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.font.outline
						end,
						set = function(_, value)
							CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.font.outline = value
							CUI:SetGuildlistFont()
						end,
					},
				}),
				border = GetBorderSelector(function()
					return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.border.name
				end, function(_, value)
					CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.border.name = value
					CUI:SetGuildiesRootStyle()
					CUI:SetGuildiesText()
				end, function()
					return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.border.size
				end, function(_, value)
					CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.border.size = value
					CUI:SetGuildiesRootStyle()
					CUI:SetGuildiesText()
				end, function()
					return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.border.inset
				end, function(_, value)
					CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.border.inset = value
					CUI:SetGuildiesRootStyle()
					CUI:SetGuildiesText()
				end, function()
					return unpack(CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.border.color)
				end, function(_, r, g, b, a)
					CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.border.color = { r, g, b, a }
					CUI:SetGuildiesRootStyle()
					CUI:SetGuildiesText()
				end),
				backdrop = GetTextureSelector(function()
					return unpack(CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.backdrop.color)
				end, function(_, r, g, b, a)
					CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.backdrop.color = { r, g, b, a }
					CUI:SetGuildiesRootStyle()
				end),
			}
		}
	}
end

local function GetFriendlistOptions(tbl_name)
	return {
		header = {
			type = "group",
			name = "Header settings",
			args = {
				font = GetFontSelector({
					name = {
						get = function()
							return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.font.name
						end,
						set = function(_, value)
							CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.font.name = value
							CUI:SetFriendsFont()
							CUI:SetFriendsText()
						end
					},
					size = {
						get = function()
							return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.font.size
						end,
						set = function(_, value)
							CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.font.size = value
							CUI:SetFriendsFont()
							CUI:SetFriendsText()
						end
					},
					outline = {
						get = function()
							return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.font.outline
						end,
						set = function(_, value)
							CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.font.outline = value
							CUI:SetFriendsFont()
							CUI:SetFriendsText()
						end
					}
				}),
				border = GetBorderSelector(function()
					return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.border.name
				end, function(_, value)
					CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.border.name = value
					CUI:SetFriendsRootStyle()
					CUI:SetFriendsText()
				end, function()
					return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.border.size
				end, function(_, value)
					CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.border.size = value
					CUI:SetFriendsRootStyle()
					CUI:SetFriendsText()
				end, function()
					return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.border.inset
				end, function(_, value)
					CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.border.inset = value
					CUI:SetFriendsRootStyle()
					CUI:SetFriendsText()
				end, function()
					return unpack(CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.border.color)
				end, function(_, r, g, b, a)
					CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.border.color = { r, g, b, a }
					CUI:SetFriendsRootStyle()
					CUI:SetFriendsText()
				end),
				backdrop = GetTextureSelector(function()
					return unpack(CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.backdrop.color)
				end, function(_, r, g, b, a)
					CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.backdrop.color = { r, g, b, a }
					CUI:SetFriendsRootStyle()
				end),
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
								return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.positioning.anchor
							end,
							set = function(_, value)
								CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.positioning.anchor = value
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
								return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.positioning.frameAnchor
							end,
							set = function(_, value)
								CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.positioning.frameAnchor = value
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
								return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.positioning.relX
							end,
							set = function(_, value)
								CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.positioning.relX = value
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
								return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.positioning.relY
							end,
							set = function(_, value)
								CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).header.positioning.relY = value
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
				font = GetFontSelector({
					name = {
						get = function()
							return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.font.name
						end,
						set = function(_, value)
							CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.font.name = value
							CUI:SetFriendlistFont()
						end
					},
					outline = {
						get = function()
							return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.font.outline
						end,
						set = function(_, value)
							CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.font.outline = value
							CUI:SetFriendlistFont()
						end,
					}
				}),
				border = GetBorderSelector(function()
					return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.border.name
				end, function(_, value)
					CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.border.name = value
					CUI:SetFriendsRootStyle()
					CUI:SetFriendsText()
				end, function()
					return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.border.size
				end, function(_, value)
					CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.border.size = value
					CUI:SetFriendsRootStyle()
					CUI:SetFriendsText()
				end, function()
					return CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.border.inset
				end, function(_, value)
					CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.border.inset = value
					CUI:SetFriendsRootStyle()
					CUI:SetFriendsText()
				end, function()
					return unpack(CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.border.color)
				end, function(_, r, g, b, a)
					CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.border.color = { r, g, b, a }
					CUI:SetFriendsRootStyle()
					CUI:SetFriendsText()
				end),
				backdrop = GetTextureSelector(function()
					return unpack(CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.backdrop.color)
				end, function(_, r, g, b, a)
					CUI:GetNestedValue(CUI.db.profile.socials, tbl_name).list.backdrop.color = { r, g, b, a }
					CUI:SetFriendsRootStyle()
				end),
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
			args = GetFriendlistOptions("friendlist"),
		},
		guildlist = {
			type = "group",
			name = "Guildlist",
			childGroups = "tab",
			disabled = function()
				return not CUI.db.profile.socials.enableGuildlist
			end,
			args = GetGuildlistOptions("guildlist")
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
					},
				}
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
					},
				}
			},
		},
	},
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
		},
	},
}

function CUI:InitializeAce()
	self.db = LibStub("AceDB-3.0"):New("ChanUIDB", defaultOptions, true)

	-- config
	LibStub("AceConfig-3.0"):RegisterOptionsTable("ChanUI", options)
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
