local CUI = CUI
local c = 1

function CUI:CreateFriendRoot()
    local f = CreateFrame("Frame", "ChanUIFriendFrame", UIParent, "BackdropTemplate")
    f:SetBackdrop(
        {
            bgFile = "Interface/DialogFrame/UI-DialogBox-Background-Dark",
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
    f:SetBackdropColor(1, 0, 0, 1)
    f:SetClampedToScreen(false)
    f:EnableMouse(true)
    f:SetPoint("CENTER", 0, 0)
    f:SetScript("OnEnter", function()
        c = c + 1
        self:UpdateText("Entered " .. c, self.friendsFontString, 8)
    end)

    self.friendRoot = f
end

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
    }

    local client = bnetInfo.gameAccountInfo.clientProgram
    if client == "WoW" then
        self:ParseWowFriend(friend, bnetInfo)
        self:Print(friend.accountName .. " timerunner: " .. friend.timerunningSeasonID)
    else
        friend.client = client
    end
    return friend
end

---@param bnetInfo BNetAccountInfo
function CUI:ParseWowFriend(friend, bnetInfo)
    self:Print(bnetInfo.accountName .. " wowproj: ".. bnetInfo.gameAccountInfo.wowProjectID)
    local wowProj = bnetInfo.gameAccountInfo.wowProjectID
    if wowProj == 1 then
        -- retail
        friend.client = "retail"
    elseif wowProj == 19 then
        -- mop classic
        friend.client = "classic_mop"
    end
    friend.timerunningSeasonID = bnetInfo.gameAccountInfo.timerunningSeasonID or 0
end

function CUI:CreateFriendsOnlineFontString()
    if not self.friendRoot then return end

    local fs = self.friendRoot:CreateFontString(nil, "OVERLAY")
    fs:SetPoint("TOPLEFT", self.friendRoot, "TOPLEFT", 0, 0)
    self:SetFont(fs)
    self:UpdateText("start", fs, 8)
    self.friendsFontString = fs
end