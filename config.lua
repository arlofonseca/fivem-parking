Debug = false -- Should be self explanatory (?)
CheckVersion = true -- Will check for latest release version if true
UseOx = true -- Use ox_core if true, otherwise ESX
TickTime = 5 -- How often vehicles are saved to the database in minute(s)

ParkingPrice = 300 -- For parking your vehicle, set to -1 to disable
GetPrice = 300 -- For taking out of garage, set to -1 to disable
ImpoundPrice = 300 -- For taking out of the impound, set to -1 to disable
ParkingSpotPrice = 300 -- The price to pay to buy a parking spot, set to -1 to disable

-- Group that is able to access the '/admincar' command
AdminGroup = "group.admin"

-- Coords to save the car in the impound
ImpoundCoords = vec4(407.4, -1637.13, 29.3, 232.4)

-- Jobs that are able to access the impound feature
ImpoundJobs = {
	"police",
	"ambulance",
	"mechanic",
}

-- Jobs that are able to access the sv (societyvehicles) feature
-- You can edit the vehicles that display per job in 'data.lua'
EmergencyJobs = {
	"police",
	"ambulance",
	"mechanic",
}

-- Use only '/impound' command if false, otherwise use both ox_target/command
UseOxTarget = true

-- Icon displayed on ox_target label when impounding a vehicle
-- https://fontawesome.com/search?o=r&m=free
TargetIcon = "fa-solid fa-car-burst"

NotificationDuration = 5000 -- Should be self explanatory (?)
NotificationPosition = "center-right" -- Should be self explanatory (?)

-- Notification icons
-- https://fontawesome.com/search?o=r&m=free
Icons = {
	[0] = "car",
	[1] = "circle-info",
}

-- Notification icon colors
-- https://mantine.dev/theming/colors/#default-colors
Colors = {
	["error"] = "#7f1d1d",
	["info"] = "#3b82f6",
	["success"] = "#14532d",
}

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

-- https://docs.fivem.net/natives/?_0x79780FD2
PlateTextPattern = "11AAA111"