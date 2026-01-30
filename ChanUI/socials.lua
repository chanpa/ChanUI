local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")

function CUI:EnableSocialLists()
	self.backdropFramePool = CreateFramePool("Frame", UIParent, "BackdropTemplate")
	self:EnableFriendlist()
	-- if self.db.profile.socials.enableGuildlist then
	-- 	C_GuildInfo.GuildRoster()
	-- 	self:RegisterEvent("GUILD_ROSTER_UPDATE", "UpdateGuild")
	-- 	self:RegisterEvent("PLAYER_GUILD_UPDATE", "UpdateGuild")
	-- 	self:CreatePopupDialog("CHANUI_SET_GUILD_NOTE", "Note", "Accept", "Cancel", GuildRosterSetPublicNote)
	-- 	self:ShowGuild()
	-- end

end

function CUI:CalculateSocialListPadding(borderInset)
	return 10 + (borderInset * 2)
end

---@param fs FontString The font string you want to update
---@param text string The message to display in the font string
---@param padding integer Amount of padding for the parent container
function CUI:UpdateListRootText(fs, text, padding)
	fs:SetText(text)
	local w = fs:GetUnboundedStringWidth()
	local h = fs:GetStringHeight()
	local parent = fs:GetParent()
	parent:SetSize(w + padding, h + padding)
	fs:SetSize(parent:GetWidth(), parent:GetHeight())
end

---Update a frame to the shared look I want
---@param f Frame The frame to update
---@param borderName string The name of the border you want for this frame (not path)
---@param borderSize integer Width of border
---@param borderInset integer Adjust the border distance from edge of background
---@param borderColor table RGBA table of the border color {r=0, g=0, b=0, a=0}
---@param backdropColor table RGBA table of the backdrop color {r=0, g=0, b=0, a=0}
function CUI:UpdateFrameLook(f, borderName, borderSize, borderInset, borderColor, backdropColor)
	local backdropR, backdropG, backdropB, backdropA = unpack(backdropColor)
	local borderR, borderG, borderB, borderA = unpack(borderColor)

	if not f.SetBackdrop then
		Mixin(f, BackdropTemplateMixin)
	end
	f:SetBackdrop({
		bgFile = "Interface/Buttons/WHITE8X8",
		edgeFile = LSM:Fetch("border", borderName),
		tile = true,
		edgeSize = borderSize,
		tileSize = 32,
		insets = {
			left = borderInset,
			right = borderInset,
			top = borderInset,
			bottom = borderInset,
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
function CUI:StyleSlider(tooltip)
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
	tooltip:UpdateLayout()
end

---@param tooltip LibQTip.Tooltip
---@param message string
---@param maxCols integer
---@param headerFont FontObject
---@param padding integer
function CUI:CreateHelpRow(tooltip, message, maxCols, headerFont, padding)
	local row = tooltip:AddRow()
	padding = padding or 0
	row:GetCell(1)
		:SetLeftPadding(padding)
		:SetColSpan(maxCols)
		:SetFontObject(headerFont)
		:SetJustifyH("CENTER")
		:SetText(message)
end
