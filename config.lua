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

-- Jobs that are able to access the 'impound' command
ImpoundJobs = {
	"police",
	"ambulance",
	"mechanic",
}

-- Coords to save the car in the impound
ImpoundSaveCoords = vec4(407.4, -1637.13, 29.3, 232.4)

-- https://docs.fivem.net/natives/?_0x79780FD2
PlateTextPattern = "11AAA111"

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
