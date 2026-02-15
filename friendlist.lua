local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")
local QT = LibStub:GetLibrary("LibQTip-2.0")

-- constants
local POPUP_SET_NOTE_NAME = "CHANUI_SET_FRIEND_NOTE"
local FRIENDLIST_TT_NAME = "ChanUIFriendListFrame"
local ROOT_FRAME_NAME = "ChanUIFriendsRootFrame"
local CLIENT_TRANSLATIONS = {
	wow_retail = "The War Within",
	wow_classic_mop = "Mists of Pandaria Classic",
	wow_classic_anniversary = "WoW Classic Anniversary",
	wow_classic_anniversary_tbc = "WoW Classic Anniversary TBC",
	wow_unknown = "Unknown WoW version",
	Fen = "Diablo IV",
	OSI = "Diablo II: Resurrected",
	WTCG = "Hearthstone",
	S2 = "StarCraft II",
	Pro = "Overwatch II",
	App = "Battle.net",
	BSAp = "Mobile",
}
local CLIENT_ORDER = {
	"wow_retail",
	"wow_classic_mop",
	"wow_classic_anniversary",
	"wow_classic_anniversary_tbc",
	"wow_unknown",
	"Fen",
	"OSI",
	"WTCG",
	"S2",
	"Pro",
	"App",
	"BSAp",
}

-- locals we will use
local friendsRoot, friendsFontString, friendsTable, friendsOnline, friendsList

local function getRealmName(client, gameAccountInfo)
	if client == "wow_retail" then
		return gameAccountInfo.realmName
	end

	-- todo: make locale a config maybe? or get locale from game state somehow
	return CUI:GetRealmName(gameAccountInfo, "en_GB")
end

local function ClickOnFriend(button, friend)
	if IsControlKeyDown() then
		if button == "LeftButton" then
			if not friend.characterName or not friend.realmName then
				return
			end
			C_PartyInfo.InviteUnit(friend.characterName .. "-" .. friend.realmName)
		elseif button == "RightButton" then
			CUI:Print("--- Friend entry ---")
			DevTools_Dump(friend)
			print(" ")
			CUI:Print("--- GetFriendAccountInfo ---")
			DevTools_Dump(C_BattleNet.GetFriendAccountInfo(friend.bnetIndex))
		end
	else
		if button == "LeftButton" then
			ChatFrameUtil.SendBNetTell(friend.accountName)
		elseif button == "RightButton" then
			local dialog = StaticPopup_Show(POPUP_SET_NOTE_NAME)
			if dialog then
				friendsList:Hide()
				dialog.data = friend.bnetAccountID
			end
		end
	end
end

