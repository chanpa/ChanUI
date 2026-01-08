local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")

function CUI:ShowSocials()
    if self.db.profile.socials.enableFriendlist then
        self:ShowFriends()
    end

    -- if self.db.profile.socials.enableGuilddlist then
    --     self:ShowGuild()
    -- end
end

function CUI:CalculateSocialFramePadding()
    local start_padding = 5
    return start_padding + (self.db.profile.socials.border.inset * 2)
end

---@param fs FontString
function CUI:UpdateSocialText(fs, message)
    local parent = fs:GetParent()
    local padding = self:CalculateSocialFramePadding()
    message = message or fs:GetText()

    fs:SetText(message)
    local w = fs:GetUnboundedStringWidth()
    local h = fs:GetStringHeight()

    parent:SetSize(w + padding, h + padding)
    fs:SetSize(parent:GetWidth(), parent:GetHeight())
end


function CUI:UpdateSocialFrameLook(f)
    local borderName = self.db.profile.socials.border.name
    local size = self.db.profile.socials.border.size
    local inset = self.db.profile.socials.border.inset
    f:SetBackdrop(
        {
            bgFile = "Interface/Buttons/WHITE8X8",
            edgeFile = LSM:Fetch("border", borderName),
            tile = true,
            edgeSize = size,
            tileSize = 32,
            insets = {
                left = inset,
                right = inset,
                top = inset,
                bottom = inset
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
end

---@param fs FontString
function CUI:UpdateSocialFramePosition(fs)
    local parent = fs:GetParent()
    local anchor = CUI.db.profile.socials.friendlist.positioning.anchor
    local relX = CUI.db.profile.socials.friendlist.positioning.relX
    local relY = CUI.db.profile.socials.friendlist.positioning.relY
    parent:ClearAllPoints()
    parent:SetPoint(anchor, UIParent, anchor, relX, relY)
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
end

function CUI:CreateSocialOnlineString(prefix, number)
    return prefix .. ": " .. self:ColorText("ff00ff00", number)
end

function CUI:CreateSocialStatusString(friend)
    if friend.isAFK or friend.isGameAFK then
		return self:ColorText("ffff8040", "AFK")
	elseif friend.isDND or friend.isGameBusy then
		return self:ColorText("ffff8040", "DND")
	end
	return ""
end