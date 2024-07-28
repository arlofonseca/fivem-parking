local getRandomLetter = require 'server.utils.getRandomLetter'

local function getAlphanumeric()
    return math.random(0, 1) == 1 and getRandomLetter()
end

return getAlphanumeric