local function ShowFriendlist()
	if friendsOnline <= 0 then
		CUI:SetFriendText(CUI:CreateSocialOnlineString("Friends", 0))
		return
	end

	local cols = 8
	friendsList =
		QT:AcquireTooltip(FRIENDLIST_TT_NAME, cols, "LEFT", "LEFT", "LEFT", "LEFT", "LEFT", "CENTER", "CENTER", "LEFT")
	friendsList:SmartAnchorTo(friendsRoot):SetAutoHideDelay(0.05, friendsRoot):Clear()

	CUI:UpdateFrameLook(
		friendsList,
		CUI.db.profile.socials.friendlist.list.border.name,
		CUI.db.profile.socials.friendlist.list.border.size,
		CUI.db.profile.socials.friendlist.list.border.inset,
		CUI.db.profile.socials.friendlist.list.border.color,
		CUI.db.profile.socials.friendlist.list.backdrop.color,
		CUI.db.profile.socials.friendlist.list.backdrop.texture
	)

	friendsList:SetDefaultHeadingFont(CUI.headerFriendsFont)
	friendsList:SetDefaultFont(CUI.normalFriendsFont)
	friendsList:AddRow(" ")
	friendsList:AddRow(" ")

	CUI:CreateHelpRow(friendsList, "Left-Click to whisper", cols, CUI.headerFriendsFont)
	CUI:CreateHelpRow(friendsList, "Ctrl-Left-Click to invite", cols, CUI.headerFriendsFont)
	CUI:CreateHelpRow(friendsList, "Right-Click to set note", cols, CUI.headerFriendsFont)
	CUI:CreateHelpRow(friendsList, "Ctrl-Right-Click to dump info", cols, CUI.headerFriendsFont)

	for _, client in pairs(CLIENT_ORDER) do
		local friends = friendsTable[client]
		if friends then
			friendsList:AddRow(" ")
			friendsList:AddRow(" ")

			-- Game title
			friendsList
				:AddRow()
				:GetCell(1)
				:SetColSpan(cols)
				:SetFontObject(CUI.headlineFriendsFont)
				:SetJustifyH("LEFT")
				:SetText(CLIENT_TRANSLATIONS[client])
			friendsList:AddSeparator()

			-- Column headers
			local headers
			if client:find("^wow") then
				headers = { "", "Real ID", "Lvl", "", "Name", "Zone", "Realm", "Note" }
			else
				headers = { "", "Real ID", "", "", "", "Activity", "", "Note" }
			end
			friendsList:AddHeadingRow(unpack(headers))

			-- Friend info
			for _, friend in pairs(friendsTable[client]) do
				local row
				if client:find("^wow") then
					row = friendsList:AddRow(
						CUI:CreateSocialStatusString(friend.isAFK, friend.isDND),
						friend.accountName,
						CUI:CreateSocialLevelString(friend.characterLevel),
						CUI:CreateSocialTimerunnerString(friend.timerunningSeasonID),
						CUI:CreateSocialNameString(friend.characterClass, friend.characterName),
						friend.characterZone,
						CUI:CreateSocialRealmString(friend.characterFaction, friend.realmName),
						friend.note
					)
				else
					row = friendsList:AddRow(
						CUI:CreateSocialStatusString(friend.isAFK, friend.isDND),
						friend.accountName,
						"",
						"",
						"",
						friend.richPresence,
						"",
						friend.note
					)
				end
				row:SetScript("OnMouseDown", function(_, _, button)
					ClickOnFriend(button, friend)
				end)
			end
		end
	end

	local percOfScreenAllowed = 0.5
	friendsList:SetMaxHeight(GetScreenHeight() * percOfScreenAllowed)
	friendsList:UpdateLayout()
	CUI:StyleSlider(friendsList, cols, CUI.headerFriendsFont)

	friendsList:Show()
end

local function CreateFriendsRoot()
	friendsRoot = CreateFrame("Frame", ROOT_FRAME_NAME, UIParent, "BackdropTemplate")
	friendsRoot:SetBackdrop({
		bgFile = LSM:Fetch("background", CUI.db.profile.socials.friendlist.header.backdrop.texture),
		edgeFile = LSM:Fetch("border", CUI.db.profile.socials.friendlist.header.border.name),
		tile = false,
		edgeSize = CUI.db.profile.socials.friendlist.header.border.size,
		tileSize = 32,
		insets = {
			left = CUI.db.profile.socials.friendlist.header.border.inset,
			right = CUI.db.profile.socials.friendlist.header.border.inset,
			top = CUI.db.profile.socials.friendlist.header.border.inset,
			bottom = CUI.db.profile.socials.friendlist.header.border.inset,
		},
	})
	local r, g, b, a = unpack(CUI.db.profile.socials.friendlist.header.backdrop.color)
	friendsRoot:SetBackdropColor(r, g, b, a)
	r, g, b, a = unpack(CUI.db.profile.socials.friendlist.header.border.color)
	friendsRoot:SetBackdropBorderColor(r, g, b, a)
	friendsRoot:SetClampedToScreen(false)
	friendsRoot:EnableMouse(true)
	friendsRoot:SetScript("OnEnter", function()
		ShowFriendlist()
	end)
	friendsRoot:SetScript("OnMouseDown", function(_, button)
		if button == "RightButton" then
			friendsList:Hide()
			Settings.OpenToCategory(CUI.categoryID)
		end
	end)
