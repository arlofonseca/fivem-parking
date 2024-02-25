local nui = {}

---@param action string
---@param data any
function nui.sendReactMessage(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

---@param visible boolean
---@param state? boolean
function nui.toggleNuiFrame(visible, state)
    SetNuiFocus(visible, visible)
    nui.sendReactMessage("setVisible", { visible = visible, state = state and state or false })
end

return nui
