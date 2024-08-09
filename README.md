# fivem-parking

A advanced vehicle garage system created with the intention of transitioning towards a more universal and adaptable structure.

## Features

- Conveniently store and retrieve your owned vehicles from a location of your choosing via commands, enhancing the realism of your experience.
- Identify whether you own a vehicle or not.
- While the flexibility of accessing your vehicles from any location is undoubtedly a plus, it's worth noting that once your vehicle is impounded, the retrieval process becomes constrained to a fixed and static impound lot location unless configured otherwise.
- Support is extended to aircraft and boats, each equipped with facilities that cater to storage and retrieval.
- Includes a tracking system for players to locate their vehicles easily, either within their garage, on the map, or at the impound lot.
- Possess an excess number of vehicles? Choose to permanently remove vehicles from your storage at any given time. Note that this action cannot be reversed.
- The process of spawning vehicles is primarily handled on the server side, utilizing the non-RPC native `CreateVehicleServerSetter`.
- Logs for specific actions are handled by ox_lib's [logger](https://overextended.dev/ox_lib/Modules/Logger/Server#liblogger) module, Discord is no longer supported.
- Any framework support, ox_core, and qbx_core are integrated by default.
- The interface is handled via ox_lib's [interface](https://overextended.dev/ox_lib/Modules/Interface/Client/context) module, which has replaced the former React + Mantine interface. This new interface is implemented in Lua, chosen for its wider accessibility and ease of contribution, ensuring broader engagement from users.

https://github.com/arlofonseca/fivem-parking/assets/138083964/5862e05b-dece-4f64-8a2e-9dafd9384583

https://github.com/arlofonseca/fivem-parking/assets/138083964/044b46e9-2f72-485d-ab42-5187314b8727

## Installation

### Dependencies

This resource requires the following to function correctly:

- [oxmysql](https://github.com/overextended/oxmysql)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory) _(if using [ox_core](https://github.com/overextended/ox_core) or [qbx_core](https://github.com/Qbox-project/qbx_core))_

### Setup

1. Download the source code using the green `Code` button or the latest release [from here](https://github.com/arlofonseca/fivem-parking/releases).
2. Unpack the contents of `fivem-parking-main.zip` or `fivem-parking.zip` file into a newly created folder named `fivem-parking`.
3. Place the `fivem-parking` folder into your `resources` directory.
4. Execute the queries found in `sql/install.sql` in your database.
5. Add `start fivem-parking` to the location where your resources are initialized.
6. Be sure to adjust the files found in the `config` directory to fit your needs.

## Usage

### Commands

#### `/v buy` _(alias: `/vb`)_

- Use this command to acquire a parking spot location. You can use this command from any location, and each time it is executed, you will secure ownership of a parking spot at that specific location.

#### `/v park` _(alias: `/vp`)_

- Executing this command will safely park your vehicle, placing it in your vehicle garage and designating its status as 'parked'.

#### `/v list` _(alias: `/vl`, `/vg`)_

- This interface provides an in-depth overview, displaying a list of your owned vehicles along with their status, and offers an option to track them. Choosing a vehicle from this list will cause it to reappear at the location where you initiated the `/v buy` command. It's crucial to note that this feature does not permit the removal of vehicles in the 'impound' state by default; instead, it prompts you to retrieve such vehicles from the designated static impound location unless configured differently.

#### `/v impound` _(optional)_ _(alias: `/vi`)_

- An extra interface that presents a list of all owned vehicles currently impounded (identical to the interface shown when configured to a static location). This command operates exclusively when `shared.impound.static` is set to `false`. If you opt to set `shared.impound.static` as `false`, selecting a vehicle from this list will cause it to spawn at the location where you executed `/v buy`, rather than the general location of the vehicle impound (the vector4 defined at `shared.impound.location`).

#### `/v stats` _(alias: `/vs`)_

- This feature provides an extensive overview of the current vehicle specifications, encompassing its class, transmission level, braking system, suspension setup, turbo configuration, and other relevant details, allowing for a comprehensive understanding of the vehicle capabilities and components.

#### `/impound`

- This command is restricted to certain job roles and is used for moving vehicles to the impound lot, where they are placed in the 'impound' state. You can modify `shared.impound.command` to adjust this command according to your requirements.

*By default, this command serves as the standard method for impounding vehicles. If you happen to be utilizing [ox_target](https://github.com/overextended/ox_target), an additional option is available, allowing you to impound vehicles using the target eye.*

#### [ADMIN] `/admincar`

- Intended to save the current vehicle you are seated in to both the database and your personal vehicle garage.

#### [ADMIN] `/givevehicle [playerId] [model]`

- Simplify the process of adding vehicles to both the database and the vehicle garages of other players.

#### [ADMIN] `/deletevehicle [playerId] [plate]`

- Similar to the command above, this one aims to streamline the procedure of removing vehicles from both the database and the vehicle garages of other players.

### Exported Functions (server)

#### `addVehicle`

- Add a vehicle to the system.

**Example:**
```lua
exports["fivem-parking"]:addVehicle(owner, plate, model, props, type, location, fuel, body, engine, temporary)
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
    - The properties of the vehicle (e.g., vehicle color, tints, etc.) can be obtained using client functions like `lib.getVehicleProperties`.

- **type** _(optional)_
  - `string`
    - The type of vehicle.

- **location** _(optional)_
  - `'outside'` or `'parked'` or `'impound'`, default state is `'outside'`.
    - The state to place the vehicle at, without affecting the physical location of the vehicle.

- **fuel** _(optional)_
  - `number`
    - The fuel level of the vehicle, can be obtained using client functions like `GetVehicleFuelLevel`.

- **body** _(optional)_
  - `number`
    - The body health of the vehicle, can be obtained using client functions like `GetVehicleBodyHealth`.

- **engine** _(optional)_
  - `number`
    - The engine health of the vehicle, can be obtained using client functions like `GetVehicleEngineHealth`.

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
exports["fivem-parking"]:removeVehicle(plate)
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
exports["fivem-parking"]:getVehicle(plate)
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
exports["fivem-parking"]:getVehicleOwner(source, plate)
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
exports["fivem-parking"]:getVehicles(owner, location)
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

#### `setVehicleStatus`

- Set the status of a vehicle.

**Example:**
```lua
exports["fivem-parking"]:setVehicleStatus(owner, plate, status, props, fuel, body, engine)
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
    - The properties of the vehicle (e.g., vehicle color, tints, etc.) can be obtained using client functions like `lib.getVehicleProperties`.

- **fuel** _(optional)_
  - `number`
    - The fuel level of the vehicle, can be obtained using client functions like `GetVehicleFuelLevel`.

- **body** _(optional)_
  - `number`
    - The body health of the vehicle, can be obtained using client functions like `GetVehicleBodyHealth`.

- **engine** _(optional)_
  - `number`
    - The engine health of the vehicle, can be obtained using client functions like `GetVehicleEngineHealth`.

**Return:**
- `boolean`
  - Whether it was successful or not.

- `string`
  - The notification message letting you know if it was successful or not.

#### `getRandomPlate`

- Generate a random plate according to the pattern in the config.

**Example:**
```lua
exports["fivem-parking"]:getRandomPlate()
```

**Return:**
- `string`
  - The generated plate.

#### `saveData`

- Force a save of all vehicles and parking spots to the database.

**Example:**
```lua
exports["fivem-parking"]:saveData()
```

## Credits

- [BerkieB](https://github.com/BerkieBb) originally made this resource. I wanted it publicly available, so here it is.
