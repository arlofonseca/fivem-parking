if not GetResourceState("es_extended"):find("start") and UseOx then return end

ESX = not UseOx and exports.es_extended.getSharedObject()

--This was made based upon other resources that use ESX
local players = {}

---@param callback function
function OnPlayerLoaded(cb)
	AddEventHandler("esx:playerLoaded", function(source)
		---
	end)
end

---@param callback function
function OnPlayerUnloaded(cbss)
	AddEventHandler("esx:playerDropped", function(source)
		players[source] = nil
	end)
end

---@param name any
---@param callback function
function RegisterCallback(name, cb)
	ESX.RegisterServerCallback(name, cb)
end

---@todo
---showNotification

---@param source number
---@return string
function GetPlayerFromId(source)
	return ESX.GetPlayerFromId(source)
end

---@param source number
---@param amount value
function RemoveMoney(source, amount)
	local player = GetPlayerFromId(source)
	if not player then return end

	if type(amount) ~= "number" then return end

	---
end

---@param job any
---@param grade any
function GetPlayersByJobGrade(job, grade)
	return MySQL.query.await([[SELECT * FROM users WHERE job = ? AND job_grade = ? ]], { ('"%s"'):format(job), ("%s"):format(grade) })
end
