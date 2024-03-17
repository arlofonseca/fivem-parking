---Recommended to determine the ownership status of vehicles by utilizing specific identifiers such as 'license', 'license2', etc. 
---Alternatively, if you have alternative methods for identifying vehicle ownership, you can adapt this file accordingly to suit your requirements.
if GetResourceState("ox_core") == "started" then return end
if GetResourceState("es_extended") == "started" then return end
if GetResourceState("qb-core") == "started" then return end

lib.print.warn("Your current framework choice isn't supported. You'll need to make adjustments to the bridge files accordingly.")

local server = {}
local config = require "config"

function server.getPlayerId(source)
    -- Insert your own stuff here
end

function server.getPlayerIdentifier(identifier)
    -- Insert your own stuff here
end

function server.getIdentifier(player)
    -- Insert your own stuff here
end

function server.identifierTypeConversion(identifier)
    return tonumber(identifier) --[[@as number]]
end

function server.getFullName(player)
    -- Insert your own stuff here
end

function server.getMoney(source)
    -- Insert your own stuff here
end

function server.removeMoney(source, amount)
    -- Insert your own stuff here
end

function server.Notify(source, message, duration, position, _type, icon)
    return lib.notify(source, {
        title = locale("notification_title"),
        description = message,
        duration = duration,
        position = position,
        type = _type,
        icon = icon,
        iconColor = config.notifications.iconColors[_type] or "#ffffff",
    })
end

return server
