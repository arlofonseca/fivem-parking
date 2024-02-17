---@param action string The action you wish to target
---@param data any The data you wish to send along with this action
function UIMessage(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

---@param shouldShow boolean
---@param impoundOpen? boolean
function ToggleNuiFrame(shouldShow, impoundOpen)
    SetNuiFocus(shouldShow, shouldShow)
    UIMessage("setVisible", { visible = shouldShow, impoundOpen = impoundOpen and impoundOpen or false })
end
