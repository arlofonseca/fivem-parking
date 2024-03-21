# bGarage

The primary goal of this system for managing vehicles and garages is to move towards a more realistic, adaptable, and universal structure. It helps you determine ownership of a vehicle and its current location. Essentially, this system provides you with the flexibility to access information about your owned vehicles and retrieve them from any location of your choice.

## Features

- Conveniently store and retrieve your owned vehicles from a location of your choosing via commands, enhancing the realism of your experience.
- Identify whether you own a vehicle or not.
- While the flexibility of accessing your vehicles from any location is undoubtedly a plus, it's worth noting that once your vehicle is impounded, the retrieval process becomes constrained to a fixed and static impound lot location unless configured otherwise.
- Support is extended to aircraft and boats, each equipped with facilities that cater to storage and retrieval.
- Includes a tracking system for players to locate their vehicles easily, either within their garage, on the map, or at the impound lot.
- Administrator privileges grant access to additional management for overseeing, including tasks such as clearing vehicles left outside or in the impound lot, monitoring usage patterns, and more.
- Possess an excess number of vehicles? Choose to permanently remove vehicles from your storage at any given time. Note that this action cannot be reversed.
- The process of spawning vehicles is primarily handled on the server side, utilizing the non-RPC native `CreateVehicleServerSetter`.
- Logs for specific actions are handled by ox_lib's [logger](https://overextended.dev/ox_lib/Modules/Logger/Server#liblogger) module, Discord is no longer supported.
- Any framework support, ox_core, es_extended, and qb-core are integrated by default.
- The interface is handled via ox_lib's [interface](https://overextended.dev/ox_lib/Modules/Interface/Client/context) module, which has replaced the former React + Mantine interface. This new interface is implemented in Lua, chosen for its wider accessibility and ease of contribution, ensuring broader engagement from users.

https://github.com/bebomusa/bGarage/assets/138083964/25427d61-33ad-4835-87cf-828348900c50

## Installation

### Dependencies

This resource requires the following to function correctly:

- [oxmysql](https://github.com/overextended/oxmysql)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory) _(if you're using [ox_core](https://github.com/overextended/ox_core))_

### Setup

1. Download the source code using the green `Code` button or the latest release [from here](https://github.com/bebomusa/bGarage/releases).
2. Unpack the contents of `bGarage-main.zip` or `bGarage.zip` file into a newly created folder named `bGarage`.
3. Place the `bGarage` folder into your `resources` directory.
4. Execute the queries found in `sql/install.sql` in your database.
5. Add `start bGarage` to the location where your resources are initialized.
6. Be sure to adjust the files found in the `config` directory to fit your needs.

## Usage

### Commands

#### `/v buy`

- Use this command to acquire a parking spot location. You can use this command from any location, and each time it is executed, you will secure ownership of a parking spot at that specific location.

#### `/v park`

- Executing this command will safely park your vehicle, placing it in your vehicle garage and designating its status as 'parked'.

#### `/v list`

- This interface provides an in-depth overview, displaying a list of your owned vehicles along with their status, and offers an option to track them. Choosing a vehicle from this list will cause it to reappear at the location where you initiated the `/v buy` command. It's crucial to note that this feature does not permit the removal of vehicles in the 'impound' state by default; instead, it prompts you to retrieve such vehicles from the designated static impound location unless configured differently.

#### `/v impound` _(optional)_

- An extra interface that presents a list of all owned vehicles currently impounded (identical to the interface shown when configured to a static location). This command operates exclusively when `config.impound.static` is set to `false`. If you opt to set `config.impound.static` as `false`, selecting a vehicle from this list will cause it to spawn at the location where you executed `/v buy`, rather than the general location of the vehicle impound (the vector4 defined at `config.impound.location`).

#### `/impound`

- This command is restricted to certain job roles and is used for moving vehicles to the impound lot, where they are placed in the 'impound' state. You can modify `config.impound.command` to adjust this command according to your requirements.

*By default, this command serves as the standard method for impounding vehicles. If you happen to be utilizing [ox_target](https://github.com/overextended/ox_target), an additional option is available, allowing you to impound vehicles using the target eye.*

#### `/admincar`

- A command restricted to a specific group, intended to save the current vehicle you are seated in to both the database and your personal vehicle garage.

#### `/givevehicle [playerId] [model]`

- Another command limited to a particular group and is tailored to simplify the process of adding vehicles to both the database and the vehicle garages of other players.

#### `/deletevehicle [playerId] [plate]`

- Similar to the command above, this one also remains restricted to a specific group and aims to streamline the procedure of removing vehicles from both the database and the vehicle garages of other players.

### Exported Functions (server)

#### `addVehicle`

- Add a vehicle to the system.

**Example:**
```lua
exports.bGarage:addVehicle(owner, plate, model, props, type, location, temporary)
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

- **type** _(optional)_
  - `string`
    - The type of vehicle.

- **location** _(optional)_
  - `'outside'` or `'parked'` or `'impound'`, default state is `'outside'`.
    - The state to place the vehicle at, without affecting the physical location of the vehicle.

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
exports.bGarage:removeVehicle(plate)
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
exports.bGarage:getVehicle(plate)
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
exports.bGarage:getVehicleOwner(source, plate)
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
exports.bGarage:getVehicles(owner, location)
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
exports.bGarage:setVehicleStatus(owner, plate, status, props)
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
exports.bGarage:getRandomPlate()
```

**Return:**
- `string`
  - The generated plate.

#### `saveData`

- Force a save of all vehicles and parking spots to the database.

**Example:**
```lua
exports.bGarage:saveData()
```

### Exported Functions (client)

#### `vehicleList`

- Displays a detailed list showcasing all owned vehicles, along with their whereabouts and current status.

**Example:**
```lua
exports.bGarage:vehicleList()
```

#### `vehicleImpound`

- Displays another detailed list of all owned vehicles currently in the 'impound' state, located at the designated vehicle impound location.

**Example:**
```lua
exports.bGarage:vehicleImpound()
```

## Credits

- [BerkieB](https://github.com/BerkieBb) originally made this resource. I wanted it publicly available, so here it is.