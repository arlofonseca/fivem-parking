return {
    framework = 'ox_core', -- Available options: 'ox_core' or 'qbx_core'.
    adminGroup = 'admin', -- The group authorized to access restricted commands (e.g., '/admincar', '/givevehicle', and '/deletevehicle').
    plateTextPattern = '11AAA111', -- Reference: https://docs.fivem.net/natives/?_0x79780FD2

    ---@class Garage
    ---@field parking Parking
    ---@field storage Storage
    ---@field retrieve Retrieve
    garage = {
        ---@class Parking
        ---@field price number | integer
        parking = {
            price = 25, -- Cost to purchase a parking spot for vehicle storage; set to -1 to disable and make it free.
        },

        ---@class Storage
        ---@field price number | integer
        storage = {
            price = 75, -- Cost for vehicle storage; set to -1 to disable and make it free.
        },

        ---@class Retrieve
        ---@field price number | integer
        retrieve = {
            price = 150, -- Cost to retrieve vehicles from storage; set to -1 to disable and make it free.
        },
    },

    ---@class Impound
    ---@field command table | string
    ---@field price number | integer
    ---@field location vector4
    ---@field useTarget boolean
    ---@field entity Entity
    ---@field marker Marker
    ---@field blip Blip
    impound = {
        command = { 'impound' }, -- Command(s) to impound vehicles.
        price = 300, -- Cost to retrieve vehicles from the impound; set to -1 to disable and make it free.
        location = vec4(407.4, -1637.13, 29.3, 232.4), -- Default location for vehicle retrieval.
        useTarget = false, -- If set to 'true', the vehicle impound menu requires 'ox_target', disabling 'marker' settings.

        ---@class Entity
        ---@field model string
        ---@field location vector4
        ---@field distance number
        entity = {
            model = 's_m_y_xmech_01', -- In-game entity model | Reference: https://docs.fivem.net/docs/game-references/ped-models/
            location = vector4(409.094, -1622.860, 28.291, 231.727), -- Entity spawn location.
            distance = 10, -- Distance at which players can view the entity.
        },

        ---@class Marker
        ---@field type number | integer
        ---@field location vector3
        ---@field distance number
        marker = {
            type = 2, -- Marker type displayed in the game world | Reference: https://docs.fivem.net/docs/game-references/markers/#markers
            location = vec3(409.094, -1622.860, 29.291), -- Marker spawn location.
            distance = 2, -- Distance at which players can view the marker.
        },

        ---@class Blip
        ---@field sprite number | integer
        ---@field color number | integer
        ---@field scale number | integer
        blip = {
            sprite = 237, -- Map icon | Reference: https://docs.fivem.net/docs/game-references/blips/#blips
            color = 1, -- Icon color | Reference: https://docs.fivem.net/docs/game-references/blips/#blip-colors
            scale = 0.75, -- Icon size.
        },
    },

    ---@class Notifications
    ---@field duration number | integer
    ---@field position string
    notifications = {
        duration = 5000, -- Duration notifications will be displayed on the screen.
        position = 'top-right', -- Options: 'top', 'top-right', 'top-left', 'bottom', 'bottom-right', 'bottom-left', 'center-right', 'center-left'.
    },
}
