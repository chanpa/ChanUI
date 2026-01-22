local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")

function CUI:ShowSocials()
	if self.db.profile.socials.enableFriendlist then
		self:RegisterEvent("FRIENDLIST_UPDATE", "UpdateFriends")
		self:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE", "UpdateFriends")
		self:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE", "UpdateFriends")
		self:RegisterEvent("BN_FRIEND_INFO_CHANGED", "UpdateFriends")
		self:RegisterEvent("BN_INFO_CHANGED", "UpdateFriends")
		StaticPopupDialogs["CHANUI_SET_FRIEND_NOTE"] = {
			text = "Note:",
			button1 = "Accept",
			button2 = "Cancel",
			hasEditBox = true,
			OnShow = function(s)
				s.EditBox:SetText("")
			end,
			OnCancel = function() end,
			OnAccept = function(s, bnetAccountID)
				BNSetFriendNote(bnetAccountID, s.EditBox:GetText())
			end,
			EditBoxOnEnterPressed = function(s)
				s:GetParent():GetButton1():Click()
			end,
			EditBoxOnEscapePressed = function(s)
				s:GetParent():GetButton2():Click()
			end,
			timeout = 0,
			whileDead = true,
			preferredIndex = 3,
		}
		StaticPopupDialogs["CHANUI_SET_GUILD_NOTE"] = {
			text = "Note:",
			button1 = "Accept",
			button2 = "Cancel",
			hasEditBox = true,
			OnShow = function(s)
				s.EditBox:SetText("")
			end,
			OnCancel = function() end,
			OnAccept = function(s, guildIndex)
				GuildRosterSetPublicNote(guildIndex, s.EditBox:GetText())
			end,
			EditBoxOnEnterPressed = function(s)
				s:GetParent():GetButton1():Click()
			end,
			EditBoxOnEscapePressed = function(s)
				s:GetParent():GetButton2():Click()
			end,
			timeout = 0,
			whileDead = true,
			preferredIndex = 3,
		}
		self:ShowFriends()
	end

	if self.db.profile.socials.enableGuildlist then
		self:RegisterEvent("GUILD_ROSTER_UPDATE", "UpdateGuild")
		self:RegisterEvent("PLAYER_GUILD_UPDATE", "UpdateGuild")
		C_GuildInfo.GuildRoster()
		self:ShowGuild()
	end
end

function CUI:CalculateSocialFramePadding(borderInset)
	return 10 + (borderInset * 2)
end

---@param fs FontString
function CUI:UpdateSocialText(fs, message, padding)
	local parent = fs:GetParent()

	if message then
		fs:SetText(message)
	end
	local w = fs:GetUnboundedStringWidth()
	local h = fs:GetStringHeight()

	parent:SetSize(w + padding, h + padding)
	fs:SetSize(parent:GetWidth(), parent:GetHeight())
end

function CUI:UpdateSocialFrameLook(f, borderName, size, inset, borderColor, backdropColor)
	local backdropR, backdropG, backdropB, backdropA = unpack(backdropColor)
	local borderR, borderG, borderB, borderA = unpack(borderColor)

	if not f.SetBackdrop then
		Mixin(f, BackdropTemplateMixin)
	end
	f:SetBackdrop({
		bgFile = "Interface/Buttons/WHITE8X8",
		edgeFile = LSM:Fetch("border", borderName),
		tile = true,
		edgeSize = size,
		tileSize = 32,
		insets = {
			left = inset,
			right = inset,
			top = inset,
			bottom = inset,
		},
	})
	f:SetBackdropColor(backdropR, backdropG, backdropB, backdropA)
	f:SetBackdropBorderColor(borderR, borderG, borderB, borderA)
	if f.NineSlice then
		f.NineSlice:Hide()
	end
end

---@param fs FontString
function CUI:UpdateSocialFramePosition(fs, anchor, frameAnchor, relX, relY)
	local parent = fs:GetParent()
	parent:ClearAllPoints()
	parent:SetPoint(frameAnchor, UIParent, anchor, relX, relY)
	fs:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
end

function CUI:CreateSocialOnlineString(prefix, number)
	return prefix .. ": " .. self:ColorText("ff00ff00", number)
end

function CUI:CreateSocialStatusString(friend)
	if friend.isAFK or friend.isGameAFK then
		return self:ColorText("ffff8040", "AFK")
	elseif friend.isDND or friend.isGameBusy then
		return self:ColorText("ffff8040", "DND")
	end
	return ""
end

function CUI:CreateSocialNameString(friend)
	local color = "fdfdfdfd"
	if friend.characterClass then
		local newClass = string.upper(friend.characterClass:gsub("%s+", ""))
		color = C_ClassColor.GetClassColor(newClass):GenerateHexColor()
	end
	return self:ColorText(color, friend.characterName)
end

function CUI:CreateSocialTimerunnerString(friend)
	if friend.timerunningSeasonID then
		return CreateAtlasMarkup("timerunning-glues-icon-small", 9, 12)
	end
	return ""
end

function CUI:CreateSocialLevelString(friend)
	if friend.characterLevel == nil then
		return "-"
	end
	local c = GetQuestDifficultyColor(friend.characterLevel)
	local color = self:RGBPercToHex(c.r, c.g, c.b)
	return self:ColorText("ff" .. color, friend.characterLevel)
end

function CUI:CreateSocialRealmString(friend)
	local color = "ffffffff"
	if friend.characterFaction == "Horde" then
		color = "ffff0000"
	elseif friend.characterFaction == "Alliance" then
		color = "ff0000ff"
	end
	return self:ColorText(color, friend.realmName)
end

--- @param tooltip LibQTip.Tooltip
--- @param maxCols number
--- @param headerFont FontObject
function CUI:StyleSlider(tooltip, maxCols, headerFont)
	local slider = tooltip.Slider
	if not slider then
		return
	end

	slider:SetBackdrop({
		bgFile = "Interface/Buttons/WHITE8X8",
		edgeFile = "",
		tile = true,
		edgeSize = 0,
		tileSize = 32,
		insets = {
			left = 0,
			right = 0,
			top = 0,
			bottom = 0,
		},
	})
	slider:SetBackdropColor(0, 0, 0, 0.5)
	local thumb = slider:CreateTexture(nil, "OVERLAY")
	thumb:SetSize(8, 8)
	thumb:SetTexture("Interface/Buttons/WHITE8X8")
	thumb:SetColorTexture(1, 1, 1, 0.8)
	slider:SetThumbTexture(thumb)
	local padding = 12 + slider:GetWidth() / 2
	CUI:CreateHelpRow(tooltip:GetRow(3), "Left-Click to whisper", maxCols, headerFont, padding)
	CUI:CreateHelpRow(tooltip:GetRow(4), "Ctrl-Left-Click to invite", maxCols, headerFont, padding)
	CUI:CreateHelpRow(tooltip:GetRow(5), "Right-Click to set note", maxCols, headerFont, padding)
	CUI:CreateHelpRow(tooltip:GetRow(6), "Ctrl-Right-Click to dump info", maxCols, headerFont, padding)
	tooltip:UpdateLayout()
end

---@param row LibQTip-2.0.Row
---@param message string
---@param maxCols integer
---@param headerFont FontObject
---@param padding integer
function CUI:CreateHelpRow(row, message, maxCols, headerFont, padding)
	local cell = row:GetCell(1)
	if padding then
		cell:SetLeftPadding(padding)
	end
	cell:SetColSpan(maxCols):SetFontObject(headerFont):SetJustifyH("CENTER"):SetText(message)
end