end

local function CreateFriendsOnlineFontString()
	if not friendsRoot then
		CreateFriendsRoot()
	end

	friendsFontString = friendsRoot:CreateFontString(nil, "OVERLAY")
	CUI:SetFriendsFont()
	CUI:SetFriendsRootPosition()
end

---@param gameAccountInfo BNetGameAccountInfo
local function ParseWowFriend(friend, gameAccountInfo)
	friend.guid = gameAccountInfo.playerGuid
	local wowProj = gameAccountInfo.wowProjectID
	if wowProj == 1 then
		friend.client = "wow_retail"
	elseif wowProj == 2 then
		friend.client = "wow_classic_anniversary"
	elseif wowProj == 5 then
		friend.client = "wow_classic_anniversary_tbc"
	elseif wowProj == 19 then
		friend.client = "wow_classic_mop"
	else
		friend.client = "wow_unknown"
	end

	friend.realmName = getRealmName(friend.client, gameAccountInfo)
	friend.realmID = gameAccountInfo.realmID
	friend.characterFaction = gameAccountInfo.factionName
	friend.characterName = gameAccountInfo.characterName
	friend.characterLevel = gameAccountInfo.characterLevel
	friend.characterClass = gameAccountInfo.className
	friend.characterZone = gameAccountInfo.areaName
	friend.timerunningSeasonID = gameAccountInfo.timerunningSeasonID or nil
end

---@param bnetInfo BNetAccountInfo
local function ParseBnetInfo(bnetInfo, bnetIndex)
	local friend = {
		bnetIndex = bnetIndex,
		bnetAccountID = bnetInfo.bnetAccountID,
		accountName = bnetInfo.accountName,
		isAFK = bnetInfo.isAFK or bnetInfo.gameAccountInfo.isGameAFK,
		isDND = bnetInfo.isDND or bnetInfo.gameAccountInfo.isGameBusy,
		isFavorite = bnetInfo.isFavorite,
		battleTag = bnetInfo.battleTag,
		message = bnetInfo.customMessage,
		note = bnetInfo.note,
		richPresence = bnetInfo.gameAccountInfo.richPresence,
	}
	local client = bnetInfo.gameAccountInfo.clientProgram
	if client == "WoW" then
		ParseWowFriend(friend, bnetInfo.gameAccountInfo)
	else
		friend.client = client
	end

	return friend
end

local function CreateFriendsTable()
	friendsTable = {}
	friendsOnline = 0
	for bnetIndex = 1, BNGetNumFriends() do
		local bnetInfo = C_BattleNet.GetFriendAccountInfo(bnetIndex)
		if bnetInfo and bnetInfo.gameAccountInfo and bnetInfo.gameAccountInfo.isOnline then
			local friendInfo = ParseBnetInfo(bnetInfo, bnetIndex)
			if friendsTable[friendInfo.client] == nil then
				friendsTable[friendInfo.client] = {}
			end
			friendsTable[friendInfo.client][bnetIndex] = friendInfo
			friendsOnline = friendsOnline + 1
		end
		bnetIndex = bnetIndex + 1
	end
end

local function UpdateFriendsRootText()
	CreateFriendsTable()
	CUI:SetFriendsText(CUI:CreateSocialOnlineString("Friends", friendsOnline))
end

local function CreateFriendlist()
	CreateFriendsTable()
	CreateFriendsRoot()
	CreateFriendsOnlineFontString()
	UpdateFriendsRootText()
	friendsRoot:Show()
	friendsFontString:Show()
end

function CUI:SetFriendsFont()
	self:SetFont(
		friendsFontString,
		self.db.profile.socials.friendlist.header.font.name,
		self.db.profile.socials.friendlist.header.font.size,
		self.db.profile.socials.friendlist.header.font.outline,
		"Friend"
	)
