local resourceName = "es_extended"

if not GetResourceState(resourceName):find("start") then return end

local _, ESX = pcall(exports.es_extended.getSharedObject) --[[@as table | false]]

if not ESX then return end

local esx = {}

---@param source integer
---@return table
function esx.GetPlayerFromId(source)
    return ESX.GetPlayerFromId(source)
end

---@param identifier string
---@return table
function esx.GetPlayerFromIdentifier(identifier)
    return ESX.GetPlayerFromIdentifier(identifier)
end

---@param player table
---@return string
function esx.GetIdentifier(player)
    return player.identifier
end

---@param identifier string
---@return string
function esx.IdentifierTypeConversion(identifier)
    return identifier
end

---@param player table
---@return string
function esx.GetFullName(player)
    return player.getName()
end

---@param source integer
---@return number
function esx.GetMoney(source)
    local player = esx.GetPlayerFromId(source)
    if not player then return 0 end

    return player.getMoney()
end

---@param source integer
---@param amount number
function esx.RemoveMoney(source, amount)
    local player = esx.GetPlayerFromId(source)
    if not player then return end

    player.removeMoney(amount)
end

---@param source integer
---@param message string
---@param duration? integer
---@param position? string
---@param _type? string
---@param icon? string
---@param iconColor? string
function esx.Notify(source, message, duration, position, _type, icon, iconColor)
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

return esx
