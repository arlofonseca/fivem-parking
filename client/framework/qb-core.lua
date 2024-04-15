local resourceName = "qb-core"

if not GetResourceState(resourceName):find("start") then return end

local _, QBCore = pcall(exports["qb-core"].GetCoreObject) --[[@as table | false]]

if not QBCore then return end

SetVehicleProperties = QBCore.Functions.SetVehicleProperties
GetVehicleProperties = QBCore.Functions.GetVehicleProperties

local qb = {}
local client = require "config.client"
local shared = require "config.shared"

---@return boolean
function qb.hasJob()
    local job = QBCore.Functions.GetPlayerData()?.job
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
function qb.Notify(message, duration, position, _type, icon)
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
function qb.showTextUI(text)
    lib.showTextUI(text)
end

function qb.hideTextUI()
    lib.hideTextUI()
end

---@param menu string
function qb.showContext(menu)
    lib.showContext(menu)
end

---@param value? boolean
function qb.hideContext(value)
    lib.hideContext(value)
end

return qb
