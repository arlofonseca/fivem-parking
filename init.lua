local cache = {}
local shared = require 'config.shared'.framework

local function spamError(msg)
    local err = table.concat(msg, '\n')
    CreateThread(function()
        while true do
            Wait(1000)
            CreateThread(function()
                error(err, 0)
            end)
        end
    end)

    error(err, 0)
end

local oxmysql, oxmysql_msg = lib.checkDependency('oxmysql', '2.9.1')
local ox_lib, ox_lib_msg = lib.checkDependency('ox_lib', '3.16.1')

if not oxmysql then
    cache[#cache + 1] = oxmysql_msg
end

if not ox_lib then
    cache[#cache + 1] = ox_lib_msg
end

if shared == 'ox_core' and not GetResourceState('ox_inventory'):find('start') then
    local ox_inv, ox_inv_msg = lib.checkDependency('ox_inventory', '2.28.1')
    if not ox_inv then
        cache[#cache + 1] = ox_inv_msg
    end
end

if #cache > 0 then
    spamError(cache)
end