local CUI = CUI

function CUI:CreateSocialOnlineString(prefix, number)
	return prefix .. ": " .. self:ColorText("ff00ff00", number)
end

function CUI:CreateSocialStatusString(isAFK, isDND, isMobile)
	if isAFK then
		return self:ColorText("ffff8040", "AFK")
	elseif isDND then
		return self:ColorText("ffff8040", "DND")
	elseif isMobile then
		return self:ColorText("ffff8040", "Mob")
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
		color = "FFFF0400"
	elseif otherFaction == "Alliance" then
		color = "FF002AFF"
	end
	return self:ColorText(color, otherRealmName)
end
