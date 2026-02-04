local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")
local QT = LibStub("LibQTip-2.0")

-- constants
local POPUP_SET_NOTE_NAME = "CHANUI_SET_GUILD_NOTE"
local GUILDLIST_TT_NAME = "ChanUIGuildlistFrame"
local ROOT_FRAME_NAME = "ChanUIGuildiesRootFrame"

-- locals we will use
local guildiesRoot, guildiesFontString, guildiesOnline, guildiesTable, guildiesList
local normalFont, headerFont, headlineFont

local function GetFaction(guid)
	if not guid then
		return
	end
	local raceID = C_PlayerInfo.GetRace({ guid = guid })
	if not raceID then
		return ""
	end
	local faction = C_CreatureInfo.GetFactionInfo(raceID)
	if not faction then
		return ""
	end
	return faction.name
end

local function ClickOnGuildie(button, guildie, guildIndex)
	if IsControlKeyDown() then
		if button == "LeftButton" then
			C_PartyInfo.InviteUnit(guildie.name .. "-" .. guildie.realm)
		elseif button == "RightButton" then
			local pck = function(...)
				return { n = select("#", ...), ... }
			end
			CUI:Print("--- Guildie entry ---")
			DevTools_Dump(guildie)
			print(" ")
			CUI:Print("--- GetGuildRosterInfo ---")
			DevTools_Dump(pck(GetGuildRosterInfo(guildIndex)))
		end
	else
		if button == "LeftButton" then
			guildie.realm = gsub(guildie.realm, " ", "")
			ChatFrame_SendTell(guildie.name .. "-" .. guildie.realm)
		elseif button == "RightButton" then
			local dialog = StaticPopup_Show("CHANUI_SET_GUILD_NOTE")
			if dialog then
				guildiesList:Hide()
				dialog.data = guildIndex
			end
		end
	end
end

local function ShowGuildlist()
	if guildiesOnline <= 0 then
		CUI:SetGuildiesText(CUI:CreateSocialOnlineString("Guild", 0))
		return
	end

	local cols = 7
	guildiesList =
		QT:AcquireTooltip(GUILDLIST_TT_NAME, cols, "CENTER", "LEFT", "LEFT", "CENTER", "LEFT", "LEFT", "LEFT")
	guildiesList:SmartAnchorTo(guildiesRoot):SetAutoHideDelay(0.05, guildiesRoot):Clear()

	CUI:UpdateFrameLook(
		guildiesList,
		CUI.db.profile.socials.guildlist.border.name,
		CUI.db.profile.socials.guildlist.border.size,
		CUI.db.profile.socials.guildlist.border.inset,
		CUI.db.profile.socials.guildlist.border.color,
		CUI.db.profile.socials.guildlist.backdrop.color
	)

	guildiesList:SetDefaultHeadingFont(headerFont)
	guildiesList:SetDefaultFont(normalFont)
	guildiesList:AddRow(" ")
	guildiesList:AddRow(" ")

	CUI:CreateHelpRow(guildiesList, "Left-Click to whisper", cols, headerFont)
	CUI:CreateHelpRow(guildiesList, "Ctrl-Left-Click to invite", cols, headerFont)
	CUI:CreateHelpRow(guildiesList, "Right-Click to set note", cols, headerFont)
	CUI:CreateHelpRow(guildiesList, "Ctrl-Right-Click to dump info", cols, headerFont)

	guildiesList:AddRow(" ")
	guildiesList:AddRow(" ")

	guildiesList:AddHeadingRow("", "Lvl", "Name", "Zone", "Realm", "Note", "Rank")
	guildiesList:AddSeparator()

	-- guildies
	for guildIndex, guildie in pairs(guildiesTable) do
		guildiesList
			:AddRow(
				CUI:CreateSocialStatusString(guildie.isAFK, guildie.isDND, guildie.isMobile),
				CUI:CreateSocialLevelString(guildie.level),
				CUI:CreateSocialNameString(guildie.class, guildie.name),
				guildie.zone,
				CUI:CreateSocialRealmString(guildie.faction, guildie.realm),
				guildie.note,
				guildie.rank
			)
			:SetScript("OnMouseDown", function(_, _, button)
				ClickOnGuildie(button, guildie, guildIndex)
			end)
	end

	-- finished
	local percOfScreenAllowed = 0.5
	guildiesList:SetMaxHeight(GetScreenHeight() * percOfScreenAllowed)
	guildiesList:UpdateLayout()
	CUI:StyleSlider(guildiesList, cols, headerFont)

	guildiesList:Show()
end

local function CreateGuildiesRoot()
	guildiesRoot = CreateFrame("Frame", ROOT_FRAME_NAME, UIParent, "BackdropTemplate")
	guildiesRoot:SetBackdrop({
		bgFile = "Interface/Buttons/WHITE8X8",
		edgeFile = LSM:Fetch("border", CUI.db.profile.socials.guildlist.border.name),
		tile = true,
		edgeSize = CUI.db.profile.socials.guildlist.border.size,
		tileSize = 32,
		insets = {
			left = CUI.db.profile.socials.guildlist.border.inset,
			right = CUI.db.profile.socials.guildlist.border.inset,
			top = CUI.db.profile.socials.guildlist.border.inset,
			bottom = CUI.db.profile.socials.guildlist.border.inset,
		},
	})
	local r, g, b, a = unpack(CUI.db.profile.socials.guildlist.backdrop.color)
	guildiesRoot:SetBackdropColor(r, g, b, a)
	r, g, b, a = unpack(CUI.db.profile.socials.guildlist.border.color)
	guildiesRoot:SetBackdropBorderColor(r, g, b, a)
	guildiesRoot:SetClampedToScreen(false)
	guildiesRoot:EnableMouse(true)
	guildiesRoot:SetScript("OnEnter", function()
		ShowGuildlist()
	end)
	guildiesRoot:SetScript("OnMouseDown", function(_, button)
		if button == "RightButton" then
			guildiesList:Hide()
			Settings.OpenToCategory(CUI.categoryID)
		end
	end)
