local CUI = CUI

function CUI:MoveTopCenterWidget()
	if not UIWidgetTopCenterContainerFrame then
		return
	end

	local frameAnchor = CUI.db.profile.tweaks.topCenterWidget.frameAnchor
	local anchor = CUI.db.profile.tweaks.topCenterWidget.anchor
	local relX = CUI.db.profile.tweaks.topCenterWidget.relX
	local relY = CUI.db.profile.tweaks.topCenterWidget.relY
	UIWidgetTopCenterContainerFrame:ClearAllPoints()
	UIWidgetTopCenterContainerFrame:SetPoint(frameAnchor, UIParent, anchor, relX, relY)
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
