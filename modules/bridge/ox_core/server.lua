local resourceName = "ox_core"

if not GetResourceState(resourceName):find("start") then return end

CreateThread(function() lib.load("@ox_core.imports.server") end)

local ox = {}

---@param source integer
---@return table
function ox.GetPlayerFromId(source)
    return Ox.GetPlayer(source)
end

---@param identifier integer
---@return table
function ox.GetPlayerFromIdentifier(identifier)
    return Ox.GetPlayerByFilter({ charId = identifier })
end

---@param player table
---@return integer
function ox.GetIdentifier(player)
    return player.charId
end

---@param identifier string
---@return number
function ox.IdentifierTypeConversion(identifier)
    return tonumber(identifier) --[[@as number]]
end

---@param player table
---@return string
function ox.GetFullName(player)
    return player.firstName .. " " .. player.lastName
end

---@param source integer
---@return number
function ox.GetMoney(source)
    return exports.ox_inventory:GetItem(source, "money", false, true) or 0
end

---@param source integer
---@param amount number
function ox.RemoveMoney(source, amount)
    exports.ox_inventory:RemoveItem(source, "money", amount)
end

---@param source integer
---@param message string
---@param duration? integer
---@param position? string
---@param _type? string
---@param icon? string
---@param iconColor? string
function ox.Notify(source, message, duration, position, _type, icon, iconColor)
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

return ox
