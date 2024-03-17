local utils = {}

---Returns the string with only the first character as uppercase and lowercases the rest of the string
---@param s string
---@return string
function string.firstToUpper(s)
    if not s or s == "" then return "" end
    return s:sub(1, 1):upper() .. s:sub(2):lower()
end

---@param settings table
---@param coords vector3
function utils.createBlip(settings, coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, settings.id)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, settings.scale)
    SetBlipColour(blip, settings.colour)
    SetBlipAsShortRange(blip, true)

    return blip
end

return utils
