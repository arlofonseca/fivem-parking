---@param event string
---@param fn function
local function registerNetEvent(event, fn)
    RegisterNetEvent(event, function(...)
        if source ~= "" then fn(...) end
    end)
end

return registerNetEvent
