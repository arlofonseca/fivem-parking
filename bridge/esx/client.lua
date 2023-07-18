if UseOx or GetResourceState("es_extended") ~= "started" then return end

ESX = not UseOx and exports.es_extended.getSharedObject() --[[@as table | false]]

if not ESX then return end

SetVehicleProperties = ESX.Game.SetVehicleProperties
GetVehicleProperties = ESX.Game.GetVehicleProperties

---Don't feel like supporting ESX.ShowNotification seeing as how this system depends on ox_lib already
---lib better anyway :)
---@param message string
---@param type "error" | "info" | "success"
function ShowNotification(message, icon, type)
	return lib.notify({
		title = locale("notification_title"),
		duration = NotificationDuration,
		description = message,
		position = NotificationPosition,
		icon = icon,
		iconColor = NotificationIconColors[type] or "#ffffff",
	})
end