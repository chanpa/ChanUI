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
        self:UpdateText("Entered " .. c, self.friendsOnline, 8)
    end)

    self.friendFrame = f
end

function CUI:CreateFriendsOnline()
    if not self.friendFrame then return end

    local fs = self.friendFrame:CreateFontString(nil, "OVERLAY")
    fs:SetPoint("TOPLEFT", self.friendFrame, "TOPLEFT", 0, 0)
    self:SetFont(fs)
    self:UpdateText("start", fs, 8)
    self.friendsOnline = fs
end