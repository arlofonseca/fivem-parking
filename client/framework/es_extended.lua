local resourceName = "es_extended"

if not GetResourceState(resourceName):find("start") then return end

local _, ESX = pcall(exports.es_extended.getSharedObject) --[[@as table | false]]

if not ESX then return end

SetVehicleProperties = ESX.Game.SetVehicleProperties
GetVehicleProperties = ESX.Game.GetVehicleProperties

local esx = {}
local client = lib.load("config.client")
local shared = lib.load("config.shared")

---@return boolean
function esx.hasJob()
    local job = LocalPlayer.state.job
    if not job then return false end

    for i = 1, #client.jobs do
        if job.name == client.jobs[i] then
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
function esx.Notify(message, duration, position, _type, icon)
    return lib.notify({
        title = locale("notification_title"),
        description = message,
        duration = duration,
        position = position,
        type = _type,
        icon = icon,
        iconColor = shared.notifications.iconColors[_type] or "#ffffff",
    })
end

---@param text string
function esx.showTextUI(text)
    lib.showTextUI(text)
end

function esx.hideTextUI()
    lib.hideTextUI()
end

---@param menu string
function esx.showContext(menu)
    lib.showContext(menu)
end

---@param value? boolean
function esx.hideContext(value)
    lib.hideContext(value)
end

return esx
