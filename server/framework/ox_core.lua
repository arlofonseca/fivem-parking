if not UseOx or GetResourceState("ox_core") ~= "started" then return end

assert(load(LoadResourceFile("ox_core", "imports/server.lua"), "@@ox_core/imports/server.lua"))()

---@param source integer
---@return table
function GetPlayerFromId(source)
	return Ox.GetPlayer(source)
end

---@param identifier integer
---@return table
function GetPlayerFromIdentifier(identifier)
	return Ox.GetPlayerByFilter({ charId = identifier })
end

---@param player table
---@return integer
function GetIdentifier(player)
	return player.charId
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