local resourceName = "ox_core"

if not GetResourceState(resourceName):find("start") then return end

CreateThread(function() lib.load("@ox_core.imports.client") end)

SetVehicleProperties = lib.setVehicleProperties
GetVehicleProperties = lib.getVehicleProperties

local client = {}
local config = require "config"

---@return boolean
function client.hasJob()
    local data = Ox.GetPlayer()
    if not data.charId then return false end

    for i = 1, #config.jobs do
        if data.getGroup(config.jobs[i]) then
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
function client.Notify(message, duration, position, _type, icon)
    return lib.notify({
        title = locale("notification_title"),
        description = message,
        duration = duration,
        position = position,
        type = _type,
        icon = icon,
        iconColor = config.notifications.iconColors[_type] or "#ffffff",
    })
end

---@param text string
function client.showTextUI(text)
    lib.showTextUI(text)
end

function client.hideTextUI()
    lib.hideTextUI()
end

---@param menu string
function client.showContext(menu)
    lib.showContext(menu)
end

---@param value? boolean
function client.hideContext(value)
    lib.hideContext(value)
end

return client
