local nui = {}

---@param action string
---@param data any
function nui.sendReactMessage(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

---Primarily used as a check to determine if the main or impound frame has been opened
---@param visible boolean
---@param state? boolean
function nui.toggleNuiState(visible, state)
    SetNuiFocus(visible, visible)
    nui.sendReactMessage("setVisible", { visible = visible, state = state and state or false })
end

return nui
