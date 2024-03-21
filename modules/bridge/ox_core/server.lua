local resourceName = "ox_core"

if not GetResourceState(resourceName):find("start") then return end

CreateThread(function() lib.load("@ox_core.imports.server") end)

local ox = {}
local shared = require "config.shared"

---@param source integer
---@return table
function ox.getPlayerId(source)
    return Ox.GetPlayer(source)
end

---@param identifier integer
---@return table
function ox.getPlayerIdentifier(identifier)
    return Ox.GetPlayerFromFilter({ charId = identifier })
end

---@param player table
---@return integer
function ox.getIdentifier(player)
    return player.charId
end

---@param identifier string
---@return number
function ox.identifierTypeConversion(identifier)
    return tonumber(identifier) --[[@as number]]
end

---@param player table
---@return string
function ox.getFullName(player)
    return player.get("firstName") .. " " .. player.get("lastName")
end

---@param source integer
---@return number
function ox.getMoney(source)
    return exports.ox_inventory:GetItem(source, "money", false, true) or 0
end

---@param source integer
---@param amount number
function ox.removeMoney(source, amount)
    exports.ox_inventory:RemoveItem(source, "money", amount)
end

---@param source integer
---@param message string
---@param duration? integer
---@param position? string
---@param _type? string
---@param icon? string
function ox.Notify(source, message, duration, position, _type, icon)
    return lib.notify(source, {
        title = locale("notification_title"),
        description = message,
        duration = duration,
        position = position,
        type = _type,
        icon = icon,
        iconColor = shared.notifications.iconColors[_type] or "#ffffff",
    })
end

return ox