end

function CUI:SetFriendsText(message)
	if not message then
		message = friendsFontString:GetText()
	end
	self:UpdateListRootText(
		friendsFontString,
		message,
		self:CalculateSocialListPadding(self.db.profile.socials.friendlist.header.border.inset)
	)
end

function CUI:SetFriendsRootStyle()
	CUI:UpdateFrameLook(
		friendsRoot,
		CUI.db.profile.socials.friendlist.header.border.name,
		CUI.db.profile.socials.friendlist.header.border.size,
		CUI.db.profile.socials.friendlist.header.border.inset,
		CUI.db.profile.socials.friendlist.header.border.color,
		CUI.db.profile.socials.friendlist.header.backdrop.color,
		CUI.db.profile.socials.friendlist.header.backdrop.texture
	)
end

function CUI:SetFriendsRootPosition()
	CUI:UpdateSocialFramePosition(
		friendsFontString,
		CUI.db.profile.socials.friendlist.header.positioning.anchor,
		CUI.db.profile.socials.friendlist.header.positioning.frameAnchor,
		CUI.db.profile.socials.friendlist.header.positioning.relX,
		CUI.db.profile.socials.friendlist.header.positioning.relY
	)
end

function CUI:UpdateFriendlist()
	self:SetFriendsFont()
	self:SetFriendsText()
	self:SetFriendsRootStyle()
	self:SetFriendsRootPosition()
end

function CUI:DisableFriendlist()
	if friendsRoot then
		friendsRoot:Release()
		friendsRoot = nil
	end
	if friendsFontString then
		friendsFontString:Hide()
		friendsFontString = nil
	end
	friendsOnline = 0
	friendsTable = nil
	CUI.normalFriendsFont = nil
	CUI.headerFriendsFont = nil
	CUI.headlineFriendsFont = nil
	self:UnregisterEvent("FRIENDLIST_UPDATE")
	self:UnregisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
	self:UnregisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
	self:UnregisterEvent("BN_FRIEND_INFO_CHANGED")
	self:UnregisterEvent("BN_INFO_CHANGED")
end

function CUI:SetFriendlistFont()
	local fontPath = LSM:Fetch("font", CUI.db.profile.socials.friendlist.list.font.name)
	local fontSize = CUI.db.profile.socials.friendlist.list.font.size
	local fontOutline = CUI.db.profile.socials.friendlist.list.font.outline

	CUI.normalFriendsFont = CreateFont("ChanUIFriendsNormalFont")
	CUI.normalFriendsFont:SetFont(fontPath, fontSize, fontOutline)
	CUI.normalFriendsFont:SetTextColor(1, 1, 1)

	CUI.headerFriendsFont = CreateFont("ChanUIFriendsHeaderFont")
	CUI.headerFriendsFont:SetFont(fontPath, fontSize, fontOutline)
	CUI.headerFriendsFont:SetTextColor(1, 0.8, 0)

	CUI.headlineFriendsFont = CreateFont("ChanUIFriendsHeadlineFont")
	CUI.headlineFriendsFont:SetFont(fontPath, fontSize + 4, fontOutline)
	CUI.headlineFriendsFont:SetTextColor(1, 0.8, 0)
end

function CUI:EnableFriendlist()
	if not self.db.profile.socials.enableFriendlist then
		return
	end

	self:RegisterEvent("FRIENDLIST_UPDATE", UpdateFriendsRootText)
	self:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE", UpdateFriendsRootText)
	self:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE", UpdateFriendsRootText)
	self:RegisterEvent("BN_FRIEND_INFO_CHANGED", CreateFriendsTable)
	self:RegisterEvent("BN_INFO_CHANGED", CreateFriendsTable)
	self:CreatePopupDialog(POPUP_SET_NOTE_NAME, "Note", "Accept", "Cancel", BNSetFriendNote)
	self:SetFriendlistFont()

	CreateFriendlist()
end
