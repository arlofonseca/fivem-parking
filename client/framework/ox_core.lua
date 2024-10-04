local resourceName = 'ox_core'

if not GetResourceState(resourceName):find('start') then return end

require '@ox_core.imports.client'

SetVehicleProperties = lib.setVehicleProperties
GetVehicleProperties = lib.getVehicleProperties

local ox = {}
local client = require 'config.client'

---@return boolean
function ox.hasJob()
    local data = Ox.GetPlayer()
    if not data.charId then return false end

    for i = 1, #client.jobs do
        if data.getGroup(client.jobs[i]) then
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
function ox.Notify(message, duration, position, _type, icon, iconColor)
    return lib.notify({
        title = locale('notification_title'),
        description = message,
        duration = duration,
        position = position,
        type = _type,
        icon = icon,
        iconColor = iconColor or '#ffffff',
    })
end

---@param text string
function ox.showTextUI(text)
    lib.showTextUI(text)
end

function ox.hideTextUI()
    lib.hideTextUI()
end

---@param menu string
function ox.showContext(menu)
    lib.showContext(menu)
end

---@param value? boolean
function ox.hideContext(value)
    lib.hideContext(value)
end

return ox
