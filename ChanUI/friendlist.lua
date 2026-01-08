local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")
local QT = LibStub("LibQTip-1.0")

CUI.friendsTable = {}
local clientTranslations = {
    wow_retail = "WoW retail",
    wow_classic_mop = "Mists of Pandaria Classic",
    wow_classic_anniversary = "WoW Classic Anniversary",
    wow_unknown = "Unknown WoW version",
    BSAp = "Mobile",
    WTCG = "Hearthstone",
    App = "Battle.net",
    Pro = "Overwatch II",
    Fen = "Diablo VI",
}
local clientOrder = {
    "wow_retail",
    "wow_classic_mop",
    "wow_classic_anniversary",
    "wow_unknown",
    "Fen",
    "WTCG",
    "Pro",
    "App",
    "BSAp"
}

------ FRAMES -------
function CUI:HideFriends()
    if self.friendRoot then self.friendRoot:Hide() end
    if self.friendsFontString then self.friendsFontString:Hide() end
end

function CUI:ShowFriends()
    if not self.friendRoot then self:CreateFriendRoot() end
    if not self.friendsFontString then self:CreateFriendsOnlineFontString() end
    self.friendRoot:Show()
    self.friendsFontString:Show()
    self:CreateFriendsTable()
end

function CUI:CreateFriendRoot()
    local f = CreateFrame("Frame", "ChanUIFriendFrame", UIParent, "BackdropTemplate")
    f:SetBackdrop(
        {
            bgFile = "Interface/Buttons/WHITE8X8",
            edgeFile = LSM:Fetch("border", self.db.profile.socials.border.name),
            tile = true,
            edgeSize = self.db.profile.socials.border.size,
            tileSize = 32,
            insets = {
                left = self.db.profile.socials.border.inset,
                right = self.db.profile.socials.border.inset,
                top = self.db.profile.socials.border.inset,
                bottom = self.db.profile.socials.border.inset
            }
        }
    )
    f:SetBackdropColor(
        self.db.profile.socials.backdrop.color.r,
        self.db.profile.socials.backdrop.color.g,
        self.db.profile.socials.backdrop.color.b,
        self.db.profile.socials.backdrop.color.a
    )
    f:SetBackdropBorderColor(
        self.db.profile.socials.border.color.r,
        self.db.profile.socials.border.color.g,
        self.db.profile.socials.border.color.b,
        self.db.profile.socials.border.color.a
    )
    f:SetClampedToScreen(false)
    f:EnableMouse(true)

    local anchor = CUI.db.profile.socials.friendlist.positioning.anchor
    local relX = CUI.db.profile.socials.friendlist.positioning.relX
    local relY = CUI.db.profile.socials.friendlist.positioning.relY
    f:SetPoint(anchor, UIParent, anchor, relX, relY)
    f:SetScript("OnEnter", function()
        self:ShowFriendList()
    end)

    self.friendRoot = f
end

function CUI:CreateFriendsOnlineFontString()
    if not self.friendRoot then return end

    local fs = self.friendRoot:CreateFontString(nil, "OVERLAY")
    fs:SetPoint("TOPLEFT", self.friendRoot, "TOPLEFT", 0, 0)
    self:SetFont(fs)
    self.friendsFontString = fs
end


