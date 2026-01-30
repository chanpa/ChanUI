local CUI = CUI

function CUI:EnableSocialLists()
	self.backdropFramePool = CreateFramePool("Frame", UIParent, "BackdropTemplate")
	self:EnableFriendlist()
	-- if self.db.profile.socials.enableGuildlist then
	-- 	C_GuildInfo.GuildRoster()
	-- 	self:RegisterEvent("GUILD_ROSTER_UPDATE", "UpdateGuild")
	-- 	self:RegisterEvent("PLAYER_GUILD_UPDATE", "UpdateGuild")
	-- 	self:CreatePopupDialog("CHANUI_SET_GUILD_NOTE", "Note", "Accept", "Cancel", GuildRosterSetPublicNote)
	-- 	self:ShowGuild()
	-- end

end


function CUI:CreateSocialOnlineString(prefix, number)
	return prefix .. ": " .. self:ColorText("ff00ff00", number)
end

function CUI:CreateSocialStatusString(isAFK, isDND)
	if isAFK then
		return self:ColorText("ffff8040", "AFK")
	elseif isDND then
		return self:ColorText("ffff8040", "DND")
	end
	return ""
end

function CUI:CreateSocialNameString(otherClass, otherName)
	local color = "fdfdfdfd"
	if otherClass then
		local newClass = string.upper(otherClass:gsub("%s+", ""))
		color = C_ClassColor.GetClassColor(newClass):GenerateHexColor()
	end
	return self:ColorText(color, otherName)
end

function CUI:CreateSocialLevelString(otherLevel)
	if otherLevel == nil then
		return "-"
	end
	local c = GetQuestDifficultyColor(otherLevel)
	local color = self:RGBPercToHex(c.r, c.g, c.b)
	return self:ColorText("ff" .. color, otherLevel)
end

function CUI:CreateSocialTimerunnerString(timerunningSeasonID)
	if timerunningSeasonID then
		return CreateAtlasMarkup("timerunning-glues-icon-small", 9, 12)
	end
	return ""
end

function CUI:CreateSocialRealmString(otherFaction, otherRealmName)
	local color = "ffffffff"
	if otherFaction == "Horde" then
		color = "ffff0000"
	elseif otherFaction == "Alliance" then
		color = "ff0000ff"
	end
	return self:ColorText(color, otherRealmName)
end
