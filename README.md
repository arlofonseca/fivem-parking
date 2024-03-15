# bgarage

The primary goal of this system for managing vehicles and garages is to move towards a more adaptable and universal structure. It helps you determine ownership of a vehicle and its current location. Essentially, this system provides you with the flexibility to access information about your owned vehicles and retrieve them from any location of your choice.

## Features

- Conveniently store and retrieve your owned vehicles from a location of your choosing, enhancing the realism of your experience.
- Identify whether you own a vehicle or not.
- While the flexibility of accessing your vehicles from any location is undoubtedly a plus, it's worth noting that once your vehicle is impounded, the retrieval process becomes constrained to a fixed and static impound location.
- Support is extended to aircraft and boats, each equipped with facilities that cater to storage and retrieval.
- Includes a tracking system for players to locate their vehicles easily, either within their garage, on the map, or at the impound.
- Logs for specific actions are handled by ox_lib's [logger](https://overextended.dev/ox_lib/Modules/Logger/Server#liblogger) module, Discord is no longer supported.
- Any framework support, ox_core, es_extended and qb-core are integrated by default.
- The interface is managed through the ox_lib's [interface](https://overextended.dev/ox_lib/Modules/Interface/Client/context) module, replacing the previous use of a React + Mantine interface.

https://github.com/bebomusa/bgarage/assets/138083964/25427d61-33ad-4835-87cf-828348900c50

## Installation

### Dependencies

- [oxmysql](https://github.com/overextended/oxmysql)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target) is not required but provides additional functionality

### Setup

1. Download the source code using the green `Code` button.
2. Unpack the `bgarage-lib-context-menu.zip` folder and rename it to `bgarage`.
3. Place the `bgarage` folder into your `resources` directory.
4. Execute the queries found in `sql/install.sql` in your database.
5. Add `start bgarage` to the location where your resources are initialized.
6. Adjust `config.lua` to fit your needs.

## Usage

### Commands

#### `/v buy`

- Use this command to acquire a parking spot location. You can use this command from any location, and each time it is executed, you will secure ownership of a parking spot at that specific location.

#### `/v park`

- Executing this command will safely park your vehicle, placing it in your vehicle garage and designating its status as 'parked'.

#### `/v list`

- This interface provides an in-depth overview, displaying a list of your owned vehicles along with their status, and offers an option to track them. Choosing a vehicle from this list will cause it to reappear at the location where you initiated the `/v buy` command. It's crucial to note that this feature does not permit the removal of vehicles in the 'impound' state by default; instead, it prompts you to retrieve such vehicles from the designated static impound location unless configured differently.

#### `/v impound`

- An extra, optional interface that presents a list of all owned vehicles currently impounded (identical to the interface shown when configured to a static location). This command operates exclusively when `config.impound.static` is set to `false`. If you opt to set `config.impound.static` as `false`, selecting a vehicle from this list will cause it to spawn at the location where you executed `v buy`, rather than the general location of the vehicle impound (the vector4 defined at `config.impound.location`).

#### `/impound`

- This command is limited to specific job roles, utilized for relocating vehicles to the vehicle impound and placing them in the 'impound' state.

*By default, this command serves as the standard method for impounding vehicles. If you happen to be utilizing [ox_target](https://github.com/overextended/ox_target), an additional option is available, allowing you to impound vehicles using the target eye.*

#### `/admincar`

- A command restricted to a specific group, intended to save the current vehicle you are seated in to both the database and your personal vehicle garage.

#### `/givevehicle [playerId] [model]`

- This command is limited to a particular group and is tailored to simplify the process of adding vehicles to both the database and the vehicle garages of other players.

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
    - The properties of the vehicle (e.g., vehicle color, tints, etc.) can be obtained using client functions like `lib.getVehicleProperties` or `ESX.Game.GetVehicleProperties`.

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
  - Whether it was successful or not.

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
  - Whether it was successful or not.

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
    - The properties of the vehicle (e.g., vehicle color, tints, etc.) can be obtained using client functions like `lib.getVehicleProperties` or `ESX.Game.GetVehicleProperties`.

**Return:**
- `boolean`
  - Whether it was successful or not.

- `string`
  - The notification message letting you know if it was successful or not.

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

- [BerkieB](https://github.com/BerkieBb) originally made this resource. I wanted it publicly available, so here it is.
