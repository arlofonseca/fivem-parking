return {
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
