local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")
local QT = LibStub("LibQTip-1.0")

CUI.friendsTable = {}
local clientTranslations = {
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
local clientOrder = {
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

local CreateFriendsTable, CreateFriendRoot, CreateFriendsOnlineFontString, ShowFriendlist, ParseBnetInfo, ParseWowFriend, CheckMissingClients, GetRealmName

-------------------------
--- Exposed functions ---
-------------------------

function CUI:HideFriends()
	if self.friendRoot then
		self.friendRoot:Hide()
	end
	if self.friendsFontString then
		self.friendsFontString:Hide()
	end
end

function CUI:ShowFriends()
	CreateFriendsTable()
	if not self.friendRoot then
		CreateFriendRoot()
	end
	if not self.friendsFontString then
		CreateFriendsOnlineFontString()
	end
	self.friendRoot:Show()
	self.friendsFontString:Show()
	self:UpdateSocialText(
		self.friendsFontString,
		self:CreateSocialOnlineString("Friends", self.numberOfOnlineFriends),
		self:CalculateSocialFramePadding(self.db.profile.socials.friendlist.border.inset)
	)
end
function CUI:UpdateFriends()
	self:ShowFriends()
end

--------------
--- FRAMES ---
--------------

function CreateFriendRoot()
	local f = CreateFrame("Frame", "ChanUIFriendFrame", UIParent, "BackdropTemplate")
	f:SetBackdrop({
		bgFile = "Interface/Buttons/WHITE8X8",
		edgeFile = LSM:Fetch("border", CUI.db.profile.socials.friendlist.border.name),
		tile = true,
		edgeSize = CUI.db.profile.socials.friendlist.border.size,
		tileSize = 32,
		insets = {
			left = CUI.db.profile.socials.friendlist.border.inset,
			right = CUI.db.profile.socials.friendlist.border.inset,
			top = CUI.db.profile.socials.friendlist.border.inset,
			bottom = CUI.db.profile.socials.friendlist.border.inset,
		},
	})
	local r, g, b, a = unpack(CUI.db.profile.socials.friendlist.backdrop.color)
	f:SetBackdropColor(r, g, b, a)
	r, g, b, a = unpack(CUI.db.profile.socials.friendlist.border.color)
	f:SetBackdropBorderColor(r, g, b, a)
	f:SetClampedToScreen(false)
	f:EnableMouse(true)

	local anchor = CUI.db.profile.socials.friendlist.positioning.anchor
	local frameAnchor = CUI.db.profile.socials.friendlist.positioning.frameAnchor
	local relX = CUI.db.profile.socials.friendlist.positioning.relX
	local relY = CUI.db.profile.socials.friendlist.positioning.relY
	f:SetPoint(frameAnchor, UIParent, anchor, relX, relY)
	f:SetScript("OnEnter", function()
		ShowFriendlist()
	end)
	CUI.friendRoot = f
end

function CreateFriendsOnlineFontString()
	if not CUI.friendRoot then
		return
	end

	local fs = CUI.friendRoot:CreateFontString(nil, "OVERLAY")
	fs:SetPoint("TOPLEFT", CUI.friendRoot, "TOPLEFT", 0, 0)
	CUI:SetFont(
		fs,
		CUI.db.profile.socials.friendlist.font.name,
		CUI.db.profile.socials.friendlist.font.size,
		CUI.db.profile.socials.friendlist.font.outline
	)
	fs:SetText("Friends")
	CUI.friendsFontString = fs
end

function ShowFriendlist()
	if CUI.numberOfOnlineFriends <= 0 then
		CUI:UpdateSocialText(
			CUI.friendsFontString,
			CUI:CreateSocialOnlineString("Friends", 0),
			CUI:CalculateSocialFramePadding(CUI.db.profile.socials.friendlist.border.inset)
		)
		return
	end

	if QT:IsAcquired("ChanUIFriendListFrame") then
		QT:Release(CUI.friendList)
		CUI.friendList = nil
	end

	-- create list
	local cols = 8
	CUI.friendList =
		QT:Acquire("ChanUIFriendListFrame", cols, "LEFT", "LEFT", "LEFT", "LEFT", "LEFT", "CENTER", "CENTER", "LEFT")
	CUI.friendList:SmartAnchorTo(CUI.friendRoot)
	CUI.friendList:SetAutoHideDelay(0.05, CUI.friendRoot)
	CUI.friendList:SetBackdropBorderColor(0, 0, 0, 0)
	CUI.friendList:SetBackdropColor(0, 0, 0, 0)
	CUI:UpdateSocialFrameLook(
		CUI.friendList,
		CUI.db.profile.socials.friendlist.border.name,
		CUI.db.profile.socials.friendlist.border.size,
		CUI.db.profile.socials.friendlist.border.inset,
		CUI.db.profile.socials.friendlist.border.color,
		CUI.db.profile.socials.friendlist.backdrop.color
	)

	-- fonts
	local fontPath = LSM:Fetch("font", CUI.db.profile.socials.friendlist.font.name)
	local normalFont = CreateFont("ChanUISocialsNormalFont")
	normalFont:SetFont(fontPath, 12, "")
	normalFont:SetTextColor(1, 1, 1)

	local headerFont = CreateFont("ChanUISocialsHeaderFont")
	headerFont:SetFont(fontPath, 12, "OUTLINE")
	headerFont:SetTextColor(1, 0.8, 0)

	local headlineFont = CreateFont("ChanUISocialsHeadlineFont")
	headlineFont:SetFont(fontPath, 16, "THICKOUTLINE")
	headlineFont:SetTextColor(1, 0.8, 0)

	CUI.friendList:SetHeaderFont(headerFont)
	CUI.friendList:SetFont(normalFont)

	-- space
	CUI.friendList:AddLine(" ")
	CUI.friendList:AddLine(" ")

	-- help lines [3..6](we might update later (after UpdateScrolling) so they aren't de-centered by the slider)
	local line = CUI.friendList:AddLine(" ")
	line = CUI.friendList:AddLine(" ")
	line = CUI.friendList:AddLine(" ")
	line = CUI.friendList:AddLine(" ")
	CUI.friendList:SetCell(3, 1, "Left-Click to whisper", headerFont, "CENTER", cols)
	CUI.friendList:SetCell(4, 1, "Ctrl-Left-Click to invite", headerFont, "CENTER", cols)
	CUI.friendList:SetCell(5, 1, "Right-Click to set bnet note", headerFont, "CENTER", cols)
	CUI.friendList:SetCell(6, 1, "Ctrl-Right-Click to dump info", headerFont, "CENTER", cols)

	for _, client in pairs(clientOrder) do
		local friends = CUI.friendsTable[client]
		if friends then
			CUI.friendList:AddLine(" ")
			CUI.friendList:AddLine(" ")

			-- headline
			line = CUI.friendList:AddHeader()
			CUI.friendList:SetCell(
				line,
				1,
				clientTranslations[client],
				headlineFont,
				"LEFT",
				cols,
				QT.LabelProvider,
				-1
			)
			CUI.friendList:AddSeparator()

			-- headers
			line = CUI.friendList:AddHeader()
			if client:find("^wow") then
				CUI.friendList:SetCell(line, 1, "") --status
				CUI.friendList:SetCell(line, 2, "Real ID")
				CUI.friendList:SetCell(line, 3, "Lvl")
				CUI.friendList:SetCell(line, 4, "") --is timerunner
				CUI.friendList:SetCell(line, 5, "Name")
				CUI.friendList:SetCell(line, 6, "Zone")
				CUI.friendList:SetCell(line, 7, "Realm")
				CUI.friendList:SetCell(line, 8, "Note")
			else
				CUI.friendList:SetCell(line, 1, "") --status
				CUI.friendList:SetCell(line, 2, "Real ID")
				CUI.friendList:SetCell(line, 6, "Activity")
				CUI.friendList:SetCell(line, 8, "Note")
			end

			-- friends
			for bnetIndex, friend in pairs(CUI.friendsTable[client]) do
				line = CUI.friendList:AddLine()
				CUI.friendList:SetLineScript(line, "OnMouseDown", function(_, button)
					ClickOnFriend(button, friend, friend.bnetAccountID)
				end)
				if client:find("^wow") then
					CUI.friendList:SetCell(line, 1, CUI:CreateSocialStatusString(friend))
					CUI.friendList:SetCell(line, 2, friend.accountName)
					CUI.friendList:SetCell(line, 3, CUI:CreateSocialLevelString(friend))
					CUI.friendList:SetCell(line, 4, CUI:CreateSocialTimerunnerString(friend))
					CUI.friendList:SetCell(line, 5, CUI:CreateSocialNameString(friend))
					CUI.friendList:SetCell(line, 6, friend.characterZone)
					CUI.friendList:SetCell(line, 7, CUI:CreateSocialRealmString(friend))
					CUI.friendList:SetCell(line, 8, friend.note)
				else
					CUI.friendList:SetCell(line, 1, CUI:CreateSocialStatusString(friend))
					CUI.friendList:SetCell(line, 2, friend.accountName)
					CUI.friendList:SetCell(line, 6, friend.richPresence)
					CUI.friendList:SetCell(line, 8, friend.note)
				end
			end
		end
	end

	-- finished
	local percOfScreenAllowed = 0.5
	CUI.friendList:UpdateScrolling(GetScreenHeight() * percOfScreenAllowed)

	-- style the slider
	local slider = CUI.friendList.slider
	if slider then
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
		slider:SetBackdropColor(0, 0, 0, 0.8)
		slider:SetThumbTexture("Interface/Buttons/WHITE8X8")

		-- slider will nudge our lines to the left, add padding to keep it centered
		local padding = 12 + slider:GetWidth() / 2
		CUI.friendList:SetCell(3, 1, "Left-Click to whisper", headerFont, "CENTER", cols, padding)
		CUI.friendList:SetCell(4, 1, "Ctrl-Left-Click to invite", headerFont, "CENTER", cols, padding)
		CUI.friendList:SetCell(5, 1, "Right-Click to set bnet note", headerFont, "CENTER", cols, padding)
		CUI.friendList:SetCell(6, 1, "Ctrl-Right-Click to dump info", headerFont, "CENTER", cols, padding)
		CUI.friendList:UpdateScrolling(GetScreenHeight() * percOfScreenAllowed)
	end

	CUI.friendList:Show()
end

function ClickOnFriend(button, friend, bnetAccountID)
	if IsControlKeyDown() then
		if button == "LeftButton" then
			if not friend.characterName or not friend.realmName then
				return
			end
			C_PartyInfo.InviteUnit(friend.characterName .. "-" .. friend.realmName)
		elseif button == "RightButton" then
			DevTools_Dump(friend)
			CheckMissingClients()
		end
	else
		if button == "LeftButton" then
			ChatFrameUtil.SendBNetTell(friend.accountName)
		elseif button == "RightButton" then
			local dialog = StaticPopup_Show("CHANUI_SET_FRIEND_NOTE")
			if dialog then
				CUI.friendList:Hide()
				dialog.data = bnetAccountID
			end
		end
	end
end

------ TABLES -------
function CreateFriendsTable()
	for _, ct in pairs(CUI.friendsTable) do
		wipe(ct)
	end

	local count = 0
	for bnetIndex = 1, BNGetNumFriends() do
		local bnetInfo = C_BattleNet.GetFriendAccountInfo(bnetIndex)
		if bnetInfo and bnetInfo.gameAccountInfo and bnetInfo.gameAccountInfo.isOnline then
			local friendInfo = ParseBnetInfo(bnetInfo, bnetIndex)
			if CUI.friendsTable[friendInfo.client] == nil then
				CUI.friendsTable[friendInfo.client] = {}
			end
			CUI.friendsTable[friendInfo.client][bnetIndex] = friendInfo
			count = count + 1
		end
		bnetIndex = bnetIndex + 1
	end
	CUI.numberOfOnlineFriends = count
end

---@param bnetInfo BNetAccountInfo
function ParseBnetInfo(bnetInfo, bnetIndex)
	local friend = {
		bnetIndex = bnetIndex,
		bnetAccountID = bnetInfo.bnetAccountID,
		accountName = bnetInfo.accountName,
		isAFK = bnetInfo.isAFK,
		isDND = bnetInfo.isDND,
		isFavorite = bnetInfo.isFavorite,
		battleTag = bnetInfo.battleTag,
		message = bnetInfo.customMessage,
		note = bnetInfo.note,
		richPresence = bnetInfo.gameAccountInfo.richPresence,
		isGameAFK = bnetInfo.gameAccountInfo.isGameAFK,
		isGameBusy = bnetInfo.gameAccountInfo.isGameBusy,
	}
	local client = bnetInfo.gameAccountInfo.clientProgram
	if client == "WoW" then
		ParseWowFriend(friend, bnetInfo.gameAccountInfo)
	else
		friend.client = client
	end

	return friend
end

---@param gameAccountInfo BNetGameAccountInfo
function ParseWowFriend(friend, gameAccountInfo)
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
		CUI:Print("Unknown wowProjectId: " .. wowProj)
		friend.client = "wow_unknown"
	end

	friend.realmName = GetRealmName(friend, gameAccountInfo)
	friend.realmID = gameAccountInfo.realmID
	friend.characterFaction = gameAccountInfo.factionName
	friend.characterName = gameAccountInfo.characterName
	friend.characterLevel = gameAccountInfo.characterLevel
	friend.characterClass = gameAccountInfo.className
	friend.characterZone = gameAccountInfo.areaName
	friend.timerunningSeasonID = gameAccountInfo.timerunningSeasonID or nil
end

function CheckMissingClients()
	local missing = {}
	for friendClient, friends in pairs(CUI.friendsTable) do
		local isMissing = true
		for rawClient, _ in pairs(clientTranslations) do
			if friendClient == rawClient then
				isMissing = false
				break
			end
		end
		if isMissing then
			missing[friendClient] = friends
		end
	end

	if next(missing) == nil then
		CUI:Print("No missing games")
		return
	end
	for k, v in pairs(missing) do
		for _, friend in pairs(v) do
			print(k .. ": " .. tostring(friend.accountName))
		end
	end
end

function GetRealmName(friend, gameAccountInfo)
	if friend.client == "wow_retail" then
		return gameAccountInfo.realmName
	end

	if not CUI.realm_id_to_name then
		CUI.realm_id_to_name = CUI:GetRealms()
	end
	return CUI.realm_id_to_name[gameAccountInfo.realmID] or "Unknown"
end