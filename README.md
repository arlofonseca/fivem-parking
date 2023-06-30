# vgarage

This resource is basically a simple garage system, but I would like to call it a vehicle management system due to this resource also deciding whether you own / have a vehicle and where it is at the moment.

# Usage

## Exports

### `addVehicle`

Add a vehicle to the system.

#### Example:

```lua
exports.vgarage:addVehicle(owner, plate, model, props, location, type, temporary)
```

#### Types:

*owner*
- - `number` or `string`
- - Number is for Ox, string is for ESX. For Ox it is `player.charid`, for ESX it is `player.license` *(if you're using ESX Multicharacter, the license will be `char1:etc` and will be unique along characters)*.

*plate*
- - `string`
- - The plate the vehicle holds.

*model*
- - `number` or `string`
- - The model name or hash of the vehicle.

*props (optional)*
- - `table`
- - The properties of the vehicle, for example vehicle color, etc. This can be gotten using functions on the client like `lib.getVehicleProperties` or `ESX.Game.GetVehicleProperties`.

*location (optional)*
- - `'outside'` or `'parked'` or `'impound'`, default(s) state to `'outside'`.
- - The state to place the vehicle at, these don't impact the physical location of the vehicle.

*type (optional)*
- - `string`
- - The type of vehicle, this is for the icon on the vehicle menu.

*temporary (optional)*
- - `boolean`
- - If the vehicle should be temporary or not. If it is 'temporary', it won't be saved to the database.

*return*
- - `boolean`
- - Whether it was successful.

### `removeVehicle`

Remove a vehicle from the system.

#### Example:

```lua
exports.vehicles:removeVehicle(plate)
```

#### Types:

*plate*
- - `string`
- - The plate the vehicle holds.

*return*
- - `boolean`
- - Whether it was successful.

### `getVehicle`

Get a vehicle from the system.

#### Example:

```lua
exports.vehicles:getVehicle(plate)
```

#### Types:

*plate*
- - `string`
- - The plate the vehicle holds.

*return*
- - `table`
- - The vehicle data.

### `getVehicleOwner`

Get a vehicle from the system by its owner.

#### Example:

```lua
exports.vehicles:getVehicleOwner(source, plate)
```

#### Types:

*source*
- - `number`
- - The source of the player to get the vehicle from.

*plate*
- - `string`
- - The plate the vehicle holds.

Return
- - `table`
- - The vehicle data.

### `getVehicles`

Get all vehicles from an owner with an optional location filter.

#### Example:

```lua
exports.vehicles:getVehicles(owner, location)
```

#### Types:

*owner*
- - `number` or `string`
- - Number is for Ox, string is for ESX. For Ox it is `player.charid`, for ESX it is `player.license` *(if you're using ESX Multicharacter, the license will be `char1:etc` and will be unique along characters)*.

*location (optional)*
- - `'outside'` or `'parked'` or `'impound'`
- - The state to place the vehicle at, these don't impact the physical location of the vehicle.

*return*
- - `table`
- - An array holding vehicle data.

### `setVehicleStatus`

Set the status of a vehicle.

#### Example:

```lua
exports.vehicles:setVehicleStatus(owner, plate, status, props)
```

#### Types:

*owner*
- - `number` or `string`
- - Number is for Ox, string is for ESX. For Ox it is `player.charid`, for ESX it is `player.license` *(if you're using ESX Multicharacter, the license will be `char1:etc` and will be unique along characters)*.

*plate*
- - `string`
- - The plate the vehicle holds.

*status*
- - `'parked'` or `'impound'`
- - The state the vehicle should be placed under, this doesn't impact its phyisical state.

*props (optional)*
- - `table`
- - The properties of the vehicle, for example vehicle color, etc. This can be gotten using functions on the client like `lib.getVehicleProperties` or `ESX.Game.GetVehicleProperties`.

*return*
- - `boolean`
- - Whether it was successful.
- - `string`
- - The notification message depending on if it was successful or not.

### `getRandomPlate`

Generate a random plate according to the pattern in the config.

#### Example:

```lua
exports.vehicles:getRandomPlate()
```

#### Types:

*return*
- - `string`
- - The generated plate.

### `save`

Force a save to the database.

#### Example:
```lua
exports.vehicles:save()
```

## Commands

### `/v buy`
- - Execute this command to purchase a parking spot location *(you're able to run this command from anywhere, each time the command is ran, is where you own a parking spot location)*.

### `/v park`
- - This command will park your vehicle & store it inside your garage *(will only allow you to access this at the location where you executed `'/v buy'`)*.

### `/v list`
- - Display a menu with a list of your owned vehicle(s) that are in the 'parked' state *(if you choose to remove a vehicle, it will spawn at the location where you executed `'/v buy'`)*.

### `/v impound`
- - Display a menu with a list of your owned vehicle(s) that are in the 'impound' state *(if you choose to remove a vehicle, it will spawn at the location where you executed `'/v buy'`)*.

### `/impound`
- - Job restricted command that is used to send vehicle(s) to the vehicle impound / 'impound' state.

### `/admincar`
- - Group restricted command that is used to save the current vehicle you are sitting in to the database *(default(s) to 'outside' state, seeing as how we are running the command in the vehicle we are sitting in, once parked, it will now be in the 'parked' state).*

# Requirements

- [FXServer](https://runtime.fivem.net/artifacts/fivem/) 5848 or higher
- [oxmysql](https://github.com/overextended/oxmysql/releases)
- [ox_lib](https://github.com/overextended/ox_lib/releases)

# Credits

- Without [BerkieB](https://github.com/BerkieBb), this system would not have been possible.
