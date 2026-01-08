local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")
local QT = LibStub("LibQTip-1.0")
local LRI = LibStub("LibRealmInfo")

CUI.friendsTable = {}
local clientTranslations = {
    retail = "WoW retail",
    classic_mop = "WoW Classic Cataclysm",
    BSAp = "Mobile",
    WTCG = "Hearthstone",
    App = "Battle.net",
    Pro = "Overwatch II"
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
    self:Print("Showing friendlist")
    if self.numberOfOnlineFriends <= 0 then
        self:UpdateSocialText(self.friendsFontString, self:CreateSocialOnlineString("Friends", 0))
        return
    end

    if QT:IsAcquired("ChanUIFriendListFrame") then
        QT:Release(self.friendList)
        self.friendList = nil
    end

    -- create list
    self.friendList = QT:Acquire("ChanUIFriendListFrame", 2, "LEFT", "CENTER")
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
    
    for client, friends in pairs(self.friendsTable) do
        -- headline
        self.friendList:AddLine(" ")
        self.friendList:AddLine(" ")
        local line = self.friendList:AddHeader()
        self.friendList:SetCell(line, 1, clientTranslations[client], headlineFont, "LEFT", 2, QT.LabelProvider, -1)
        self.friendList:AddSeparator()

        -- headers
        line = self.friendList:AddHeader()
        self.friendList:SetCell(line, 1, "Real ID")
        self.friendList:SetCell(line, 2, "Activity")

        -- friends
        for _, friend in pairs(friends) do
            line = self.friendList:AddLine()
            self.friendList:SetLineScript(line, "OnMouseUp", function()
                CUI:ClickOnFriend(friend)
            end)
            self.friendList:SetCell(line, 1, friend.accountName)
            self.friendList:SetCell(line, 2, friend.richPresence)
        end
    end

    -- finished
    self.friendList:UpdateScrolling()
    self.friendList:Show()
end


function CUI:ClickOnFriend(friend)
    if IsControlKeyDown() then
        self:Print(friend.characterName .. "-" .. friend.realmName)
        -- C_PartyInfo.InviteUnit(friend.characterName .. "-" .. LRI:GetRealmInfoByID(friend.realmID).apiName)
    else
        ChatFrame_SendBNetTell(friend.accountName)
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
        richPresence = bnetInfo.gameAccountInfo.richPresence
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
        friend.client = "retail"
        friend.characterFaction = gameAccountInfo.factionName
    elseif wowProj == 19 then
        friend.client = "classic_mop"
    else
        self:Print("Unknown wowProjectId: " .. wowProj)
        friend.client = "unknown_wow"
    end
    local _, _, _, _, _, _, realmName = GetPlayerInfoByGUID(gameAccountInfo.playerGuid)
    friend.realmName = realmName
    friend.characterName = gameAccountInfo.characterName
    friend.characterLevel = gameAccountInfo.characterLevel
    friend.characterClass = gameAccountInfo.className
    friend.characterZone = gameAccountInfo.areaName
    friend.timerunningSeasonID = gameAccountInfo.timerunningSeasonID or 0
end