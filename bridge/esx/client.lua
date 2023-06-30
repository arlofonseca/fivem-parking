if not GetResourceState("es_extended"):find("start") and UseOx then return end

ESX = not UseOx and exports.es_extended.getSharedObject()

--This was made based upon other resources that use ESX
---@todo

---@param callback function
function Framework.playerReady(cb)
	AddEventHandler("esx:playerLoaded", function()
		---
	end)
end

---@param name any
---@param callback functions
function Framework.ServerCallback(name, cb, ...)
	ESX.TriggerServerCallback(name, cb, ...)
end

---@param message string
---@param type "info" | "success" | "error"
---@param time number
function Framework.showNotification(message, type, time)
	ESX.ShowNotification(message, type, (time or 5) * 1000)
end
