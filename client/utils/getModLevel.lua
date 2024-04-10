---@param type number
local function getModLevel(type)
    local mod = GetVehicleMod(cache.vehicle, type)
    return mod ~= -1 and tostring(mod) .. "Level" or "Stock"
end

return getModLevel
