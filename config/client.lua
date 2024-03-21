return {
    impound = {
        command = "impound", -- Default command to relocate vehicles to the impound lot.
        static = true, -- If 'false', the impound won't be confined to a fixed location and can be accessed via command (disables 'location', 'useTarget', 'entity', 'marker', and 'blip' options).
        price = 300, -- Price for taking vehicles out of impound, set to -1 to disable and make free.
        location = vec4(407.4, -1637.13, 29.3, 232.4), -- General location (where all vehicles will spawn).
        useTarget = false, -- If 'true', ox_target will be required to access the vehicle impound menu (disables the 'marker' options).

        entity = {
            model = "s_m_y_xmech_01", -- Entity that displays in the world | https://docs.fivem.net/docs/game-references/ped-models/
            location = vector4(409.094, -1622.860, 28.291, 231.727), -- Location of the entity (where the ped spawns).
            distance = 10, -- Distance players needs to be in order to see the entity in the world.
        },

        marker = {
            type = 2, -- Marker that displays in the world | https://docs.fivem.net/docs/game-references/markers/#markers
            location = vec3(409.094, -1622.860, 29.291), -- Location of the marker (where the marker spawns).
            distance = 2, -- Distance players needs to be in order to see the marker in the world.
        },

        blip = {
            sprite = 237, -- Icon that displays on the map | https://docs.fivem.net/docs/game-references/blips/#blips
            color = 1, -- Color of the icon | https://docs.fivem.net/docs/game-references/blips/#blip-colors
            scale = 0.75, -- Size of the icon.
        },
    },

    -- Specify the jobs that have access to impounding vehicles, leave the table empty to let everyone access it.
    -- If using "ox_core" these are groups.
    jobs = {
        "police",
        "ambulance",
        "mechanic",
    },

    -- The value here decides what icon they get per vehicle class and what type of vehicle it will be if not defined.
    vehicleClasses = {
        [0] = "car",
        [1] = "car",
        [2] = "car",
        [3] = "car",
        [4] = "car",
        [5] = "car",
        [6] = "car",
        [7] = "car",
        [8] = "motorcycle",
        [9] = "car",
        [10] = "truck",
        [11] = "car",
        [12] = "van",
        [13] = "bicycle",
        [14] = "boat",
        [15] = "helicopter",
        [16] = "plane",
        [17] = "car",
        [18] = "emergency",
        [19] = "emergency",
        [20] = "truck",
        [21] = "train",
        [22] = "car",
    },

    -- https://fontawesome.com/search?o=r&m=free
    convertIcons = {
        van = "van-shuttle",
        boat = "sailboat",
        emergency = "light-emergency-on",
        bicycle = "person-biking",
        motorcycle = "motorcycle",
        helicopter = "helicopter-symbol",
        plane = "plane-up",
        truck = "truck-pickup",
        train = "train-subway",
        aircraft = "paper-plane",
        bike = "bicycle",
        automobile = "car-burst",
    },
}
