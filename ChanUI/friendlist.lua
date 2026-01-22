local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")
local QT = LibStub:GetLibrary("LibQTip-2.0")

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
local friendListName = "ChanUIFriendListFrame"

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

	-- create list
	local cols = 8
	local tooltip =
		QT:AcquireTooltip(friendListName, cols, "LEFT", "LEFT", "LEFT", "LEFT", "LEFT", "CENTER", "CENTER", "LEFT")
	tooltip:SmartAnchorTo(CUI.friendRoot):SetAutoHideDelay(0.05, CUI.friendRoot):Clear()

	CUI:UpdateSocialFrameLook(
		tooltip,
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

	tooltip:SetDefaultHeadingFont(headerFont)
	tooltip:SetDefaultFont(normalFont)

	-- space
	tooltip:AddRow(" ")
	tooltip:AddRow(" ")

	-- help lines [3..6](we might update later (after UpdateScrolling) so they aren't de-centered by the slider)
	local row = tooltip:AddRow()
	CUI:CreateHelpRow(row, "Left-Click to whisper", cols, headerFont)
	row = tooltip:AddRow()
	CUI:CreateHelpRow(row, "Ctrl-Left-Click to invite", cols, headerFont)
	row = tooltip:AddRow()
	CUI:CreateHelpRow(row, "Right-Click to set note", cols, headerFont)
	row = tooltip:AddRow()
	CUI:CreateHelpRow(row, "Ctrl-Right-Click to dump info", cols, headerFont)

	for _, client in pairs(clientOrder) do
		local friends = CUI.friendsTable[client]
		if friends then
			tooltip:AddRow(" ")
			tooltip:AddRow(" ")

			-- Game title
			row = tooltip:AddRow()
			row:GetCell(1)
				:SetColSpan(cols)
				:SetFontObject(headlineFont)
				:SetJustifyH("LEFT")
				:SetText(clientTranslations[client])
			tooltip:AddSeparator()

			-- Column headers
			local headers
			if client:find("^wow") then
				headers = { "", "Real ID", "Lvl", "", "Name", "Zone", "Realm", "Note" }
			else
				headers = { "", "Real ID", "", "", "", "Activity", "", "Note" }
			end
			row = tooltip:AddHeadingRow(unpack(headers))
			for _, cell in pairs(row.Cells) do
				cell:SetFontObject()
			end

			-- Friend info
			for bnetIndex, friend in pairs(CUI.friendsTable[client]) do
				if client:find("^wow") then
					row = tooltip:AddRow(
						CUI:CreateSocialStatusString(friend),
						friend.accountName,
						CUI:CreateSocialLevelString(friend),
						CUI:CreateSocialTimerunnerString(friend),
						CUI:CreateSocialNameString(friend),
						friend.characterZone,
						CUI:CreateSocialRealmString(friend),
						friend.note
					)
				else
					row = tooltip:AddRow(
						CUI:CreateSocialStatusString(friend),
						friend.accountName,
						"",
						"",
						"",
						friend.richPresence,
						"",
						friend.note
					)
				end
				for _, cell in pairs(row.Cells) do
					cell:SetFontObject()
				end
				row:SetScript("OnMouseDown", function(_, _, button)
					ClickOnFriend(button, friend)
				end)
			end
		end
	end

	-- finished
	local percOfScreenAllowed = 0.5
	tooltip:SetMaxHeight(GetScreenHeight() * percOfScreenAllowed)
	tooltip:UpdateLayout()
	CUI:StyleSlider(tooltip, cols, headerFont)

	tooltip:Show()
	CUI.friendList = tooltip
end

------ TABLES -------
function CreateFriendsTable()
	CUI.friendsTable = {}

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

function ClickOnFriend(button, friend)
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
				dialog.data = friend.bnetAccountID
			end
		end
	end
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

	return CUI:GetRealms("eu")[gameAccountInfo.realmID] or "Unknown"
end
