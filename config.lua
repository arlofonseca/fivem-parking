CheckVersion = true -- Will check for latest release version if true
UseOx = true -- Use ox_core if true, otherwise ESX
TickTime = 5000 -- How often vehicles are saved to the database

-- The value here decides what icon they get per vehicle class and what type of vehicle it will be if not defined
VehicleClasses = {
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
}

-- https://fontawesome.com/search?o=r&m=free
ConvertIcons = {
	van = "van-shuttle",
	boat = "sailboat",
	emergency = "light-emergency-on",
}

ParkingPrice = 750 -- For parking your vehicle, set to -1 to disable
GetPrice = 800 -- For getting your vehicle back, set to -1 to disable
ImpoundPrice = 1000 -- For taking out of the impound, set to -1 to disable
ParkingSpotPrice = 400 -- The price to pay to buy a parking spot, set to -1 to disable

-- Jobs that are able to access the impound feature
ImpoundJobs = {
	"police",
	"ambulance",
	"mechanic",
}

-- Jobs that are able to access the sv (societyvehicles) feature
EmergencyJobs = {
	"police",
	"ambulance",
	"mechanic",
}

-- Vehicles that are available in the sv command
SocietyVehicles = {
    police = {
        {
            model = "police",
            name = "Test Vehicle #1",
        },
    },

    ambulance = {
        {
            model = "bmx",
            name = "Test Vehicle #2",
        },
    },

    mechanic = {
        {
            model = "asea",
            name = "Test Vehicle #3",
        },
    },
}

-- Use ox_target if true, otherwise '/impound' command
UseOxTarget = true

-- Group that is able to access the '/admincar' command
AdminGroup = "group.admin"

-- Coords to save the car in the impound
ImpoundSaveCoords = vec4(407.4, -1637.13, 29.3, 232.4)

-- https://docs.fivem.net/natives/?_0x79780FD2
PlateTextPattern = "11AAA111"