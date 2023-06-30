---Do not rename this resource or touch this part of the code
if GetCurrentResourceName() ~= "vgarage" then
	error("^1Please don't rename this resource, change the folder name back to 'vgarage'.^0")
	return
end

---Dependency check
---Credits to Linden for this :)
local success, message = lib.checkDependency("oxmysql", "2.7.1")
if not success then error(message) end
success, message = lib.checkDependency("ox_lib", "3.6.1")
if not success then error(message) end
