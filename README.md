# bgarage

The primary goal of this system for managing vehicles and garages is to move towards a more adaptable and universal structure. It helps you determine ownership of a vehicle and its current location. Essentially, this system provides you with the flexibility to access information about your owned vehicles and retrieve them from any location of your choice.

## Features

- Conveniently access your vehicle garage or owned vehicles from a location of your preference.
- Identify whether you own a vehicle or not.
- While the flexibility of accessing your vehicles from any location is undoubtedly a plus, it's worth noting that once your vehicle is impounded, the retrieval process becomes constrained to a fixed and static impound location.
- Support is extended to aircraft and boats, each equipped with facilities that cater to storage and retrieval.
- Only works for Overextended framework, not ESX or anything else.

## Installation

1. Install resource dependencies:
   - [oxmysql](https://github.com/overextended/oxmysql)
   - [ox_core](https://github.com/overextended/ox_core)
   - [ox_lib](https://github.com/overextended/ox_lib)
   - [ox_target](https://github.com/overextended/ox_lib) is not required but provides additional functionality
2. Download or clone the repo with `git clone https://github.com/bebomusa/bgarage`.
3. Add `ensure bgarage` to where your resources are being started.
4. Execute the queries in `sql/install.sql` in your database.
5. Adjust `config.lua` to fit your needs.

## Usage

### Commands

### `/v buy`

- Use this command to acquire a parking spot location. You can use this command from *any* location, and each time it is executed, you will secure ownership of a parking spot at that specific location.

### `/v park`

- Using this command will park your vehicle and securely stored in your vehicle garage. 

### `/v list`

- Displays a menu that includes a comprehensive list of your owned vehicles, indicating whether they are parked or located in the vehicle impound. If you choose to retrieve a vehicle from this list, it will reappear at the location where you executed the `/v buy` command. However, it is important to note that this does not permit the removal of vehicles in the 'impound' state. Instead, it tells you to retrieve your vehicle from the vehicle impound location.

### `/impound`

- A command restricted to specific job roles, used to relocate vehicles to the vehicle impound, placing them in the 'impound' state.

### `/admincar`

- This is a group-restricted command designed for the purpose of saving the current vehicle you are sitting in to the database and your vehicle garage.

### `/givevehicle [model] [targetId]`

- Ace-restricted command designed to facilitate the insertion of vehicles into the database and another player(s) vehicle garage.

### Exported Functions (server)

### `addVehicle`

- Add a vehicle to the system.

**Example:**
```lua
exports.bgarage:addVehicle(owner, plate, model, props, location, type, temporary)
```

**Types:**
- **owner**
  - `number`
    - `player.charId` is used for Ox.

- **plate**
  - `string`
    - The plate the vehicle holds.

- **model**
  - `number` or `string`
    - The model name or hash of the vehicle.

- **props** _(optional)_
  - `table`
    - The properties of the vehicle, e.g. vehicle color, etc. Obtainable using client functions like `lib.getVehicleProperties`.

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

### `removeVehicle`

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

### `getVehicle`

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

### `getVehicleOwner`

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

### `getVehicles`

- Get all vehicles from an owner with an optional location filter.

**Example:**
```lua
exports.bgarage:getVehicles(owner, location)
```

**Types:**
- **owner**
  - `number`
    - `player.charId` is used for Ox.

- **location** _(optional)_
  - `'outside'` or `'parked'` or `'impound'`
    - The state to place the vehicle at, these don't impact the physical location of the vehicle.

**Return:**
- `table`
  - An array holding vehicle data.

### `setVehicleStatus`

- Set the status of a vehicle.

**Example:**
```lua
exports.bgarage:setVehicleStatus(owner, plate, status, props)
```

**Types:**
- **owner**
  - `number`
    - `player.charId` is used for Ox.

- **plate**
  - `string`
    - The plate the vehicle holds.

- **status**
  - `'parked'` or `'impound'`
    - The state the vehicle should be placed under, without impacting its physical state.

- **props** _(optional)_
  - `table`
    - The properties of the vehicle, e.g. vehicle color, etc. Obtainable using client functions like `lib.getVehicleProperties`.

**Return:**
- `boolean`
  - Whether it was successful.

- `string`
  - The notification message depending on if it was successful or not.

### `getRandomPlate`

- Generate a random plate according to the pattern in the config.

**Example:**
```lua
exports.bgarage:getRandomPlate()
```

**Return:**
- `string`
  - The generated plate.

### `save`

- Force a save to the database.

**Example:**
```lua
exports.bgarage:save()
```

## Credits

- Without [BerkieB](https://github.com/BerkieBb), this system would not have been possible.