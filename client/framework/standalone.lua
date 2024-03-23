if GetResourceState("ox_core") == "started" then return end
if GetResourceState("es_extended") == "started" then return end
if GetResourceState("qb-core") == "started" then return end

lib.print.warn("Your current framework choice isn't supported. You'll need to make adjustments to the bridge files accordingly.")

SetVehicleProperties = lib.setVehicleProperties
GetVehicleProperties = lib.getVehicleProperties

local standalone = {}
local client = lib.load("config.client")
local shared = lib.load("config.shared")

---@return boolean
function standalone.hasJob()
    -- Insert your own stuff here
    return false
end

---@param message string
---@param duration? integer
---@param position? string
---@param _type? string
---@param icon? string
function standalone.Notify(message, duration, position, _type, icon)
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
function standalone.showTextUI(text)
    lib.showTextUI(text)
end

function standalone.hideTextUI()
    lib.hideTextUI()
end

---@param menu string
function standalone.showContext(menu)
    lib.showContext(menu)
end

---@param value? boolean
function standalone.hideContext(value)
    lib.hideContext(value)
end

return standalone
