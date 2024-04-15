-- Recommended to determine the ownership status of vehicles by utilizing specific identifiers such as 'license', 'license2', etc.
-- Alternatively, if you have other methods for identifying vehicle ownership, you can adapt this file accordingly to suit your requirements.
-- Keep in mind that 'oxmysql' and ox_lib' are still required unless other modifications are made.
if GetResourceState("ox_core") == "started" then return end
if GetResourceState("es_extended") == "started" then return end
if GetResourceState("qb-core") == "started" then return end

lib.print.warn("Your current framework choice isn't supported. You'll need to make adjustments to the bridge files accordingly.")

local standalone = {}
local shared = require "config.shared"

function standalone.getPlayerId(source)
    -- Insert your own stuff here
end

function standalone.getPlayerIdentifier(identifier)
    -- Insert your own stuff here
end

function standalone.getIdentifier(player)
    -- Insert your own stuff here
end

function standalone.identifierTypeConversion(identifier)
    return tonumber(identifier) --[[@as number]]
end

function standalone.getFullName(player)
    -- Insert your own stuff here
end

function standalone.getMoney(source)
    -- Insert your own stuff here
end

function standalone.removeMoney(source, amount)
    -- Insert your own stuff here
end

function standalone.Notify(source, message, duration, position, _type, icon)
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

return standalone
