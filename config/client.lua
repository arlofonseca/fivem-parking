return {
    ---@class Jobs
    ---@field jobs table | string
    jobs = {
        -- List of jobs that are permitted to impound vehicles; leave the table empty to allow access to everyone.
        -- If using "ox_core", these are groups.
        "police",
        "ambulance",
        "mechanic",
    },
}
