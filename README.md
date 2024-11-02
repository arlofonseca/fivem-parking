# fivem-parking

A simple vehicle garage system created with a more versatile structure, allowing players to manage their vehicles from any location.

## Installation

##### _If you download the source code via the green `Code` button, you'll need to build the resource. Information on how to do this is provided below. If you prefer not to build it, you can download latest release and drag and drop it into your server. However, any changes made to the built resource will need to be re-built to apply the changes._

### Dependencies

- [oxmysql](https://github.com/overextended/oxmysql)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_core](https://github.com/overextended/ox_core)
- [ox_inventory](https://github.com/overextended/ox_inventory)

### Building this resource

1. Download and install the LTS version of [Node.js](https://nodejs.org/en).
2. Open a command-line terminal (e.g., Terminal, Command Prompt).
3. Enter `node --version` to verify the installation.
4. Run `npm install -g pnpm` to globally install the package manager [pnpm](https://pnpm.io).
5. Download or clone the repository with `git clone https://github.com/arlofonseca/fivem-parking`.
6. Install all dependencies with `pnpm i`.
7. Build the resource with `pnpm build`.

Use `pnpm watch` to rebuild whenever a file is modified and `pnpm format` to autoformat using prettier.

## Usage

### Commands

#### `/list` _(alias: `/vl`)_

- Displays a list of your owned vehicles.

#### `/park` _(alias: `/vp`)_

- Stores your vehicle into your vehicle garage.

#### `/get [vehicleId]` _(alias: `/vg`)_

- Retrieve your vehicle from your vehicle garage via its unique identifier.

_If you do not know the unique identifier of your vehicle, you can find it when executing the `/list` command._

#### `/impound [vehicleId]` _(alias: `/rv`)_

- Retrieve your vehicle from the impound via its unique identifier, restoring it to the `stored` state.

_This will only work if you are within the radius of the location defined in `config.json`._

#### `/transfervehicle [vehicleId] [playerId] [confirm]`

- Transfer ownership of a vehicle to another player.

#### [ADMIN] `/deletevehicle [plate]`

- Removes a vehicle from the database.

_This action cannot be reversed._

#### [ADMIN] `/admincar [model]`

- Spawns a vehicle and saves it to both the database and your vehicle garage.

#### [ADMIN] `/addvehicle [playerId] [model]`

- Adds a vehicle to the target player's vehicle garage.

#### [ADMIN] `/viewvehicles [playerId]`

- Displays a list of the target player's owned vehicles.

## Credits

- [BerkieB](https://github.com/BerkieBb) originally made this resource. I wanted it publicly available, so here it is.
