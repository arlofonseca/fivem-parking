local resourceName = 'qbx_core'

if not GetResourceState(resourceName):find('start') then return end

require '@qbx_core.modules.playerdata'

SetVehicleProperties = lib.setVehicleProperties
GetVehicleProperties = lib.getVehicleProperties

local qbox = {}
local client = require 'config.client'
local shared = require 'config.shared'

---@return boolean
function qbox.hasJob()
    if not QBX.PlayerData or table.type(QBX.PlayerData) == 'empty' then return false end

    for i = 1, #client.jobs do
        if QBX.PlayerData.job.name == client.jobs[i] then
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
function qbox.Notify(message, duration, position, _type, icon)
    return lib.notify({
        title = locale('notification_title'),
        description = message,
        duration = duration,
        position = position,
        type = _type,
        icon = icon,
        iconColor = shared.notifications.iconColors[_type] or '#ffffff',
    })
end

---@param text string
function qbox.showTextUI(text)
    lib.showTextUI(text)
end

function qbox.hideTextUI()
    lib.hideTextUI()
end

---@param menu string
function qbox.showContext(menu)
    lib.showContext(menu)
end

---@param value? boolean
function qbox.hideContext(value)
    lib.hideContext(value)
end

return qbox
