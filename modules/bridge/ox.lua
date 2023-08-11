if not UseOx or GetResourceState("ox_core") ~= "started" then return end

local file = ("imports/%s.lua"):format(IsDuplicityVersion() and "server" or "client")
local import = LoadResourceFile("ox_core", file)
local chunk = assert(load(import, ("@@ox_core/%s"):format(file)))
chunk()

if IsDuplicityVersion() then
	---@param source integer
	---@return table
	function GetPlayerFromId(source)
		return Ox.GetPlayer(source)
	end

	---@param identifier integer
	---@return table
	function GetPlayerFromIdentifier(identifier)
		return Ox.GetPlayerByFilter({ charid = identifier })
	end

	---@param player table
	---@return integer
	function GetIdentifier(player)
		return player.charid
	end

	---@param source integer
	---@return number
	function GetMoney(source)
		return exports.ox_inventory:GetItem(source, "money", false, true) or 0
	end

	---@param source integer
	---@param amount number
	function RemoveMoney(source, amount)
		exports.ox_inventory:RemoveItem(source, "money", amount)
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
			iconColor = NotificationIconColors[type] or "#ffffff",
		})
	end
end