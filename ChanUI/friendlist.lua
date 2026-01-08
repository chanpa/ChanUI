local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")

CUI.friendsTable = {}

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
    f:SetPoint("TOP", 0, 0)
    f:SetScript("OnEnter", function()
        self:Print(self:DumpObject(self.friendsTable["retail"]))
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


------ TABLES & LOGIC -------
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
    self:UpdateSocialText(self.friendsFontString, "Friends: " .. self:ColorText("ff00ff00", self.numberOfOnlineFriends))
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
    friend.realmID = gameAccountInfo.realmID
    friend.characterName = gameAccountInfo.characterName
    friend.characterLevel = gameAccountInfo.characterLevel
    friend.characterClass = gameAccountInfo.className
    friend.characterZone = gameAccountInfo.areaName
    friend.timerunningSeasonID = gameAccountInfo.timerunningSeasonID or 0
end