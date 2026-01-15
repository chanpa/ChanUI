local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")
local QT = LibStub("LibQTip-1.0")

CUI.guildieTable = {}

local CreateGuildieTable, CreateGuildieRoot, CreateGuildieOnlineFontString, ShowGuildlist

-------------------------
--- Exposed functions ---
-------------------------

function CUI:HideGuildies()
    if self.guildieRoot then self.guildieRoot:Hide() end
    if self.guildieFontString then self.guildieFontString:Hide() end
end


function CUI:ShowGuild()
    if not IsInGuild() then return end

    CreateGuildieTable()
    if not self.guildieRoot then CreateGuildieRoot() end
    if not self.guildieFontString then CreateGuildieOnlineFontString() end
    self.guildieRoot:Show()
    self.guildieFontString:Show()
    self:UpdateSocialText(
        self.guildieFontString,
        self:CreateSocialOnlineString("Guild", self.numberOfOnlineGuildies),
        self:CalculateSocialFramePadding(self.db.profile.socials.guildlist.border.inset)
    )
end
function CUI:UpdateGuild() self:ShowGuild() end

--------------
--- FRAMES ---
--------------

function CreateGuildieRoot()
    local f = CreateFrame("Frame", "ChanUIGuildieFrame", UIParent, "BackdropTemplate")
    f:SetBackdrop(
        {
            bgFile = "Interface/Buttons/WHITE8X8",
            edgeFile = LSM:Fetch("border", CUI.db.profile.socials.guildlist.border.name),
            tile = true,
            edgeSize = CUI.db.profile.socials.guildlist.border.size,
            tileSize = 32,
            insets = {
                left = CUI.db.profile.socials.guildlist.border.inset,
                right = CUI.db.profile.socials.guildlist.border.inset,
                top = CUI.db.profile.socials.guildlist.border.inset,
                bottom = CUI.db.profile.socials.guildlist.border.inset
            }
        }
    )
    local r, g, b, a = unpack(CUI.db.profile.socials.guildlist.backdrop.color)
    f:SetBackdropColor(r, g, b, a)
    r, g, b, a = unpack(CUI.db.profile.socials.guildlist.border.color)
    f:SetBackdropBorderColor(r, g, b, a)
    f:SetClampedToScreen(false)
    f:EnableMouse(true)

    local anchor = CUI.db.profile.socials.guildlist.positioning.anchor
    local frameAnchor = CUI.db.profile.socials.guildlist.positioning.frameAnchor
    local relX = CUI.db.profile.socials.guildlist.positioning.relX
    local relY = CUI.db.profile.socials.guildlist.positioning.relY
    f:SetPoint(frameAnchor, UIParent, anchor, relX, relY)
    f:SetScript("OnEnter", function()
        ShowGuildlist()
    end)
    CUI.guildieRoot = f
end

function CreateGuildieOnlineFontString()
    if not CUI.guildieRoot then return end

    local fs = CUI.guildieRoot:CreateFontString(nil, "OVERLAY")
    fs:SetPoint("TOPLEFT", CUI.guildieRoot, "TOPLEFT", 0, 0)
    CUI:SetFont(
        fs,
        CUI.db.profile.socials.guildlist.font.name,
        CUI.db.profile.socials.guildlist.font.size,
        CUI.db.profile.socials.guildlist.font.outline
    )
    fs:SetText("Guild")
    CUI.guildieFontString = fs
end

