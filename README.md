# bgarage

The primary goal of this system for managing vehicles and garages is to move towards a more adaptable and universal structure. It helps you determine ownership of a vehicle and its current location. Essentially, this system provides you with the flexibility to access information about your owned vehicles and retrieve them from any location of your choice.

## Features

- Utilizes ox_lib for most UI elements (e.g., notifications, input), and cache.
- Conveniently store and retrieve your owned vehicles from a location of your choosing, enhancing the realism of your experience.
- Identify whether you own a vehicle or not.
- While the flexibility of accessing your vehicles from any location is undoubtedly a plus, it's worth noting that once your vehicle is impounded, the retrieval process becomes constrained to a fixed and static impound location.
- Support is extended to aircraft and boats, each equipped with facilities that cater to storage and retrieval.
- Includes a tracking system for players to locate their vehicles easily, either within their garage, on the map, or at the impound.
- Logs for specific actions are handled by ox_lib's [logger](https://overextended.dev/ox_lib/Modules/Logger/Server#liblogger) module, Discord is no longer supported.
- Any framework support, ox_core, es_extended and qb-core integrated by default.

## Installation

- Install resource dependencies:
   - [oxmysql](https://github.com/overextended/oxmysql)
   - [ox_lib](https://github.com/overextended/ox_lib)
   - [ox_target](https://github.com/overextended/ox_target) is not required but provides additional functionality
- Open a command-line terminal (e.g. Terminal, Command Prompt).
- Enter `npm install -g pnpm` to globally install the package.
- Download a [release](https://github.com/bebomusa/bgarage/releases/latest) build to skip the next steps or clone the repo with `git clone https://github.com/bebomusa/bgarage`.
- Find your way inside of the `web` directory using `cd web`.
- Install dependencies with `pnpm i`.
- Build the resource with `pnpm build`.
- Execute the queries in `sql/install.sql` in your database.
- Include `start bgarage` where your resources are being started.
- Adjust `config.lua` to fit your needs.

## Usage

### Commands

#### `/v buy`

- Use this command to acquire a parking spot location. You can use this command from any location, and each time it is executed, you will secure ownership of a parking spot at that specific location.

#### `/v park`

- Executing this command will park your vehicle securely, storing it in your vehicle garage.

#### `/v list`

- Displays a menu that includes a comprehensive list of your owned vehicles, indicating whether they are parked or located in the vehicle impound. If you choose to retrieve a vehicle from this list, it will reappear at the location where you executed the `/v buy` command. However, it is important to note that this does not permit the removal of vehicles in the 'impound' state. Instead, it tells you to retrieve your vehicle from the vehicle impound location.

#### `/impound`

- This command is limited to specific job roles, utilized for relocating vehicles to the vehicle impound and placing them in the 'impound' state.

#### `/admincar`

- A command restricted to a specific group, intended to save the current vehicle you are seated in to both the database and your personal vehicle garage.
  
#### `/givevehicle [model] [targetId]`

- Ace-restricted command specifically created to streamline the insertion of vehicles into the database and the vehicle garage of another player or players.

#### `/findspot`

- This is a universal command designed for locating your parking spot. It becomes particularly useful when you find yourself unable to recall the exact location of your current parking spot and lack the funds to acquire a new parking spot.

### Exported Functions (server)

#### `addVehicle`

- Add a vehicle to the system.

**Example:**
```lua
exports.bgarage:addVehicle(owner, plate, model, props, location, type, temporary)
```

**Types:**
- **owner**
  - `number` or `string`
    - Number is for Ox, string is for ESX. For Ox, it is `player.charId`, for ESX, it is `player.license` (if you're using ESX Multicharacter, the license will be char1:etc and will be unique along characters).

- **plate**
  - `string`
    - The plate the vehicle holds.

- **model**
  - `number` or `string`
    - The model name or hash of the vehicle.

- **props** _(optional)_
  - `table`
    - The properties of the vehicle (e.g., vehicle color, tints, etc.) can be obtained using client functions like `lib.getVehicleProperties`.

- **location** _(optional)_
  - `'outside'` or `'parked'` or `'impound'`, default state is `'outside'`.
    - The state to place the vehicle at, without affecting the physical location of the vehicle.

- **type** _(optional)_
  - `string`
    - The type of vehicle, for the icon on the vehicle menu.

- **temporary** _(optional)_
  - `boolean`
    - If the vehicle should be temporary or not. If 'temporary', it won't be saved to the database.

**Return:**
- `boolean`
  - Whether it was successful.

#### `removeVehicle`

- Remove a vehicle from the system.

**Example:**
```lua
exports.bgarage:removeVehicle(plate)
```

**Types:**
- **plate**
  - `string`
    - The plate the vehicle holds.

**Return:**
- `boolean`
  - Whether it was successful.

#### `getVehicle`

- Get a vehicle from the system.

**Example:**
```lua
exports.bgarage:getVehicle(plate)
```

**Types:**
- **plate**
  - `string`
    - The plate the vehicle holds.

**Return:**
- `table`
  - The vehicle data.

#### `getVehicleOwner`

- Get a vehicle from the system by its owner.

**Example:**
```lua
exports.bgarage:getVehicleOwner(source, plate)
```

**Types:**
- **source**
  - `number`
    - The source of the player to get the vehicle from.

- **plate**
  - `string`
    - The plate the vehicle holds.

**Return:**
- `table`
  - The vehicle data.

#### `getVehicles`

- Get all vehicles from an owner with an optional location filter.

**Example:**
```lua
exports.bgarage:getVehicles(owner, location)
```

**Types:**
- **owner**
  - `number` or `string`
    - Number is for Ox, string is for ESX. For Ox, it is `player.charId`, for ESX, it is `player.license` (if you're using ESX Multicharacter, the license will be char1:etc and will be unique along characters).

- **location** _(optional)_
  - `'outside'` or `'parked'` or `'impound'`
    - The state to place the vehicle at, these don't impact the physical location of the vehicle.

**Return:**
- `table`
  - An array holding vehicle data.

#### `setVehicleStatus`

- Set the status of a vehicle.

**Example:**
```lua
exports.bgarage:setVehicleStatus(owner, plate, status, props)
```

**Types:**
- **owner**
  - `number` or `string`
    - Number is for Ox, string is for ESX. For Ox, it is `player.charId`, for ESX, it is `player.license` (if you're using ESX Multicharacter, the license will be char1:etc and will be unique along characters).

- **plate**
  - `string`
    - The plate the vehicle holds.

- **status**
  - `'parked'` or `'impound'`
    - The state the vehicle should be placed under, without impacting its physical state.

- **props** _(optional)_
  - `table`
    - The properties of the vehicle (e.g., vehicle color, tints, etc.) can be obtained using client functions like `lib.getVehicleProperties`.

**Return:**
- `boolean`
  - Whether it was successful.

- `string`
  - The notification message depending on if it was successful or not.

#### `getRandomPlate`

- Generate a random plate according to the pattern in the config.

**Example:**
```lua
exports.bgarage:getRandomPlate()
```

**Return:**
- `string`
  - The generated plate.

#### `saveData`

- Force a save of all vehicles and parking spots to the database.

**Example:**
```lua
exports.bgarage:saveData()
```

## Credits

- Without [BerkieB](https://github.com/BerkieBb), this system would not have been possible.