return {
    ---@class Database
    ---@field interval number | integer
    ---@field debug boolean
    database = {
        interval = 5, -- Time in minutes to save vehicles to the database.
        debug = true, -- If 'false', database debugging will be disabled.
    },

    ---@class Aliases
    ---@field buy table | string
    ---@field list table | string
    ---@field park table | string
    aliases = {
        buy = { 'vb' }, -- The alias command(s) to purchase a parking space.
        list = { 'vl', 'vg' }, -- The alias command(s) to display the list of all owned vehicles.
        park = { 'vp' }, -- The alias command(s) to park your vehicle in your garage.
    }
}
