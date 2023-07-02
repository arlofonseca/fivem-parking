if GetResourceState("ox_core") ~= "started" then return end

if UseOx then
	assert(load(LoadResourceFile("ox_core", "imports/client.lua"), "@@ox_core/imports/client.lua"))()
end

--This was made based upon other resources that use ox_core

---@param callback function
function Framework.playerReady(cb)
	AddEventHandler("ox:playerLoaded", function()
		---
	end)
end

---@param name any
---@param callback function
function Framework.ServerCallback(name, cb, ...)
	lib.callback(name, false, cb, ...)
end

---@param message string
---@param type "info" | "success" | "error"
---@param time number
function Framework.notifyClient(message, type, time)
	lib.notify({
		title = "Vehicle Parking",
		description = message,
		type = type,
		position = "center-right",
		duration = (time or 5) * 1000,
	})
end

---@todo
---getPlayerIdentifier
---getPlayerByJobInfo
