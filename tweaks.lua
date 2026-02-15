local CUI = CUI

function CUI:MoveTopCenterWidget()
	if not UIWidgetTopCenterContainerFrame or not CUI.db.profile.tweaks.topCenterWidget.enable then
		return
	end

	local frameAnchor = CUI.db.profile.tweaks.topCenterWidget.positioning.frameAnchor
	local anchor = CUI.db.profile.tweaks.topCenterWidget.positioning.anchor
	local relX = CUI.db.profile.tweaks.topCenterWidget.positioning.relX
	local relY = CUI.db.profile.tweaks.topCenterWidget.positioning.relY
	UIWidgetTopCenterContainerFrame:ClearAllPoints()
	UIWidgetTopCenterContainerFrame:SetPoint(frameAnchor, UIParent, anchor, relX, relY)
end

function CUI:HideExpansionSummary()
	if CUI.db.profile.tweaks.hideExpansionSummaryButton and ExpansionLandingPageMinimapButton then
		ExpansionLandingPageMinimapButton:Hide()
	end
end

function CUI:MoveHousingControlsFrame()
	if not HousingControlsFrame or not CUI.db.profile.tweaks.housingControlsFrame.enable then
		return
	end

	local frameAnchor = CUI.db.profile.tweaks.housingControlsFrame.positioning.frameAnchor
	local anchor = CUI.db.profile.tweaks.housingControlsFrame.positioning.anchor
	local relX = CUI.db.profile.tweaks.housingControlsFrame.positioning.relX
	local relY = CUI.db.profile.tweaks.housingControlsFrame.positioning.relY
	HousingControlsFrame:ClearAllPoints()
	HousingControlsFrame:SetPoint(frameAnchor, UIParent, anchor, relX, relY)
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
	self:MoveTopCenterWidget()
end

function CUI:UpdateTweaks()
	self:HideExpansionSummary()
	self:MoveHousingControlsFrame()
	self:MoveTopCenterWidget()
end
