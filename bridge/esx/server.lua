if not GetResourceState("es_extended"):find("start") and UseOx then return end

ESX = not UseOx and exports.es_extended.getSharedObject()

--This was made based upon other resources that use ESX
local players = {}

---@param callback function
function Framework.onPlayerLoaded(cb)
	AddEventHandler("esx:playerLoaded", function(source)
		---
	end)
end

---@param callback function
function Framework.onPlayerUnloaded(cbss)
	AddEventHandler("esx:playerDropped", function(source)
		players[source] = nil
	end)
end

---@param name any
---@param callback function
function Framework.RegisterCallback(name, cb)
	ESX.RegisterServerCallback(name, cb)
end

---@todo
---showNotification

---@param source number
---@return string
function Framework.getPlayerId(source)
	return ESX.GetPlayerFromId(source).getIdentifier()
end

---@param source number
---@param amount value
function Framework.removeMoney(source, amount)
	local player = Framework.getPlayerId(source)
	if not player then return end

	if type(amount) ~= "number" then return end

	---
end

---@param job any
---@param grade any
function Framework.getPlayersByJobGrade(job, grade)
	return MySQL.query.await([[SELECT * FROM users WHERE job = ? AND job_grade = ? ]], { ('"%s"'):format(job), ("%s"):format(grade) })
end
