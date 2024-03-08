local resourceName = "ox_core"

if not GetResourceState(resourceName):find("start") then return end

CreateThread(function() lib.load("@ox_core.imports.server") end)

local server = {}

---@param source integer
---@return table
function server.getPlayerId(source)
    return Ox.GetPlayer(source)
end

---@param identifier integer
---@return table
function server.getPlayerIdentifier(identifier)
    return Ox.GetPlayerFromFilter({ charId = identifier })
end

---@param player table
---@return integer
function server.getIdentifier(player)
    return player.charId
end

---@param identifier string
---@return number
function server.identifierTypeConversion(identifier)
    return tonumber(identifier) --[[@as number]]
end

---@param player table
---@return string
function server.getFullName(player)
    return player.firstName .. " " .. player.lastName
end

---@param source integer
---@return number
function server.getMoney(source)
    return exports.ox_inventory:GetItem(source, "money", false, true) or 0
end

---@param source integer
---@param amount number
function server.removeMoney(source, amount)
    exports.ox_inventory:RemoveItem(source, "money", amount)
end

---@param source integer
---@param message string
---@param duration? integer
---@param position? string
---@param _type? string
---@param icon? string
---@param iconColor? string
function server.Notify(source, message, duration, position, _type, icon, iconColor)
    return lib.notify(source, {
        title = locale("notification_title"),
        description = message,
        duration = duration,
        position = position,
        type = _type,
        icon = icon,
        iconColor = iconColor,
    })
end

return server
