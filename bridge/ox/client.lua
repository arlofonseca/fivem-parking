if not UseOx or GetResourceState("ox_core") ~= "started" then return end

assert(load(LoadResourceFile("ox_core", "imports/client.lua"), "@@ox_core/imports/client.lua"))()

SetVehicleProperties = lib.setVehicleProperties
GetVehicleProperties = lib.getVehicleProperties