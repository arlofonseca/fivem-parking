if GetResourceState("qb-core") ~= "started" then return end

local _, QBCore = pcall(exports['qb-core'].getSharedObject) --[[@as table | false]]

if not QBCore then return end

SetVehicleProperties = QBCore.Functions.SetVehicleProperties
GetVehicleProperties = QBCore.Functions.GetVehicleProperties

---@return boolean
function CheckImpoundJob()
	local job = QBCore.Functions.GetPlayerData()?.job
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
	local job = QBCore.Functions.GetPlayerData()?.job
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