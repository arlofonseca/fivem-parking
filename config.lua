-- Shared classes for lua language server annotation
---@class Vehicle
---@field owner string | number
---@field model string | number This is supposed to be only a number, but this: `adder` is seen as a string
---@field props table
---@field location 'outside' | 'parked' | 'impound'
---@field type? 'car' | 'van' | 'truck' | 'bicycle' | 'motorcycle' | 'boat' | 'helicopter' | 'plane' | 'train' | 'emergency'
---@field temporary? boolean

---@class VehicleDatabase
---@field owner string
---@field plate string
---@field model integer
---@field props string
---@field location 'outside' | 'parked' | 'impound'
---@field type 'car' | 'van' | 'truck' | 'bicycle' | 'motorcycle' | 'boat' | 'helicopter' | 'plane' | 'train' | 'emergency'

UseOx = true -- If set to 'false', ESX will be used
Debug = true -- If set to 'false', it will disable debugging actions
CheckVersion = true -- Check for the latest release version (?)

-- If set 'true', it will log certain action(s)
-- Change the logging option at 'server>main.lua#L5'
Logging = false

-- Identifier to display in embeds on a logged action(s)
-- 'license' | 'license2' | 'steam' | 'fivem'
IdentifierType = "license"

TickTime = 5 -- Time that it takes to save vehicles to database, in minutes.
ParkingSpotPrice = 300 -- Price for buying a parking spot, set to -1 to disable and make free
StorePrice = 300 -- Price for storing your vehicle, set to -1 to disable and make free
GetPrice = 300 -- Price for taking out of garage, set to -1 to disable and make free
ImpoundPrice = 300 -- Price for taking out of impound, set to -1 to disable and make free

-- Coordinates of the impound location (where vehicles will spawn)
ImpoundCoords = vec4(407.4, -1637.13, 29.3, 232.4)

-- Impound marker type
-- https://docs.fivem.net/docs/game-references/markers/
ImpoundMarker = 2

-- Coordinates of the impound marker in world (where marker will display)
MarkerCoords = vec3(409.0, -1622.94, 29.2)

-- The distance the player(s) need to be in order to see the impound marker in the world
MarkerDistance = 2

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

-- Use only the '/impound' command if false, otherwise use both ox_target / command to impound vehicle(s)
UseOxTarget = false

-- Icon displayed on ox_target label when impounding a vehicle(s)
-- This will only matter if 'UseOxTarget' is 'true'
-- https://fontawesome.com/search?o=r&m=free
OxTargetIcon = "fa-solid fa-car-burst"

-- How long notification(s) will be displayed on your screen for
NotificationDuration = 5000

-- The position notification(s) will be displayed at on your screen
-- 'top' | 'top-right' | 'top-left' | 'bottom' | 'bottom-right' | 'bottom-left' | 'center-right' | 'center-left'
NotificationPosition = "center-right"

-- Icons displayed within notification(s)
-- https://fontawesome.com/search?o=r&m=free
NotificationIcons = {
	[0] = "car",
	[1] = "circle-info",
}

-- Color of icons displayed within notification(s)
-- https://mantine.dev/theming/colors/#default-colors
NotificationIconColors = {
	["error"] = "#7f1d1d",
	["info"] = "#3b82f6",
	["success"] = "#14532d",
}

-- Types of notification(s).
NotificationType = {
	[0] = "error",
	[1] = "info",
	[2] = "success"
}

AdminGroup = "group.admin" -- Group that is able to access the '/admincar' command
UseAces = true -- Used for the '/givevehicle' command

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

-- Vehicles that are available in the '/sv` (societyvehicles) command
SocietyVehicles = {
	police = {
		{
			model = "police",
			name = "Cruiser",
		},
	},

	ambulance = {
		{
			model = "ambulance",
			name = "Aid Vehicle",
		},
	},

	mechanic = {
		{
			model = "towtruck",
			name = "Tow Truck",
		},
	},
}