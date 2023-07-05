if not UseOx or GetResourceState("ox_core") ~= "started" then return end

assert(load(LoadResourceFile("ox_core", "imports/client.lua"), "@@ox_core/imports/client.lua"))()

SetVehicleProperties = lib.setVehicleProperties
GetVehicleProperties = lib.getVehicleProperties

---@param message string
---@param type "error" | "info" | "success"
function ShowNotification(message, icon, type)
	return lib.notify({
		title = locale("notification_title"),
		duration = NotificationDuration,
		description = message,
		position = NotificationPosition,
		icon = icon,
		iconColor = IconColors[type] or "#ffffff",
	})
end