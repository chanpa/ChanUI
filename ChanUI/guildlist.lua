local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")
local QT = LibStub("LibQTip-2.0")

CUI.guildieTable = {}

local CreateGuildieTable, CreateGuildieRoot, CreateGuildieOnlineFontString, ShowGuildlist
local guildListName = "ChanUIGuildlistFrame"
-------------------------
--- Exposed functions ---
-------------------------

function CUI:HideGuildies()
	if self.guildieRoot then
		self.guildieRoot:Hide()
	end
	if self.guildieFontString then
		self.guildieFontString:Hide()
	end
end

function CUI:ShowGuild()
	if not IsInGuild() then
		return
	end

	CreateGuildieTable()
	if not self.guildieRoot then
		CreateGuildieRoot()
	end
	if not self.guildieFontString then
		CreateGuildieOnlineFontString()
	end
	self.guildieRoot:Show()
	self.guildieFontString:Show()
	self:UpdateSocialText(
		self.guildieFontString,
		self:CreateSocialOnlineString("Guild", self.numberOfOnlineGuildies),
		self:CalculateSocialFramePadding(self.db.profile.socials.guildlist.border.inset)
	)
end
function CUI:UpdateGuild()
	self:ShowGuild()
end

--------------
--- FRAMES ---
--------------

function CreateGuildieRoot()
	local f = CreateFrame("Frame", "ChanUIGuildieFrame", UIParent, "BackdropTemplate")
	f:SetBackdrop({
		bgFile = "Interface/Buttons/WHITE8X8",
		edgeFile = LSM:Fetch("border", CUI.db.profile.socials.guildlist.border.name),
		tile = true,
		edgeSize = CUI.db.profile.socials.guildlist.border.size,
		tileSize = 32,
		insets = {
			left = CUI.db.profile.socials.guildlist.border.inset,
			right = CUI.db.profile.socials.guildlist.border.inset,
			top = CUI.db.profile.socials.guildlist.border.inset,
			bottom = CUI.db.profile.socials.guildlist.border.inset,
		},
	})
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
	if not CUI.guildieRoot then
		return
	end

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

	if QT:IsAcquiredTooltip(guildListName) then
		CUI.guildList:Release()
		CUI.guildList = nil
	end

	-- create list
	local cols = 7
	local tooltip = QT:AcquireTooltip(guildListName, cols, "CENTER", "LEFT", "LEFT", "CENTER", "LEFT", "LEFT", "LEFT")
	tooltip:SmartAnchorTo(CUI.guildieRoot):SetAutoHideDelay(0.05, CUI.guildieRoot):Clear()
	tooltip.NineSlice:Hide()
	CUI:UpdateSocialFrameLook(
		tooltip,
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

	tooltip:SetDefaultHeadingFont(headerFont)
	tooltip:SetDefaultFont(normalFont)

	-- space
	tooltip:AddRow(" ")
	tooltip:AddRow(" ")

	-- help lines [3..6](we might update later (after UpdateScrolling) so they aren't de-centered by the slider)
	local line = tooltip:AddRow(" ")
	line = tooltip:AddRow(" ")
	line = tooltip:AddRow(" ")
	line = tooltip:AddRow(" ")
	CUI:CreateHelpRow(tooltip:GetRow(3), "Left-Click to whisper", cols, headerFont)
	CUI:CreateHelpRow(tooltip:GetRow(4), "Ctrl-Left-Click to invite", cols, headerFont)
	CUI:CreateHelpRow(tooltip:GetRow(5), "Right-Click to set note", cols, headerFont)
	CUI:CreateHelpRow(tooltip:GetRow(6), "Ctrl-Right-Click to dump info", cols, headerFont)

	tooltip:AddRow(" ")
	tooltip:AddRow(" ")

	line = tooltip:AddHeadingRow("", "Lvl", "Name", "Zone", "Realm", "Note", "Rank")
	for _, cell in pairs(line.Cells) do
		cell:SetFontObject()
	end
	tooltip:AddSeparator()
	-- guildies
	for guildIndex, guildie in pairs(CUI.guildieTable) do
		line = tooltip:AddRow(" ")
		line:SetScript("OnMouseDown", function(_, _, button)
			ClickOnGuildie(button, guildie.name, guildie.realm, guildIndex)
		end)
		line:GetCell(1):SetFontObject():SetText(CreateStatusString(guildie.status))
		line:GetCell(2):SetFontObject():SetText(CreateLevelString(guildie.level))
		line:GetCell(3):SetFontObject():SetText(CreateCharString(guildie))
		line:GetCell(4):SetFontObject():SetText(guildie.zone)
		line:GetCell(5):SetFontObject():SetText(CreateRealmString(guildie))
		line:GetCell(6):SetFontObject():SetText(guildie.note)
		line:GetCell(7):SetFontObject():SetText(guildie.rank)
	end

	-- finished
	local percOfScreenAllowed = 0.5
	tooltip:SetMaxHeight(GetScreenHeight() * percOfScreenAllowed)
	tooltip:UpdateLayout()
	CUI:StyleSlider(tooltip, cols, headerFont)

	tooltip:Show()
	CUI.guildList = tooltip
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
			ChatFrame_SendTell(name .. "-" .. realm)
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
		local name, rank, rankIndex, level, _, zone, note, officerNote, connected, memberstatus, className, _, _, isMobile, _, _, guid =
			GetGuildRosterInfo(i)
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
				faction = GetFaction(guid, name),
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

function GetFaction(guid, name)
	if not guid then
		return
	end
	local raceID = C_PlayerInfo.GetRace({ guid = guid })
	if not raceID then
		CUI:Print("Invalid race for " .. name .. ": " .. tostring(raceID))
		return ""
	end
	local faction = C_CreatureInfo.GetFactionInfo(raceID)
	if not faction then
		CUI:Print("Invalid race or faction:" .. tostring(faction))
		return ""
	end
	return faction.name
end

function CreateStatusString(status)
	if status == "AFK" or status == "DND" then
		return CUI:ColorText("ffff8040", status)
	end
	return status
end

function CreateLevelString(level)
	if level == nil then
		return "-"
	end
	local c = GetQuestDifficultyColor(level)
	local color = CUI:RGBPercToHex(c.r, c.g, c.b)
	return CUI:ColorText("ff" .. color, level)
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
