if GetResourceState("es_extended") ~= "started" then return end

local _, ESX = pcall(exports.es_extended.getSharedObject) --[[@as table | false]]

if not ESX then return end

---@param source integer
---@return table
function GetPlayerFromId(source)
    return ESX.GetPlayerFromId(source)
end

---@param identifier string
---@return table
function GetPlayerFromIdentifier(identifier)
    return ESX.GetPlayerFromIdentifier(identifier)
end

---@param player table
---@return string
function GetIdentifier(player)
    return player.identifier
end

---@param identifier string
---@return string
function IdentifierTypeConversion(identifier)
    return identifier
end

---@param player table
---@return string
function GetFullName(player)
    return player.getName()
end

---@param source integer
---@return number
function GetMoney(source)
    local player = GetPlayerFromId(source)
    if not player then return 0 end

    return player.getMoney()
end

---@param source integer
---@param amount number
function RemoveMoney(source, amount)
    local player = GetPlayerFromId(source)
    if not player then return end

    player.removeMoney(amount)
end

---@param source integer
---@param message string
---@param icon string
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
