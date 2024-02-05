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
