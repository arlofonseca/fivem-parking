return {
    framework = "ox_core", -- Available options: "ox_core", "es_extended", "qb-core", and "standalone".

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

    notifications = {
        duration = 5000, -- Duration for which notifications will display on screen.
        position = "center-right", -- Available options: "top", "top-right", "top-left", "bottom", "bottom-right", "bottom-left", "center-right", and "center-left".

        -- https://fontawesome.com/search?o=r&m=free
        icons = {
            [0] = "car",
            [1] = "circle-info",
            [2] = "square-parking",
            [3] = "warehouse",
        },

        -- https://mantine.dev/theming/colors/#default-colors
        iconColors = {
            ["error"] = "#7f1d1d",
            ["inform"] = "#3b82f6",
            ["success"] = "#14532d",
            ["warning"] = "#ffa94d",
        },
    },

    miscellaneous = {
        adminGroup = "group.admin", -- Group that is able to access restricted commands (e.g., '/admincar' or '/givevehicle').
        plateTextPattern = "11AAA111", -- https://docs.fivem.net/natives/?_0x79780FD2
    },
}
