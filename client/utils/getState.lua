---@param entity any
local function getState(entity)
   return Entity(entity).state
end

return getState
