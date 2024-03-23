return {
    -- ignore
    ---@todo finish this and implement functionality (hopefully I never get around to it).
    garages = {
        [1] = {
            label = "Legion Garage",
            price = 150,
            spawns = {
                vector4(208.904, -793.554, 30.515, 248.089),
                vector4(218.249, -796.721, 30.335, 69.141),
                vector4(235.057, -800.275, 30.037, 68.497),
            },
            entity = {
                model = "cs_wade",
                location = vector4(215.787, -808.796, 29.749, 250.708),
                distance = 10,
            },
            marker = {
                type = 2,
                location = vec3(215.787, -808.796, 30.749),
                distance = 2,
            },
        },
        [2] = {
            label = "Paleto Garage",
            price = 150,
            spawns = {
                vector4(150.838, 6598.248, 31.411, 180.881),
                vector4(140.956, 6575.135, 31.539, 269.733),
                vector4(131.189, 6585.257, 31.528, 272.561),
            },
            entity = {
                model = "cs_wade",
                location = vector4(159.594, 6590.048, 31.127, 85.388),
                distance = 10,
            },
            marker = {
                type = 2,
                location = vec3(159.594, 6590.048, 32.127),
                distance = 2,
            },
        },
    },
}
