local resourceName = "ox_core"

if not GetResourceState(resourceName):find("start") then return end

CreateThread(function() lib.load("@ox_core.imports.client") end)

SetVehicleProperties = lib.setVehicleProperties
GetVehicleProperties = lib.getVehicleProperties

local client = {}
local config = require "config"

---@return boolean
function client.hasJob()
    local data = Ox.GetPlayerData()
    if not data then return false end

    for i = 1, #config.jobs do
        if data.groups[config.jobs[i]] then
            return true
        end
    end

    return false
end

---@param message string
---@param duration? integer
---@param position? string
---@param _type? string
---@param icon? string
---@param iconColor? string
function client.Notify(message, duration, position, _type, icon, iconColor)
    return lib.notify({
        title = locale("notification_title"),
        description = message,
        duration = duration,
        position = position,
        type = _type,
        icon = icon,
        iconColor = iconColor,
    })
end

---@param text string
function client.showTextUI(text)
    lib.showTextUI(text)
end

function client.hideTextUI()
    lib.hideTextUI()
end

return client
