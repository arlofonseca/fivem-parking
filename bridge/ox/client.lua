if GetResourceState("ox_core") ~= "started" then return end

if UseOx then
	assert(load(LoadResourceFile("ox_core", "imports/client.lua"), "@@ox_core/imports/client.lua"))()
end

---@todo
