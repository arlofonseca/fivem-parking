SaveTime = 5 -- Time that it takes to save vehicles to database in minutes

--#region Garage

Garage = {
	location = 300, -- Price for buying a parking spot, set to -1 to disable and make free
	storage = 300, -- Price for storing your vehicle, set to -1 to disable and make free
	retrieve = 300, -- Price for taking out of garage, set to -1 to disable and make free
	sprite = 1, -- Icon that will display on the map when executing '/findspot' | https://docs.fivem.net/docs/game-references/blips/#blips
	spriteColor = 1, -- Color of the icon that displays on the map | https://docs.fivem.net/docs/game-references/blips/#blip-colors
	spriteScale = 0.75, -- Size of the icon that displays on the map
}

--#endregion Garage

--#region Impound

Impound = {
	price = 300, -- Price for taking vehicles out of impound, set to -1 to disable and make free
	location = vec4(407.4, -1637.13, 29.3, 232.4),  -- General location (where vehicles will spawn)
	textui = true, -- If 'false', it will use ox_target to access the vehicle impound menu and disable the marker option
	entity = "s_m_y_xmech_01", -- Entity that will display in the world | https://docs.fivem.net/docs/game-references/ped-models/
	entityLocation = vector4(409.094, -1622.860, 28.291, 231.727), -- Location of the entity model
	entityDistance = 15, -- Distance the player needs to be in order to see the entity in the world
	marker = 2, -- Marker that will display in the world at 'markerLocation' vector3 | https://docs.fivem.net/docs/game-references/markers/#markers
	markerLocation = vec3(409.094, -1622.860, 29.291), -- Coordinates of the marker in world (where marker will display)
	markerDistance = 2, -- Distance the player needs to be in order to see the marker in the world
	sprite = 237, -- Icon that will display on the map | https://docs.fivem.net/docs/game-references/blips/#blips
	spriteColor = 1, -- Color of the icon that displays on the map | https://docs.fivem.net/docs/game-references/blips/#blip-colors
	spriteScale = 0.75, -- Size of the icon that displays on the map
}

--#endregion Impound

--#region Miscellaneous

Misc = {
	debug = true, -- If 'false', it will disable debugging actions
	logging = false, -- If 'true', it will log the specified actions
	adminGroup = "group.admin", -- Group that is able to access the '/admincar' command
	useAces = true, -- Used for the '/givevehicle' command
	plateTextPattern = "11AAA111", -- https://docs.fivem.net/natives/?_0x79780FD2
}

--#endregion Miscellaneous

-- Specify the jobs that have access to impounding vehicles, for ox these are groups, leave the table empty to let everyone access it
Jobs = {
	"police",
	"ambulance",
	"mechanic",
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
