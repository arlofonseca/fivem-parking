return {
    database = {
        interval = 5, -- Time that it takes to save vehicles to database in minutes.
        debug = true, -- If 'false', database debug will be disabled.
    },

    logging = {
        enabled = false, -- If 'true', certain actions will be logged (e.g., purchasing a parking space or giving a vehicle).
        identifier = 'license2', -- Available options: 'license', 'license2', 'steam', and 'fivem'.
    },

    commands = {
        aliases = true, -- If 'false', alternative commands for '/v buy, park, and list' will not be available.
    }
}