end

function CreateGuildiesOnlineFontString()
	if not guildiesRoot then
		CreateGuildiesRoot()
	end

	guildiesFontString = guildiesRoot:CreateFontString(nil, "OVERLAY")
	CUI:SetGuildiesRootPosition()
	CUI:SetGuildiesFont()
	CUI:SetGuildiesText("Guild")
end

local function CreateGuildiesTable()
	guildiesTable = {}
	guildiesOnline = 0
	for i = 1, GetNumGuildMembers() do
		local name, rank, rankIndex, level, _, zone, note, officerNote, connected, memberstatus, className, _, _, isMobile, _, _, guid =
			GetGuildRosterInfo(i)
		if name and (connected or isMobile) then
			local realm
			name, realm = strmatch(name, "(.+)-(.+)")
			guildiesTable[i] = {
				isAFK = memberstatus == 1,
				isDND = memberstatus == 2,
				isMobile = isMobile,
				name = name,
				realm = realm,
				rank = rank,
				level = level,
				zone = zone,
				note = note,
				officerNote = officerNote,
				online = connected,
				class = className,
				rankIndex = rankIndex,
				faction = GetFaction(guid),
			}
			guildiesOnline = guildiesOnline + 1
		end
	end
end

local function CreateGuildlist()
	CreateGuildiesTable()
	CreateGuildiesRoot()
	CreateGuildiesOnlineFontString()
	guildiesRoot:Show()
	guildiesFontString:Show()
	CUI:SetGuildiesText(CUI:CreateSocialOnlineString("Guild", guildiesOnline))
end

local function UpdateGuildiesRootText()
	CreateGuildiesTable()
	CUI:SetGuildiesText(CUI:CreateSocialOnlineString("Guild", guildiesOnline))
end

function CUI:SetGuildiesFont()
	self:SetFont(
		guildiesFontString,
		self.db.profile.socials.guildlist.font.name,
		self.db.profile.socials.guildlist.font.size,
		self.db.profile.socials.guildlist.font.outline
	)
end

function CUI:SetGuildiesText(message)
	if not message then
		message = guildiesFontString:GetText()
	end
	self:UpdateListRootText(
		guildiesFontString,
		message,
		self:CalculateSocialListPadding(self.db.profile.socials.guildlist.border.inset)
	)
end

function CUI:SetGuildiesRootStyle()
	self:UpdateFrameLook(
		guildiesRoot,
		self.db.profile.socials.guildlist.border.name,
		self.db.profile.socials.guildlist.border.size,
		self.db.profile.socials.guildlist.border.inset,
		self.db.profile.socials.guildlist.border.color,
		self.db.profile.socials.guildlist.backdrop.color
	)
end

function CUI:SetGuildiesRootPosition()
	self:UpdateSocialFramePosition(
		guildiesFontString,
		self.db.profile.socials.guildlist.positioning.anchor,
		self.db.profile.socials.guildlist.positioning.frameAnchor,
		self.db.profile.socials.guildlist.positioning.relX,
		self.db.profile.socials.guildlist.positioning.relY
	)
end

function CUI:UpdateGuildlist()
	self:SetGuildiesFont()
	self:SetGuildiesText()
	self:SetGuildiesRootStyle()
	self:SetGuildiesRootPosition()
end

function CUI:DisableGuildlist()
	if guildiesRoot then
		guildiesRoot:Release()
		guildiesRoot = nil
	end
	if guildiesFontString then
		guildiesFontString:Hide()
		guildiesFontString = nil
	end
	guildiesOnline = 0
	guildiesTable = nil
	normalFont = nil
	headerFont = nil
	headlineFont = nil
	self:UnregisterEvent("GUILD_ROSTER_UPDATE")
	self:UnregisterEvent("PLAYER_GUILD_UPDATE")
end

function CUI:EnableGuildlist()
	if not self.db.profile.socials.enableGuildlist then
		return
	end

	C_GuildInfo.GuildRoster()
	self:RegisterEvent("GUILD_ROSTER_UPDATE", UpdateGuildiesRootText)
	self:RegisterEvent("PLAYER_GUILD_UPDATE", UpdateGuildiesRootText)
	self:CreatePopupDialog(POPUP_SET_NOTE_NAME, "Note", "Accept", "Cancel", GuildRosterSetPublicNote)

	local fontPath = LSM:Fetch("font", CUI.db.profile.socials.guildlist.font.name)
	normalFont = CreateFont("ChanUIGuildiesNormalFont")
	normalFont:SetFont(fontPath, 12, "")
	normalFont:SetTextColor(1, 1, 1)

	headerFont = CreateFont("ChanUIFGuildiesHeaderFont")
	headerFont:SetFont(fontPath, 12, "OUTLINE")
	headerFont:SetTextColor(1, 0.8, 0)

	headlineFont = CreateFont("ChanUIGuildiesHeadlineFont")
	headlineFont:SetFont(fontPath, 16, "THICKOUTLINE")
	headlineFont:SetTextColor(1, 0.8, 0)

	CreateGuildlist()
end
