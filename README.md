# fivem-parking

A simple vehicle garage system created with a more versatile structure, allowing players to conveniently store and retrieve owned vehicles from any location.

## Features

- Utilizes [Prisma](https://www.prisma.io) to interact with your database.
- Menu is handled via ox_lib's [interface](https://overextended.dev/ox_lib/Modules/Interface/Client/context) module, which has replaced the old React + Mantine interface.
- Supports logging via Discord.
- Administrators have the ability to manage and oversee vehicles via command.

## Installation

##### _If you download the source code via the green `Code` button, you'll need to build the resource. Information on how to do this is provided below. If you prefer not to build it, you can download latest release and drag and drop it into your server. However, any changes made to the built resource will need to be re-built to apply the changes._

### Dependencies

- [ox_core](https://github.com/overextended/ox_core)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory)

### Building this resource

1. Download and install the LTS version of [Node.js](https://nodejs.org/en).
2. Open a command-line terminal (e.g., Terminal, Command Prompt).
3. Enter `node --version` to verify the installation.
4. Run `npm install -g pnpm` to globally install the package manager [pnpm](https://pnpm.io).
5. Download or clone the repository with `git clone https://github.com/arlofonseca/fivem-parking`.
6. Install all dependencies with `pnpm i`.
7. Create a new file named `.env` within the root directory.
8. Copy the contents of `.env.example` to the newly created `.env` file and edit accordingly.
9. Connect your database with `pnpm pull` to add Prisma models to `schema.prisma`.
10. Generate Prisma client using `pnpm generate`.
11. Build the resource with `pnpm build`.

Use `pnpm watch` to rebuild whenever a file is modified.

## Usage

### Commands

#### `/list` _(alias: `/vl`)_

- Displays a list of your owned vehicles.

#### `/get [vehicleId]` _(alias: `/vg`)_

- Retrieve your vehicle from your vehicle garage via its unique identifier.

_If you do not know the unique identifier of your vehicle, you can find it when executing the `/list` command._

#### `/park` _(alias: `/vp`)_

- Stores your vehicle into your vehicle garage.

#### `/impound [vehicleId]` _(alias: `/rv`)_

- Retrieve your vehicle from the impound via its unique identifier, restoring it to the `stored` state.

_This will only work if you are within the radius of the location defined in `config.json`._

#### [ADMIN] `/adeletevehicle [plate]` _(alias: `/delveh`)_

- Removes a vehicle from the database.

_This action cannot be reversed._

#### [ADMIN] `/admincar [model]` _(alias: `/acar`)_

- Spawns a vehicle and saves it to both the database and your vehicle garage.

#### [ADMIN] `/addvehicle [playerId] [model]`

- Adds a vehicle to the target player's vehicle garage.

#### [ADMIN] `/playervehicles [playerId]`

- Displays a list of the target player's owned vehicles.

## Support

For any feedback or support regarding this script, please reach out on [discord](https://discord.com/invite/QZgyyBkUkp).

## Credits

- [BerkieB](https://github.com/BerkieBb) originally made this resource. I wanted it publicly available, so here it is.
