Debug = true -- If set to 'false', it will disable debugging actions

Logging = false -- If set to true, it will log certain action(s)
LoggingOption = "" -- Available options: 'oxlogger', 'DISCORD_WEBHOOK'

-- Identifier to display in embeds on a logged action(s)
-- 'license' | 'license2' | 'steam' | 'fivem'
IdentifierType = "license"

-- Time that it takes to save vehicles to database in minutes
TickTime = 5

ParkingSpotPrice = 300 -- Price for buying a parking spot, set to -1 to disable and make free
StorePrice = 300 -- Price for storing your vehicle, set to -1 to disable and make free
GetPrice = 300 -- Price for taking out of garage, set to -1 to disable and make free
ImpoundPrice = 300 -- Price for taking out of impound, set to -1 to disable and make free

-- Coordinates of the impound location (where vehicles will spawn)
ImpoundCoords = vec4(407.4, -1637.13, 29.3, 232.4)

-- Marker that will display in the world at 'MarkerCoords' vector3
-- https://docs.fivem.net/docs/game-references/markers/#markers
ImpoundMarker = 2

-- Icon that will display on the map for the impound
-- https://docs.fivem.net/docs/game-references/blips/#blips
ImpoundSprite = 237

-- Color of the impound icon that displays on the map
-- https://docs.fivem.net/docs/game-references/blips/#blip-colors
ImpoundSpriteColor = 1

-- Size of the impound icon that displays on the map
ImpoundSpriteScale = 0.75

-- Coordinates of the impound marker in world (where marker will display)
MarkerCoords = vec3(409.094, -1622.860, 29.291)

-- Distance the player(s) need to be in order to see the impound marker in the world
MarkerDistance = 2

-- Entity that will display in the world
-- https://docs.fivem.net/docs/game-references/ped-models/
EntityModel = "s_m_y_xmech_01"

-- Coordinates of the entity (where the npc will spawn)
EntityCoords = vector4(409.094, -1622.860, 28.291, 231.727)

-- Distance the player(s) need to be in order to see the entity in the world
EntityDistance = 30

-- Specify the jobs that have access to impounding vehicles, for ox these are groups, leave the table empty to let everyone access it
Jobs = {
	"police",
	"ambulance",
	"mechanic",
}

-- Use only the '/impound' command if false, otherwise use both ox_target / command to impound vehicle(s)
UseOxTarget = false

-- Icons displayed on ox_target labels
-- https://fontawesome.com/search?o=r&m=free
TargetIcons = {
	[0] = "car",
	[1] = "handshake",
}

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
	[2] = "success",
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
