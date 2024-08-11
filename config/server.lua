return {
    database = {
        interval = 5, -- Time that it takes to save vehicles to database in minutes.
        debug = true, -- If 'false', database debug will be disabled.
    },

    logging = {
        enabled = false, -- If 'true', certain actions will be logged (e.g., purchasing a parking space or giving a vehicle).
        identifier = 'license2', -- Available options: 'license', 'license2', 'steam', and 'fivem'.
    },

    aliases = {
        -- The alias command to purchase a parking space.
        ---@param table | string A list of possible aliases for purchase a parking space.
        buy = { 'vb' },

        -- The alias command to display the list of all owned vehicles.
        ---@param table | string A list of possible aliases for displaying the list of all owned vehicles.
        list = { 'vl', 'vg' },

        -- The alias command to park your vehicle in your garage.
        ---@param table | string A list of possible aliases for parking your vehicle in your garage.
        park = { 'vp' },

        -- The alias command to display the list of all impounded vehicles.
        ---@param table | string A list of possible aliases for displaying the list of all impounded vehicles.
        impound = { 'vi' },

        -- The alias command to display the list of all impounded vehicles.
        ---@param table | string A list of possible aliases for displaying the list of all impounded vehicles.
        stats = { 'vs' },
    }
}