------ FRIEND LIST -------
function CUI:ShowFriendList()
    if self.numberOfOnlineFriends <= 0 then
        self:UpdateSocialText(self.friendsFontString, self:CreateSocialOnlineString("Friends", 0))
        return
    end

    if QT:IsAcquired("ChanUIFriendListFrame") then
        QT:Release(self.friendList)
        self.friendList = nil
    end

    -- create list
    self.friendList = QT:Acquire("ChanUIFriendListFrame", 7, "LEFT", "LEFT", "LEFT", "LEFT", "CENTER", "CENTER", "LEFT")
    self.friendList:SetBackdropColor(0, 0, 0, 1)
    self.friendList:SetBackdropBorderColor(0, 0, 0, 0)
    self.friendList:SmartAnchorTo(self.friendRoot)
    self.friendList:SetAutoHideDelay(0.05, self.friendRoot)

    -- fonts
    local fontPath = LSM:Fetch("font", self.db.profile.font.name)
    local normalFont = CreateFont("ChanUISocialsNormalFont")
    normalFont:SetFont(fontPath, 12, "")
    normalFont:SetTextColor(1, 1, 1)

    local headerFont = CreateFont("ChanUISocialsHeaderFont")
    headerFont:SetFont(fontPath, 12, "OUTLINE")
    headerFont:SetTextColor(1, 0.8, 0)
    
    local headlineFont = CreateFont("ChanUISocialsHeadlineFont")
    headlineFont:SetFont(fontPath, 16, "THICKOUTLINE")
    headlineFont:SetTextColor(1, 0.8, 0)

    self.friendList:SetHeaderFont(headerFont)
    self.friendList:SetFont(normalFont)

    -- help
    self.friendList:AddLine(" ")
    self.friendList:AddLine(" ")
    local line = self.friendList:AddLine()
    self.friendList:SetCell(line, 1, "Left-Click to whisper", headerFont, "CENTER", 7)
    line = self.friendList:AddLine()
    self.friendList:SetCell(line, 1, "Right-Click to dump info", headerFont, "CENTER", 7)
    line = self.friendList:AddLine()
    self.friendList:SetCell(line, 1, "Ctrl-Left-Click to invite", headerFont, "CENTER", 7)
    
    for _, client in pairs(clientOrder) do
        local friends = self.friendsTable[client]
        if friends then
            self.friendList:AddLine(" ")
            self.friendList:AddLine(" ")
            -- headline
            line = self.friendList:AddHeader()
            self.friendList:SetCell(line, 1, clientTranslations[client], headlineFont, "LEFT", 7, QT.LabelProvider, -1)
            self.friendList:AddSeparator()

            -- headers
            line = self.friendList:AddHeader()
            if client:find("^wow") then
                self.friendList:SetCell(line, 1, "")
                self.friendList:SetCell(line, 2, "Real ID")
                self.friendList:SetCell(line, 3, "Lvl")
                self.friendList:SetCell(line, 4, "Name")
                self.friendList:SetCell(line, 5, "Zone")
                self.friendList:SetCell(line, 6, "Realm")
                self.friendList:SetCell(line, 7, "Note")
            else
                self.friendList:SetCell(line, 1, "")
                self.friendList:SetCell(line, 2, "Real ID")
                self.friendList:SetCell(line, 3, "Activity", "CENTER", 4)
                self.friendList:SetCell(line, 7, "Note")
            end


            -- friends
            for _, friend in pairs(self.friendsTable[client]) do
                line = self.friendList:AddLine()
                self.friendList:SetLineScript(line, "OnMouseDown", function(_, button)
                    CUI:ClickOnFriend(button, friend)
                end)
                if client:find("^wow") then
                    self.friendList:SetCell(line, 1, self:CreateSocialStatusString(friend))
                    self.friendList:SetCell(line, 2, friend.accountName)
                    self.friendList:SetCell(line, 3, friend.characterLevel)
                    self.friendList:SetCell(line, 4, friend.characterName)
                    self.friendList:SetCell(line, 5, friend.characterZone)
                    self.friendList:SetCell(line, 6, friend.realmName)
                    self.friendList:SetCell(line, 7, friend.note)
                else
                    self.friendList:SetCell(line, 1, self:CreateSocialStatusString(friend))
                    self.friendList:SetCell(line, 2, friend.accountName)
                    self.friendList:SetCell(line, 3, friend.richPresence, "CENTER", 4)
                    self.friendList:SetCell(line, 7, friend.note)
                end

            end
        end
    end

    -- finished
    self.friendList:UpdateScrolling(GetScreenHeight() * 0.5)
    self.friendList:SetBackdropColor(0, 0, 0, 0.75)
    self.friendList:Show()
    local slider = self.friendList.slider
    if slider then
        slider:SetBackdrop(
            {
                bgFile = "Interface/Buttons/WHITE8X8",
                edgeFile = "",
                tile = true,
                edgeSize = 0,
                tileSize = 32,
                insets = {
                    left = 0,
                    right = 0,
                    top = 0,
                    bottom = 0
                }
            }
        )
        slider:SetBackdropColor(0, 0, 0, 0.8)
        slider:SetThumbTexture("Interface/Buttons/WHITE8X8")
    end
