local CUI = CUI
local LSM = LibStub("LibSharedMedia-3.0")


function CUI:HideExpansionSummary()
    if self.db.profile.tweaks.hideExpansionSummaryButton and ExpansionLandingPageMinimapButton then
        ExpansionLandingPageMinimapButton:Hide()
    end
end

function CUI:MoveHousingControlsFrame()
    if not HousingControlsFrame then return end
    
    local anchor = self.db.profile.tweaks.housingControlsFrame.anchor
    local relX = self.db.profile.tweaks.housingControlsFrame.relX
    local relY = self.db.profile.tweaks.housingControlsFrame.relY
    HousingControlsFrame:ClearAllPoints()
    HousingControlsFrame:SetPoint(anchor, UIParent, anchor, relX, relY)
end

function CUI:CreateChatBackdrops()
    self.chatBackdrops = {}
    local padding = 5
    for i = 1, NUM_CHAT_WINDOWS do
        local oldChatFrame = _G["ChatFrame"..i]
        local _, _, _, _, _, _, shown = GetChatWindowInfo(i)
        local frameName = oldChatFrame:GetName()
        for j = 1, #CHAT_FRAME_TEXTURES do
            _G[frameName..CHAT_FRAME_TEXTURES[j]]:SetTexture(nil)
        end
        self:SetFont(
            oldChatFrame,
            CUI.db.profile.tweaks.chat.font.name,
            CUI.db.profile.tweaks.chat.font.size,
            CUI.db.profile.tweaks.chat.font.outline
        )
        if shown then
            local f = self.chatBackdrops[i] or CreateFrame("Frame", "Chat"..i.."BackdropFrame", UIParent, "BackdropTemplate")
            local x, y = oldChatFrame:GetSize()
            local point, relTo, relPt, offsetX, offsetY = oldChatFrame:GetPoint()
            local chatLevel = oldChatFrame:GetFrameLevel()
            f:SetFrameStrata("LOW")
            f:SetFrameLevel(chatLevel - 1)
            f:SetSize(x + (padding * 2), y + (padding * 2))
            if point and relTo and relPt and offsetX and offsetY then
                f:SetPoint(point, relTo, relPt, offsetX, offsetY)
            end
            f:SetBackdrop({
                bgFile = "Interface/Buttons/WHITE8X8",
                edgeFile = LSM:Fetch("border", CUI.db.profile.tweaks.chat.border.name),
                tile = true,
                edgeSize = CUI.db.profile.tweaks.chat.border.size,
                tileSize = 32,
                insets = {
                    left = CUI.db.profile.tweaks.chat.border.inset,
                    right = CUI.db.profile.tweaks.chat.border.inset,
                    top = CUI.db.profile.tweaks.chat.border.inset,
                    bottom = CUI.db.profile.tweaks.chat.border.inset
                }
            })
            f:SetBackdropColor(unpack(CUI.db.profile.tweaks.chat.backdrop.color))
            f:SetBackdropBorderColor(unpack(CUI.db.profile.tweaks.chat.border.color))

            x, y = oldChatFrame:GetSize()
            f:SetSize(
                x + (CUI.db.profile.tweaks.chat.border.inset * 2) + (padding * 2),
                y + (CUI.db.profile.tweaks.chat.border.inset * 2) + (padding * 2)
            )
            oldChatFrame:ClearAllPoints()
            oldChatFrame:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", padding + CUI.db.profile.tweaks.chat.border.inset, padding + CUI.db.profile.tweaks.chat.border.inset)
            self.chatBackdrops[i] = f
        end
    end
end

function CUI:UpdateChat()
    local padding = 5
    for i = 1, NUM_CHAT_WINDOWS do
        local _, _, _, _, _, _, shown = GetChatWindowInfo(i)
        if shown then
            local oldChatFrame = _G["ChatFrame"..i]
            local f = self.chatBackdrops[i]
            local x, y = oldChatFrame:GetSize()
            local point, relTo, relPt, offsetX, offsetY = oldChatFrame:GetPoint()
            f:SetSize(
                x + (CUI.db.profile.tweaks.chat.border.inset * 2) + (padding * 2),
                y + (CUI.db.profile.tweaks.chat.border.inset * 2) + (padding * 2)
            )
            if point and relTo and relPt and offsetX and offsetY then
                f:SetPoint(point, UIParent, relPt, offsetX, offsetY)
            end
            oldChatFrame:ClearAllPoints()
            oldChatFrame:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", padding + CUI.db.profile.tweaks.chat.border.inset, padding + CUI.db.profile.tweaks.chat.border.inset)
            self.chatBackdrops[i] = f
        end
    end
end