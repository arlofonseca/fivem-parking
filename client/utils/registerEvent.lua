---@param event string
---@param fn function
local function registerEvent(event, fn)
    RegisterNetEvent(event, function(...)
        if source ~= "" then fn(...) end
    end)
end

return registerEvent
