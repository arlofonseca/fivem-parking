# bgarage

This simple vehicle / garage management system was designed with the intention to move towards a more generic structure, deciding whether you own / have a vehicle and where it is at the moment. In other words, with this system you have the ability to access your owned vehicle(s) from anywhere you would like. Only the impound is static.

## Usage

### Exports

### `addVehicle`

- Add a vehicle to the system.

**Example:**
```lua
exports.bgarage:addVehicle(owner, plate, model, props, location, type, temporary)
```

**Types:**
- **owner**
  - `number` or `string`
    - Number is for Ox, string is for ESX. For Ox, it is `player.charId`, for ESX, it is `player.license` *(if you're using ESX Multicharacter, the license will be `char1:etc` and will be unique along characters)*.
- **plate**
  - `string`
    - The plate the vehicle holds.
- **model**
  - `number` or `string`
    - The model name or hash of the vehicle.
- **props (optional)**
  - `table`
    - The properties of the vehicle, e.g., vehicle color, etc. Obtainable using client functions like `lib.getVehicleProperties` or `ESX.Game.GetVehicleProperties`.
- **location (optional)**
  - `'outside'` or `'parked'` or `'impound'`, default(s) state to `'outside'`.
    - The state to place the vehicle at, without affecting the physical location of the vehicle.
- **type (optional)**
  - `string`
    - The type of vehicle, for the icon on the vehicle menu.
- **temporary (optional)**
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
  - `number` or `string`
    - Number is for Ox, string is for ESX. For Ox, it is `player.charId`, for ESX, it is `player.license` *(if you're using ESX Multicharacter, the license will be `char1:etc` and will be unique along characters)*.
- **location (optional)**
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
  - `number` or `string`
    - Number is for Ox, string is for ESX. For Ox, it is `player.charId`, for ESX, it is `player.license` *(if you're using ESX Multicharacter, the license will be `char1:etc` and will be unique along characters)*.
- **plate**
  - `string`
    - The plate the vehicle holds.
- **status**
  - `'parked'` or `'impound'`
    - The state the vehicle should be placed under, without impacting its physical state.
- **props (optional)**
  - `table`
    - The properties of the vehicle, e.g., vehicle color, etc. Obtainable using client functions like `lib.getVehicleProperties` or `ESX.Game.GetVehicleProperties`.

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

### Commands

- `/v buy`
  - Use this command to acquire a parking spot location. You can use this command from *any* location, and each time you execute it, you will secure ownership of a parking spot at that location.

- `/v park`
  - By using this command, your vehicle will be parked and securely stored in your garage. Please note that you can only access this feature at the location where you executed the `/v buy` command.

- `/v list`
  - Present a menu containing a list of your owned vehicle(s) currently in the 'parked' state within your vehicle garage. If you decide to remove a vehicle from this list, it will reappear at the location where you executed the `/v buy` command.

- `/impound`
  - A command restricted to specific job roles, used to relocate vehicle(s) to the vehicle impound, placing them in the 'impound' state.

- `/sv`
  - Another command with restricted access, available exclusively to specific job roles. Its purpose is to provide entry to the society vehicle(s) menu, where authorized users can access and manage the vehicles associated with their role or responsibilities within the organization.

- `/admincar`
  - This is a group-restricted command designed for the purpose of saving the current vehicle in which you are seated into your personal vehicle garage and database. By default, this vehicle is stored in the 'outside' state once the command is executed. However, once you execute the `/v buy` command followed by `/v park`, it will then be securely placed in your vehicle garage, marked as the 'parked' state for your convenience and future use.

- `/givevehicle [model] [targetId]`
  - Ace-restricted command designed to facilitate the insertion of vehicle(s) into another player(s) vehicle garage, effectively placing it in the 'parked' state for their future use. It's important to note that this action results in

 the permanent storage of the provided vehicle(s) in the target player(s) vehicle garage.

## Requirements

- [FXServer](https://runtime.fivem.net/artifacts/fivem/) 6129 or higher
- [oxmysql](https://github.com/overextended/oxmysql/releases)
- [ox_lib](https://github.com/overextended/ox_lib/releases)
- [ox_target](https://github.com/overextended/ox_target/releases) *(optional)*

## Credits

- Without [BerkieB](https://github.com/BerkieBb), this system would not have been possible.