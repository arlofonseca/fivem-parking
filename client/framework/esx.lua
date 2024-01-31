if GetResourceState("es_extended") ~= "started" then return end

local _, ESX = pcall(exports.es_extended.getSharedObject) --[[@as table | false]]

if not ESX then return end

SetVehicleProperties = ESX.Game.SetVehicleProperties
GetVehicleProperties = ESX.Game.GetVehicleProperties

---@return boolean
function HasJob()
    local job = LocalPlayer.state.job
    if not job then return false end

    for i = 1, #Jobs do
        if job.name == Jobs[i] then
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
        duration = NotificationDuration,
        description = message,
        position = NotificationPosition,
        icon = icon,
        iconColor = NotificationIconColors[type] or "#ffffff",
    })
end
