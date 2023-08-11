if UseOx or GetResourceState("es_extended") ~= "started" then return end

ESX = not UseOx and exports.es_extended.getSharedObject() --[[@as table | false]]

if not ESX then return end

if IsDuplicityVersion() then
	---@param source integer
	---@return table
	function GetPlayerFromId(source)
		return ESX.GetPlayerFromId(source)
	end

	---@param identifier string
	---@return table
	function GetPlayerFromIdentifier(identifier)
		return ESX.GetPlayerFromIdentifier(identifier)
	end

	---@param player table
	---@return string
	function GetIdentifier(player)
		return player.identifier
	end

	---@param source integer
	---@return number
	function GetMoney(source)
		local player = GetPlayerFromId(source)
		if not player then return 0 end

		return player.getMoney()
	end

	---@param source integer
	---@param amount number
	function RemoveMoney(source, amount)
		local player = GetPlayerFromId(source)
		if not player then return end

		player.removeMoney(amount)
	end

	---@param source integer
	---@param message string
	---@param type "error" | "info" | "success"
	function ShowNotification(source, message, icon, type)
		return lib.notify(source, {
			title = locale("notification_title"),
			duration = NotificationDuration,
			description = message,
			position = NotificationPosition,
			icon = icon,
			iconColor = NotificationIconColors[type] or "#ffffff",
		})
	end
else
	SetVehicleProperties = ESX.Game.SetVehicleProperties
	GetVehicleProperties = ESX.Game.GetVehicleProperties

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
end