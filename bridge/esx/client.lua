if GetResourceState("es_extended") ~= "started" then return end

ESX = not UseOx and exports.es_extended.getSharedObject()

---@todo
