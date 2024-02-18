local nui = {}

---@param action string The action you wish to target
---@param data any The data you wish to send along with this action
function nui.UIMessage(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

---@param shouldShow boolean
---@param impoundOpen? boolean
function nui.ToggleNuiFrame(shouldShow, impoundOpen)
    SetNuiFocus(shouldShow, shouldShow)
    nui.UIMessage("setVisible", { visible = shouldShow, impoundOpen = impoundOpen and impoundOpen or false })
end

return nui
