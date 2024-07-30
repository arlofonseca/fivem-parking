local resourceName = 'qbx_core'

if not GetResourceState(resourceName):find('start') then return end

local qbox = {}
local shared = require 'config.shared'

---@param source integer
---@return table
function qbox.getPlayerId(source)
    return exports.qbx_core:GetPlayer(source)
end

---@param identifier string
---@return table
function qbox.getPlayerIdentifier(identifier)
    return exports.qbx_core:GetPlayerFromCitizenId(identifier)
end

---@param player table
---@return integer
function qbox.getIdentifier(player)
    return player.PlayerData.citizenid
end

---@param identifier string
---@return string
function qbox.identifierTypeConversion(identifier)
    return identifier
end

---@param player table
---@return string
function qbox.getFullName(player)
    return player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
end

---@param source integer
---@return number
function qbox.getMoney(source)
    return exports.ox_inventory:GetItem(source, 'money', false, true) or 0
end

---@param source integer
---@param amount number
function qbox.removeMoney(source, amount)
    exports.ox_inventory:RemoveItem(source, 'money', amount)
end

---@param source integer
---@param message string
---@param duration? integer
---@param position? string
---@param _type? string
---@param icon? string
function qbox.Notify(source, message, duration, position, _type, icon)
    return lib.notify(source, {
        title = locale('notification_title'),
        description = message,
        duration = duration,
        position = position,
        type = _type,
        icon = icon,
        iconColor = shared.notifications.iconColors[_type] or '#ffffff',
    })
end

return qbox
