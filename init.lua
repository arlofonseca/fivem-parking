local cache = {}

local function spamError(msg)
    local err = table.concat(msg, "\n")
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

local oxmysql, oxmysql_msg = lib.checkDependency("oxmysql", "2.9.1")
local ox_lib, ox_lib_msg = lib.checkDependency("ox_lib", "3.16.1")

if not oxmysql then
    table.insert(cache, oxmysql_msg)
end

if not ox_lib then
    table.insert(cache, ox_lib_msg)
end

if #cache > 0 then
    spamError(cache)
end
