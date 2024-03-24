---@param s string
---@return string
local function capitalizeFirst(s)
    if not s or s == "" then return "" end
    return s:sub(1, 1):upper() .. s:sub(2):lower()
end

return capitalizeFirst
