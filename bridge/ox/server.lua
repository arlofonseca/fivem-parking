if GetResourceState("ox_core") ~= "started" then return end

if UseOx then
	assert(load(LoadResourceFile("ox_core", "imports/server.lua"), "@@ox_core/imports/server.lua"))()
end

---@todo
