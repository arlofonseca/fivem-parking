if GetResourceState("ox_core") ~= "started" then return end

CreateThread(function() lib.load("@ox_core.imports.client") end)

SetVehicleProperties = lib.setVehicleProperties
GetVehicleProperties = lib.getVehicleProperties

---@return boolean
function HasJob()
    local data = Ox.GetPlayerData()
    if not data then return false end

    for i = 1, #Jobs do
        if data.groups[Jobs[i]] then
            return true
        end
    end

    return false
end

---@param message string
---@param icon string
---@param type "error" | "info" | "success"
function Notify(message, icon, type)
    return lib.notify({
        title = locale("notification_title"),
        duration = Notification.duration,
        description = message,
        position = Notification.position,
        icon = icon,
        iconColor = NotificationIconColors[type] or "#ffffff",
    })
end
