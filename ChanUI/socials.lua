local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")

function CUI:ShowSocials()
    if self.db.profile.socials.enableFriendlist then
        StaticPopupDialogs["CHANUI_SET_FRIEND_NOTE"] = {
            text = "Note:",
            button1 = "Accept",
            button2 = "Cancel",
            hasEditBox = true,
            OnShow = function(s) s.EditBox:SetText("") end,
            OnCancel = function() end,
            OnAccept = function(s, bnetAccountID)
                BNSetFriendNote(bnetAccountID, s.EditBox:GetText())
            end,
            EditBoxOnEnterPressed = function(s) s:GetParent():GetButton1():Click() end,
            EditBoxOnEscapePressed = function(s) s:GetParent():GetButton2():Click() end,
            timeout = 0,
            whileDead = true,
            preferredIndex = 3
        }
        self:ShowFriends()
    end

    -- if self.db.profile.socials.enableGuilddlist then
    --     self:ShowGuild()
    -- end
end

function CUI:CalculateSocialFramePadding()
    local start_padding = 8
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
    if not f.SetBackdrop then
        Mixin(f, BackdropTemplateMixin)
    end
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

function CUI:CreateSocialNameString(friend)
    local color = "fdfdfdfd"
    if friend.characterClass then
        local newClass = string.upper(friend.characterClass:gsub("%s+", ""))
        color = C_ClassColor.GetClassColor(newClass):GenerateHexColor()
    end
    return self:ColorText(color, friend.characterName)
end

function CUI:CreateSocialTimerunnerString(friend)
    if friend.timerunningSeasonID then
        return CreateAtlasMarkup("timerunning-glues-icon-small", 9, 12)
    end
    return ""
end

function CUI:CreateSocialLevelString(friend)
    if friend.characterLevel == nil then return "-" end
    local c = GetQuestDifficultyColor(friend.characterLevel)
    local color = self:RGBPercToHex(c.r, c.g, c.b)
    return self:ColorText("ff"..color, friend.characterLevel)
end

function CUI:CreateSocialRealmString(friend)
    local color = "ffffffff"
    if friend.characterFaction == "Horde" then
        color = "ffff0000"
    elseif friend.characterFaction == "Alliance" then
        color = "ff0000ff"
    end
    return self:ColorText(color, friend.realmName)
end