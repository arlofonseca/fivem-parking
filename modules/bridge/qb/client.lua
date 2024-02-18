local resourceName = "qb-core"

if not GetResourceState(resourceName):find("start") then return end

local _, QBCore = pcall(exports["qb-core"].GetCoreObject) --[[@as table | false]]

if not QBCore then return end

SetVehicleProperties = QBCore.Functions.SetVehicleProperties
GetVehicleProperties = QBCore.Functions.GetVehicleProperties

local qb = {}

---@return boolean
function qb.HasJob()
    local job = QBCore.Functions.GetPlayerData()?.job
    if not job then return false end

    for i = 1, #Jobs do
        if job.name == Jobs[i] then
            return true
        end
    end

    return false
end

---@param message string
---@param duration? integer
---@param position? string
---@param _type? string
---@param icon? string
---@param iconColor? string
function qb.Notify(message, duration, position, _type, icon, iconColor)
    return lib.notify({
        title = locale("notification_title"),
        description = message,
        duration = duration,
        position = position,
        type = _type,
        icon = icon,
        iconColor = iconColor,
    })
end

---@param text string
function qb.ShowTextUI(text)
    lib.showTextUI(text)
end

function qb.HideTextUI()
    lib.hideTextUI()
end

return qb
