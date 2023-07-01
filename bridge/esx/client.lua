if not GetResourceState("es_extended"):find("start") and UseOx then return end

ESX = not UseOx and exports.es_extended.getSharedObject()

--This was made based upon other resources that use ESX

if ESX and ESX.PlayerLoaded then
	---
end

---@param callback function
function Framework.playerReady(cb)
	AddEventHandler("esx:playerLoaded", function(player)
		ESX.PlayerData = player
		ESX.PlayerLoaded = true
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
function Framework.notifyClient(message, type, time)
	ESX.ShowNotification(message, type, (time or 5) * 1000)
end

---@param source number
function Framework.getPlayerIdentifier()
	return ESX.PlayerData?.id or cache.player
end

---@param source number
function Framework.getPlayerByJobInfo()
	return { name = ESX.PlayerData.job.name, label = ESX.PlayerData.job.label }
end
