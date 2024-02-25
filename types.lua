---@class Vehicle
---@field owner string | number
---@field model string | number This is supposed to be only a number, but this: `adder` is seen as a string
---@field modelName? string
---@field plate? string
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

---@class Ped
---@field model string | number
---@field coords vector4
---@field distance integer
---@field target? boolean

---@class Blip
---@field label string
---@field sprite integer
---@field colour? integer
---@field alpha? integer
---@field display? integer
---@field rotation? integer
---@field scale? number

---@class Marker
---@field type integer
---@field posX number
---@field posY number
---@field posZ number
---@field dirX number
---@field dirY number
---@field dirZ number
---@field rotX number
---@field rotY number
---@field rotZ number
---@field scaleX number
---@field scaleY number
---@field scaleZ number
---@field red integer
---@field green integer
---@field blue integer
---@field alpha integer
---@field bobUpAndDown? boolean
---@field faceCamera? boolean
---@field p19 integer
---@field rotate? boolean
---@field textureDict string
---@field textureName string
---@field drawOnEnts? boolean

---@class Garage
---@field price number

---@class Impound
---@field price number
---@field state? boolean

---@class Map
---@field plate? string
---@field modelName? string
---@field coords vector4
---@field location 'outside' | 'parked' | 'impound'

---@class Options
---@field usingGrid? boolean
---@field usingDarkMode? boolean
