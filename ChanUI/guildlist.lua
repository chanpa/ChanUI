local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")
local QT = LibStub("LibQTip-2.0")

-- constants
local POPUP_SET_NOTE_NAME = "CHANUI_SET_GUILD_NOTE"
local GUILDLIST_TT_NAME = "ChanUIGuildlistFrame"
local ROOT_FRAME_NAME = "ChanUIGuildiesRootFrame"

-- locals we will use
local guildiesRoot, guildiesFontString, guildiesOnline, guildiesTable, guildiesList

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
		CUI.db.profile.socials.guildlist.list.border.name,
		CUI.db.profile.socials.guildlist.list.border.size,
		CUI.db.profile.socials.guildlist.list.border.inset,
		CUI.db.profile.socials.guildlist.list.border.color,
		CUI.db.profile.socials.guildlist.list.backdrop.color
	)

	guildiesList:SetDefaultHeadingFont(CUI.headerGuildiesFont)
	guildiesList:SetDefaultFont(CUI.normalGuildiesFont)
	guildiesList:AddRow(" ")
	guildiesList:AddRow(" ")

	CUI:CreateHelpRow(guildiesList, "Left-Click to whisper", cols, CUI.headerGuildiesFont)
	CUI:CreateHelpRow(guildiesList, "Ctrl-Left-Click to invite", cols, CUI.headerGuildiesFont)
	CUI:CreateHelpRow(guildiesList, "Right-Click to set note", cols, CUI.headerGuildiesFont)
	CUI:CreateHelpRow(guildiesList, "Ctrl-Right-Click to dump info", cols, CUI.headerGuildiesFont)

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
	CUI:StyleSlider(guildiesList, cols, CUI.headerGuildiesFont)

	guildiesList:Show()
end

local function CreateGuildiesRoot()
	guildiesRoot = CreateFrame("Frame", ROOT_FRAME_NAME, UIParent, "BackdropTemplate")
	guildiesRoot:SetBackdrop({
		bgFile = "Interface/Buttons/WHITE8X8",
		edgeFile = LSM:Fetch("border", CUI.db.profile.socials.guildlist.header.border.name),
		tile = true,
		edgeSize = CUI.db.profile.socials.guildlist.header.border.size,
		tileSize = 32,
		insets = {
			left = CUI.db.profile.socials.guildlist.header.border.inset,
			right = CUI.db.profile.socials.guildlist.header.border.inset,
			top = CUI.db.profile.socials.guildlist.header.border.inset,
			bottom = CUI.db.profile.socials.guildlist.header.border.inset,
		},
	})
	local r, g, b, a = unpack(CUI.db.profile.socials.guildlist.header.backdrop.color)
	guildiesRoot:SetBackdropColor(r, g, b, a)
	r, g, b, a = unpack(CUI.db.profile.socials.guildlist.header.border.color)
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
	CUI:SetGuildiesFont()
	CUI:SetGuildiesRootPosition()
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

local function UpdateGuildiesRootText()
	CreateGuildiesTable()
	CUI:SetGuildiesText(CUI:CreateSocialOnlineString("Guild", guildiesOnline))
end

local function CreateGuildlist()
	CreateGuildiesTable()
	CreateGuildiesRoot()
	CreateGuildiesOnlineFontString()
	UpdateGuildiesRootText()
	guildiesRoot:Show()
	guildiesFontString:Show()
end

function CUI:SetGuildiesFont()
	self:SetFont(
		guildiesFontString,
		self.db.profile.socials.guildlist.header.font.name,
		self.db.profile.socials.guildlist.header.font.size,
		self.db.profile.socials.guildlist.header.font.outline,
		"Guildie"
	)
end

function CUI:SetGuildiesText(message)
	if not message then
		message = guildiesFontString:GetText()
	end
	self:UpdateListRootText(
		guildiesFontString,
		message,
		self:CalculateSocialListPadding(self.db.profile.socials.guildlist.header.border.inset)
	)
end

function CUI:SetGuildiesRootStyle()
	self:UpdateFrameLook(
		guildiesRoot,
		self.db.profile.socials.guildlist.header.border.name,
		self.db.profile.socials.guildlist.header.border.size,
		self.db.profile.socials.guildlist.header.border.inset,
		self.db.profile.socials.guildlist.header.border.color,
		self.db.profile.socials.guildlist.header.backdrop.color
	)
end

function CUI:SetGuildiesRootPosition()
	self:UpdateSocialFramePosition(
		guildiesFontString,
		self.db.profile.socials.guildlist.header.positioning.anchor,
		self.db.profile.socials.guildlist.header.positioning.frameAnchor,
		self.db.profile.socials.guildlist.header.positioning.relX,
		self.db.profile.socials.guildlist.header.positioning.relY
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
	CUI.normalGuildiesFont = nil
	CUI.headerGuildiesFont = nil
	CUI.headlineGuildiesFont = nil
	self:UnregisterEvent("GUILD_ROSTER_UPDATE")
	self:UnregisterEvent("PLAYER_GUILD_UPDATE")
end

function CUI:SetGuildlistFont()
	local fontPath = LSM:Fetch("font", CUI.db.profile.socials.guildlist.list.font.name)
	local fontSize = CUI.db.profile.socials.guildlist.list.font.size
	local fontOutline = CUI.db.profile.socials.guildlist.list.font.outline

	CUI.normalGuildiesFont = CreateFont("ChanUIGuildiesNormalFont")
	CUI.normalGuildiesFont:SetFont(fontPath, fontSize, fontOutline)
	CUI.normalGuildiesFont:SetTextColor(1, 1, 1)

	CUI.headerGuildiesFont = CreateFont("ChanUIGuildiesHeaderFont")
	CUI.headerGuildiesFont:SetFont(fontPath, fontSize, fontOutline)
	CUI.headerGuildiesFont:SetTextColor(1, 0.8, 0)

	CUI.headlineGuildiesFont = CreateFont("ChanUIGuildiesHeadlineFont")
	CUI.headlineGuildiesFont:SetFont(fontPath, fontSize + 4, fontOutline)
	CUI.headlineGuildiesFont:SetTextColor(1, 0.8, 0)
end

function CUI:EnableGuildlist()
	if not self.db.profile.socials.enableGuildlist then
		return
	end

	C_GuildInfo.GuildRoster()
	self:RegisterEvent("GUILD_ROSTER_UPDATE", UpdateGuildiesRootText)
	self:RegisterEvent("PLAYER_GUILD_UPDATE", UpdateGuildiesRootText)
	self:CreatePopupDialog(POPUP_SET_NOTE_NAME, "Note", "Accept", "Cancel", GuildRosterSetPublicNote)
	self:SetGuildlistFont()

	CreateGuildlist()
end
