local utils = {}

---@param action string
---@param data any
function utils.sendReactMessage(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

---@todo remove this when impound tab is removed and seperated to it's own individual popup menu 
---Primarily used as a check to determine if the main or impound frame has been opened
---@param visible boolean
---@param state? boolean
function utils.toggleNuiState(visible, state)
    SetNuiFocus(visible, visible)
    utils.sendReactMessage("setVisible", { visible = visible, state = state and state or false })
end

---@param settings table
---@param coords vector3
function utils.createBlip(settings, coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, settings.id)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, settings.scale)
    SetBlipColour(blip, settings.colour)
    SetBlipAsShortRange(blip, true)

    return blip
end

return utils
