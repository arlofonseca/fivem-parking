lib.locale()

---source https://github.com/overextended/ox_core/blob/main/shared/init.lua#L1
local success, message = lib.checkDependency("ox_lib", "3.6.1")
success, message = lib.checkDependency("oxmysql", "2.7.1")

if not success then
    return print(('^1Error: %s^0'):format(message))
end

---@todo
