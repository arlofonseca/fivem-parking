-- https://github.com/overextended/ox_mdt/blob/master/server/utils/registerCallback.lua
---@param event string
---@param cb fun(playerId: number, ...: any): ...
local function registerCallback(event, cb)
    lib.callback.register(event, function(source, ...)
        return cb(source, ...)
    end)
end

return registerCallback
