local CUI = CUI

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