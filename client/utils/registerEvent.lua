---@param event string
---@param fn fun(...)
local function registerEvent(event, fn)
    RegisterNetEvent(event, function(...)
        local args = { ... }
        if not source or source == '' then return end

        fn(table.unpack(args))
    end)
end

return registerEvent
