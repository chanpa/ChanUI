local CUI = CUI
local CHAT_TAB_TEXTURES = {
	"Left",
	"Right",
	"Middle",
	"ActiveLeft",
	"ActiveRight",
	"ActiveMiddle",
	"HighlightLeft",
	"HighlightRight",
	"HighlightMiddle",
}

function CUI:MoveTopCenterFrame()
	if not UIWidgetTopCenterContainerFrame then
		return
	end

	UIWidgetTopCenterContainerFrame:ClearAllPoints()
	UIWidgetTopCenterContainerFrame:SetPoint("TOP", UIParent, "TOP", 0, -55)
end

function CUI:HideExpansionSummary()
	if CUI.db.profile.tweaks.hideExpansionSummaryButton and ExpansionLandingPageMinimapButton then
		ExpansionLandingPageMinimapButton:Hide()
	end
end

function CUI:MoveHousingControlsFrame()
	if not HousingControlsFrame then
		return
	end

	local frameAnchor = CUI.db.profile.tweaks.housingControlsFrame.frameAnchor
	local anchor = CUI.db.profile.tweaks.housingControlsFrame.anchor
	local relX = CUI.db.profile.tweaks.housingControlsFrame.relX
	local relY = CUI.db.profile.tweaks.housingControlsFrame.relY
	HousingControlsFrame:ClearAllPoints()
	HousingControlsFrame:SetPoint(frameAnchor, UIParent, anchor, relX, relY)
end

local function setChatFont(frame)
	CUI:SetFont(
		frame,
		CUI.db.profile.tweaks.chat.font.name,
		CUI.db.profile.tweaks.chat.font.size,
		CUI.db.profile.tweaks.chat.font.outline,
		"Chat"
	)
end

local function changeChatTabSize(chatTab)
	local tabW, tabH = chatTab:GetSize()
	local oldTextW, oldTextH = chatTab.Text:GetSize()
	local newTextW = chatTab.Text:GetUnboundedStringWidth()
	chatTab:SetSize(tabW + (newTextW - oldTextW), tabH)
	chatTab.Text:SetSize(newTextW, oldTextH)
end

function CUI:UpdateChat()
	if not CUI.db.profile.tweaks.enableChatOptions then
		return
	end

	for i = 1, NUM_CHAT_WINDOWS do
		local chatFrame = _G["ChatFrame" .. i]
		local chatTab = _G["ChatFrame" .. i .. "Tab"]

		-- Hide background and border
		local frameName = chatFrame:GetName()
		for j = 1, #CHAT_FRAME_TEXTURES do
			_G[frameName .. CHAT_FRAME_TEXTURES[j]]:SetTexture(nil)
		end

		-- set font in chat and tab
		setChatFont(chatFrame)
		setChatFont(chatTab.Text)
		changeChatTabSize(chatTab)
		-- chatTab:HookScript("OnSizeChanged", function(s)
		--     changeChatTabSize(s)
		-- end)

		-- hide tab textures
		for _, part in pairs(CHAT_TAB_TEXTURES) do
			chatTab[part]:SetTexture(nil)
		end
	end

	-- Hide quicktoast
	QuickJoinToastButton:Hide()
end

function CUI:PLAYER_LOGIN()
	local activities = C_PerksActivities.GetTrackedPerksActivities()
	if activities and activities.trackedIDs then
		for _, id in next, activities.trackedIDs do
			C_PerksActivities.RemoveTrackedPerksActivity(id)
		end
	end
end

function CUI:EnableTweaks()
	self:HookScript(ExpansionLandingPageMinimapButton, "OnShow", "HideExpansionSummary")
	self:RegisterEvent("HOUSE_EDITOR_AVAILABILITY_CHANGED", "MoveHousingControlsFrame")
	self:MoveTopCenterFrame()
	--self:UpdateChat()
end

function CUI:UpdateTweaks()
	self:HideExpansionSummary()
	self:MoveHousingControlsFrame()
	self:MoveTopCenterFrame()
	self:UpdateChat()
end

