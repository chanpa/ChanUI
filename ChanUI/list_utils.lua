local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")

---@param dialogName string
---@param text string
---@param button1String string
---@param button2String string
---@param onAcceptFunc function
function CUI:CreatePopupDialog(dialogName, text, button1String, button2String, onAcceptFunc)
	StaticPopupDialogs[dialogName] = {
		text = text,
		button1 = button1String,
		button2 = button2String,
		hasEditBox = true,
		OnShow = function(s)
			s.EditBox:SetText("")
		end,
		OnCancel = function() end,
		OnAccept = function(s, data)
			onAcceptFunc(data, s.EditBox:GetText())
		end,
		EditBoxOnEnterPressed = function(s)
			s:GetParent():GetButton1():Click()
		end,
		EditBoxOnEscapePressed = function(s)
			s:GetParent():GetButton2():Click()
		end,
		timeout = 0,
		whileDead = true,
		preferredIndex = 3,
	}
end

function CUI:CalculateSocialListPadding(borderInset)
	return 10 + (borderInset * 2)
end

---@param fs FontString The font string you want to update
---@param text string The message to display in the font string
---@param padding integer Amount of padding for the parent container
function CUI:UpdateListRootText(fs, text, padding)
	fs:SetText(text)
	local w = fs:GetUnboundedStringWidth()
	local h = fs:GetStringHeight()
	local parent = fs:GetParent()
	parent:SetSize(w + padding, h + padding)
	fs:SetSize(parent:GetWidth(), parent:GetHeight())
end

---Update a frame to the shared look I want
---@param f Frame The frame to update
---@param borderName string The name of the border you want for this frame (not path)
---@param borderSize integer Width of border
---@param borderInset integer Adjust the border distance from edge of background
---@param borderColor table RGBA table of the border color {r=0, g=0, b=0, a=0}
---@param backdropColor table RGBA table of the backdrop color {r=0, g=0, b=0, a=0}
function CUI:UpdateFrameLook(f, borderName, borderSize, borderInset, borderColor, backdropColor, backdropTexture)
	local backdropR, backdropG, backdropB, backdropA = unpack(backdropColor)
	local borderR, borderG, borderB, borderA = unpack(borderColor)

	if not f.SetBackdrop then
		Mixin(f, BackdropTemplateMixin)
	end
	f:SetBackdrop({
		bgFile = LSM:Fetch("background", backdropTexture),
		edgeFile = LSM:Fetch("border", borderName),
		tile = false,
		edgeSize = borderSize,
		tileSize = 32,
		insets = {
			left = borderInset,
			right = borderInset,
			top = borderInset,
			bottom = borderInset,
		},
	})
	f:SetBackdropColor(backdropR, backdropG, backdropB, backdropA)
	f:SetBackdropBorderColor(borderR, borderG, borderB, borderA)
	if f.NineSlice then
		f.NineSlice:Hide()
	end
end

---@param fs FontString
function CUI:UpdateSocialFramePosition(fs, anchor, frameAnchor, relX, relY)
	local parent = fs:GetParent()
	parent:ClearAllPoints()
	parent:SetPoint(frameAnchor, UIParent, anchor, relX, relY)
	fs:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
end

--- @param tooltip LibQTip.Tooltip
function CUI:StyleSlider(tooltip)
	local slider = tooltip.Slider
	if not slider then
		return
	end

	slider:SetBackdrop({
		bgFile = "Interface/Buttons/WHITE8X8",
		edgeFile = "",
		tile = true,
		edgeSize = 0,
		tileSize = 32,
		insets = {
			left = 0,
			right = 0,
			top = 0,
			bottom = 0,
		},
	})
	slider:SetBackdropColor(0, 0, 0, 0.5)
	local thumb = slider:CreateTexture(nil, "OVERLAY")
	thumb:SetSize(8, 8)
	thumb:SetTexture("Interface/Buttons/WHITE8X8")
	thumb:SetColorTexture(1, 1, 1, 0.8)
	slider:SetThumbTexture(thumb)
	tooltip:UpdateLayout()
end

---@param tooltip LibQTip.Tooltip
---@param message string
---@param maxCols integer
---@param headerFont FontObject
---@param padding integer
function CUI:CreateHelpRow(tooltip, message, maxCols, headerFont, padding)
	padding = padding or 0
	tooltip
		:AddRow()
		:GetCell(1)
		:SetLeftPadding(padding)
		:SetColSpan(maxCols)
		:SetFontObject(headerFont)
		:SetJustifyH("CENTER")
		:SetText(message)
end

