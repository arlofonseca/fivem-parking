if GetResourceState("ox_core") ~= "started" then return end

CreateThread(function() lib.load("@ox_core.imports.server") end)

---@param source integer
---@return table
function GetPlayerFromId(source)
    return Ox.GetPlayer(source)
end

---@param identifier integer
---@return table
function GetPlayerFromIdentifier(identifier)
    return Ox.GetPlayerByFilter({ charId = identifier })
end

---@param player table
---@return integer
function GetIdentifier(player)
    return player.charId
end

---@param identifier string
---@return number
function IdentifierTypeConversion(identifier)
    return tonumber(identifier) --[[@as number]]
end

---@param player table
---@return string
function GetFullName(player)
    return player.firstName .. " " .. player.lastName
end

---@param source integer
---@return number
function GetMoney(source)
    return exports.ox_inventory:GetItem(source, "money", false, true) or 0
end

---@param source integer
---@param amount number
function RemoveMoney(source, amount)
    exports.ox_inventory:RemoveItem(source, "money", amount)
end

---@param source integer
---@param message string
---@param type "error" | "info" | "success"
function Notify(source, message, icon, type)
    return lib.notify(source, {
        title = locale("notification_title"),
        duration = NotificationDuration,
        description = message,
        position = NotificationPosition,
        icon = icon,
        iconColor = NotificationIconColors[type] or "#ffffff",
    })
end