function ShowGuildlist()
    if CUI.numberOfOnlineGuildies <= 0 then
        CUI:UpdateSocialText(
            CUI.guildieFontString,
            CUI:CreateSocialOnlineString("Guild", 0),
            CUI:CalculateSocialFramePadding(CUI.db.profile.socials.guildlist.border.inset)
        )
        return
    end

    if QT:IsAcquired("ChanUIGuildlistFrame") then
        QT:Release(CUI.guildList)
        CUI.guildList = nil
    end

    -- create list
    local cols = 7
    CUI.guildList = QT:Acquire("ChanUIGuildlistFrame", cols, "CENTER", "LEFT", "LEFT", "CENTER", "LEFT", "LEFT", "LEFT")
    CUI.guildList:SmartAnchorTo(CUI.guildieRoot)
    CUI.guildList:SetAutoHideDelay(0.05, CUI.guildieRoot)
    CUI.guildList:SetBackdropBorderColor(0, 0, 0, 0)
    CUI.guildList:SetBackdropColor(0, 0, 0, 0)
    CUI:UpdateSocialFrameLook(
        CUI.guildList,
        CUI.db.profile.socials.guildlist.border.name,
        CUI.db.profile.socials.guildlist.border.size,
        CUI.db.profile.socials.guildlist.border.inset,
        CUI.db.profile.socials.guildlist.border.color,
        CUI.db.profile.socials.guildlist.backdrop.color
    )

    -- fonts
    local fontPath = LSM:Fetch("font", CUI.db.profile.socials.guildlist.font.name)
    local normalFont = CreateFont("ChanUISocialsNormalFont")
    normalFont:SetFont(fontPath, 12, "")
    normalFont:SetTextColor(1, 1, 1)

    local headerFont = CreateFont("ChanUISocialsHeaderFont")
    headerFont:SetFont(fontPath, 12, "OUTLINE")
    headerFont:SetTextColor(1, 0.8, 0)

    local headlineFont = CreateFont("ChanUISocialsHeadlineFont")
    headlineFont:SetFont(fontPath, 16, "THICKOUTLINE")
    headlineFont:SetTextColor(1, 0.8, 0)

    CUI.guildList:SetHeaderFont(headerFont)
    CUI.guildList:SetFont(normalFont)

    -- space
    CUI.guildList:AddLine(" ")
    CUI.guildList:AddLine(" ")

    -- help lines [3..6](we might update later (after UpdateScrolling) so they aren't de-centered by the slider)
    local line = CUI.guildList:AddLine(" ")
    line = CUI.guildList:AddLine(" ")
    line = CUI.guildList:AddLine(" ")
    line = CUI.guildList:AddLine(" ")
    CUI.guildList:SetCell(3, 1, "Left-Click to whisper", headerFont, "CENTER", cols)
    CUI.guildList:SetCell(4, 1, "Ctrl-Left-Click to invite", headerFont, "CENTER", cols)
    CUI.guildList:SetCell(5, 1, "Right-Click to set public note", headerFont, "CENTER", cols)
    CUI.guildList:SetCell(6, 1, "Ctrl-Right-Click to dump info", headerFont, "CENTER", cols)
    CUI.guildList:AddLine(" ")
    CUI.guildList:AddLine(" ")

    line = CUI.guildList:AddHeader()
    CUI.guildList:SetCell(line, 1, "")
	CUI.guildList:SetCell(line, 2, "Lvl")
	CUI.guildList:SetCell(line, 3, "Name")
	CUI.guildList:SetCell(line, 4, "Zone")
	CUI.guildList:SetCell(line, 5, "Realm")
	CUI.guildList:SetCell(line, 6, "Note")
	CUI.guildList:SetCell(line, 7, "Rank")
    for guildIndex, guildie in pairs(CUI.guildieTable) do
        line = CUI.guildList:AddLine(" ")
        CUI.guildList:SetLineScript(line, "OnMouseDown", function(_, button)
            ClickOnGuildie(button, guildie.name, guildie.realm, guildIndex)
        end)
        CUI.guildList:SetCell(line, 1, CreateStatusString(guildie.status))
        CUI.guildList:SetCell(line, 2, CreateLevelString(guildie.level))
        CUI.guildList:SetCell(line, 3, CreateCharString(guildie))
        CUI.guildList:SetCell(line, 4, guildie.zone)
        CUI.guildList:SetCell(line, 5, CreateRealmString(guildie))
        CUI.guildList:SetCell(line, 6, guildie.note)
        CUI.guildList:SetCell(line, 7, guildie.rank)
    end

    -- finished
    local percOfScreenAllowed = 0.5
    CUI.guildList:UpdateScrolling(GetScreenHeight() * percOfScreenAllowed)

    -- style the slider
    local slider = CUI.guildList.slider
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

        -- slider will nudge our lines to the left, add padding to keep it centered
        local padding = 12 + slider:GetWidth() / 2
        CUI.guildList:SetCell(3, 1, "Left-Click to whisper", headerFont, "CENTER", cols, padding)
        CUI.guildList:SetCell(4, 1, "Ctrl-Left-Click to invite", headerFont, "CENTER", cols, padding)
        CUI.guildList:SetCell(5, 1, "Right-Click to set public note", headerFont, "CENTER", cols, padding)
        CUI.guildList:SetCell(6, 1, "Ctrl-Right-Click to dump info", headerFont, "CENTER", cols, padding)
        CUI.guildList:UpdateScrolling(GetScreenHeight() * percOfScreenAllowed)
    end

    CUI.guildList:Show()
end


function ClickOnGuildie(button, name, realm, guildIndex)
    if IsControlKeyDown() then
        if button == "LeftButton" then
            C_PartyInfo.InviteUnit(name .. "-" .. realm)
        elseif button == "RightButton" then
            DevTools_Dump(CUI.guildieTable)
        end
    else
        if button == "LeftButton" then
            realm = gsub(realm, " ", "")
            ChatFrame_SendTell(name.."-"..realm)
        elseif button == "RightButton" then
            local dialog = StaticPopup_Show("CHANUI_SET_GUILD_NOTE")
            if dialog then
                CUI.guildList:Hide()
                dialog.data = guildIndex
            end
        end
    end
end

------ TABLES -------
function CreateGuildieTable()
    wipe(CUI.guildieTable)

    CUI.numberOfOnlineGuildies = 0
    for i = 1, GetNumGuildMembers() do
        local name, rank, rankIndex, level, _, zone, note, officerNote, connected, memberstatus, className, _, _, isMobile, _, _, guid = GetGuildRosterInfo(i)
        if name and (connected or isMobile) then
            local realm
            name, realm = strmatch(name, "(.+)-(.+)")
            CUI.guildieTable[i] = {
                status = GetStatus(memberstatus, isMobile),
                name = name,
                realm = realm,
                rank = rank,
                level = level,
                zone = zone,
                note = note,
                officerNote = officerNote,
                online = connected,
                class = className,
                rankIndex = rankIndex,
                faction = GetFaction(guid),
            }
            CUI.numberOfOnlineGuildies = CUI.numberOfOnlineGuildies + 1
        end
    end
end


function GetStatus(statusNum, isMobile)
    if statusNum == 1 then
        return "AFK"
    elseif statusNum == 2 then
        return "DND"
    elseif isMobile then
        return "Mobile"
    elseif statusNum == 0 then
        return ""
    end
end

function GetFaction(guid)
    if not guid then return end
    local raceID = C_PlayerInfo.GetRace({guid = guid})
    if not raceID then CUI:Print("Invalid race: "..tostring(raceID)) return "" end
    local faction = C_CreatureInfo.GetFactionInfo(raceID)
    if not faction then CUI:Print("Invalid race or faction:"..tostring(faction)) return "" end
    return faction.name
end

function CreateStatusString(status)
    if status == "AFK" or status == "DND" then
        return CUI:ColorText("ffff8040", status)
    end
    return status
end

function CreateLevelString(level)
    if level == nil then return "-" end
    local c = GetQuestDifficultyColor(level)
    local color = CUI:RGBPercToHex(c.r, c.g, c.b)
    return CUI:ColorText("ff"..color, level)
end

function CreateCharString(guildie)
    local color = "fdfdfdfd"
    if guildie.class then
        local newClass = string.upper(guildie.class:gsub("%s+", ""))
        color = C_ClassColor.GetClassColor(newClass):GenerateHexColor()
    end
    return CUI:ColorText(color, guildie.name)
end

function CreateRealmString(guildie)
    local color
    if guildie.faction == "Horde" then
        color = "ffff0000"
    else
        color = "ff0000ff"
    end

    return CUI:ColorText(color, guildie.realm)
end