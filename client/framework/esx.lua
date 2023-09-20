if GetResourceState("es_extended") ~= "started" then return end

local _, ESX = pcall(exports.es_extended.getSharedObject) --[[@as table | false]]

if not ESX then return end

SetVehicleProperties = ESX.Game.SetVehicleProperties
GetVehicleProperties = ESX.Game.GetVehicleProperties

---@return boolean
function CheckImpoundJob()
	local job = LocalPlayer.state.job
	if not job then return false end

	for i = 1, #ImpoundJobs do
		if job.name == ImpoundJobs[i] then
			return true
		end
	end

	return false
end

---@return string
function GetEmergencyJob()
	local job = LocalPlayer.state.job
	if not job then return "none" end

	for i = 1, #EmergencyJobs do
		if job.name == EmergencyJobs[i] then
			return EmergencyJobs[i]
		end
	end

	return "none"
end

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