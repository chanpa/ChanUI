local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")

function CUI:ShowSocials()
    if self.db.profile.socials.enableFriendlist then
        self:RegisterEvent("FRIENDLIST_UPDATE", "UpdateFriends")
        self:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE", "UpdateFriends")
        self:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE", "UpdateFriends")
        self:RegisterEvent("BN_FRIEND_INFO_CHANGED", "UpdateFriends")
        self:RegisterEvent("BN_INFO_CHANGED", "UpdateFriends")
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

function CUI:CalculateSocialFramePadding(borderInset)
    return 10 + (borderInset * 2)
end

---@param fs FontString
function CUI:UpdateSocialText(fs, message, padding)
    local parent = fs:GetParent()
    message = message or fs:GetText()

    fs:SetText(message)
    local w = fs:GetUnboundedStringWidth()
    local h = fs:GetStringHeight()

    parent:SetSize(w + padding, h + padding)
    fs:SetSize(parent:GetWidth(), parent:GetHeight())
end


function CUI:UpdateSocialFrameLook(f, borderName, size, inset, borderColor, backdropColor)
    local backdropR, backdropG, backdropB, backdropA = unpack(backdropColor)
    local borderR, borderG, borderB, borderA = unpack(borderColor)

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
    f:SetBackdropColor(backdropR, backdropG, backdropB, backdropA)
    f:SetBackdropBorderColor(borderR, borderG, borderB, borderA)
end

---@param fs FontString
function CUI:UpdateSocialFramePosition(fs, anchor, relX, relY)
    local parent = fs:GetParent()
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