end


function CUI:ClickOnFriend(button, friend)
    if IsControlKeyDown() then
        if not friend.characterName or not friend.realmName then return end
        if button == "LeftButton" then
            C_PartyInfo.InviteUnit(friend.characterName .. "-" .. friend.realmName)
        end
    else
        if button == "LeftButton" then
            ChatFrameUtil.SendBNetTell(friend.accountName)
        elseif button == "RightButton" then
            self:Print(self:DumpObject(friend))
        end
    end
end

------ TABLES -------
function CUI:CreateFriendsTable()
    for _, ct in pairs(self.friendsTable) do
		wipe(ct)
	end

    local count = 0
    for bnetIndex = 1, BNGetNumFriends() do
        local bnetInfo = C_BattleNet.GetFriendAccountInfo(bnetIndex)
        if bnetInfo and bnetInfo.gameAccountInfo and bnetInfo.gameAccountInfo.isOnline then
            local friendInfo = self:ParseBnetInfo(bnetInfo)
            if self.friendsTable[friendInfo.client] == nil then
                self.friendsTable[friendInfo.client] = {}
            end
            self.friendsTable[friendInfo.client][bnetIndex] = friendInfo
            count = count + 1
        end
        bnetIndex = bnetIndex + 1
    end
    self.numberOfOnlineFriends = count
    self:UpdateSocialText(self.friendsFontString, self:CreateSocialOnlineString("Friends", count))
end

---@param bnetInfo BNetAccountInfo
function CUI:ParseBnetInfo(bnetInfo)
    local friend =  {
        accountName = bnetInfo.accountName,
        isAFK = bnetInfo.isAFK,
        isDND = bnetInfo.isDND,
        isFavorite = bnetInfo.isFavorite,
        battleTag = bnetInfo.battleTag,
        message = bnetInfo.customMessage,
        note = bnetInfo.note,
        richPresence = bnetInfo.gameAccountInfo.richPresence,
        isGameAFK = bnetInfo.gameAccountInfo.isGameAFK,
        isGameBusy = bnetInfo.gameAccountInfo.isGameBusy
    }
    local client = bnetInfo.gameAccountInfo.clientProgram
    if client == "WoW" then
        self:ParseWowFriend(friend, bnetInfo.gameAccountInfo)
    else
        friend.client = client
    end
    
    return friend
end

---@param gameAccountInfo BNetGameAccountInfo
function CUI:ParseWowFriend(friend, gameAccountInfo)
    local wowProj = gameAccountInfo.wowProjectID
    if wowProj == 1 then
        friend.client = "wow_retail"
        friend.characterFaction = gameAccountInfo.factionName
    elseif wowProj == 2 then
        friend.client = "wow_classic_anniversary"
    elseif wowProj == 19 then
        friend.client = "wow_classic_mop"
    else
        self:Print("Unknown wowProjectId: " .. wowProj)
        friend.client = "wow_unknown"
    end
    local _, _, _, _, _, _, realmName = GetPlayerInfoByGUID(gameAccountInfo.playerGuid)
    friend.guid = gameAccountInfo.playerGuid
    friend.realmName = realmName
    friend.characterName = gameAccountInfo.characterName
    friend.characterLevel = gameAccountInfo.characterLevel
    friend.characterClass = gameAccountInfo.className
    friend.characterZone = gameAccountInfo.areaName
    friend.timerunningSeasonID = gameAccountInfo.timerunningSeasonID or 0
end