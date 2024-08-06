return {
    framework = 'ox_core', -- Available options: 'ox_core' and 'qbx_core'.

    garage = {
        parking = {
            price = 25, -- Price for buying a parking spot to store your vehicle, set to -1 to disable and make free.
        },

        storage = {
            price = 75, -- Price for storing your vehicle, set to -1 to disable and make free.
        },

        retrieve = {
            price = 150, -- Price for taking vehicles out of storage, set to -1 to disable and make free.
        },
    },

    impound = {
        command = 'impound', -- Default command to relocate vehicles to the impound lot.
        static = true, -- If 'false', the impound won't be confined to a fixed location and can be accessed via command (disables 'location', 'useTarget', 'entity', 'marker', and 'blip' options).
        price = 300, -- Price for taking vehicles out of impound, set to -1 to disable and make free.
        location = vec4(407.4, -1637.13, 29.3, 232.4), -- General location (where all vehicles will spawn).
        useTarget = false, -- If 'true', ox_target will be required to access the vehicle impound menu (disables the 'marker' options).

        entity = {
            model = 's_m_y_xmech_01', -- Entity that displays in the world | https://docs.fivem.net/docs/game-references/ped-models/
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

    notifications = {
        duration = 5000, -- Duration for which notifications will display on screen.
        position = 'top-right', -- Available options: 'top', 'top-right', 'top-left', 'bottom', 'bottom-right', 'bottom-left', 'center-right', and 'center-left'.

        -- https://fontawesome.com/search?o=r&m=free
        icons = {
            [0] = 'car',
            [1] = 'circle-info',
            [2] = 'square-parking',
            [3] = 'warehouse',
        },

        -- https://mantine.dev/theming/colors/#default-colors
        iconColors = {
            ['error'] = '#7f1d1d',
            ['inform'] = '#3b82f6',
            ['success'] = '#14532d',
            ['warning'] = '#ffa94d',
        },
    },

    miscellaneous = {
        adminGroup = 'group.admin', -- Group that is able to access restricted commands (e.g., '/admincar' or '/givevehicle').
        plateTextPattern = '11AAA111', -- https://docs.fivem.net/natives/?_0x79780FD2
    },
}
