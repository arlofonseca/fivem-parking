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
---@param type "inform" | "error" | "success" | "warning"
---@param icon string
---@param iconColor string
function Notify(message, type, icon, iconColor)
    return lib.notify({
        title = locale("notification_title"),
        description = message,
        duration = Notification.duration,
        position = Notification.position,
        type = type,
        icon = icon,
        iconColor = iconColor,
    })
end
