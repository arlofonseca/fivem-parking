# fivem-parking

A advanced vehicle garage system created with the intention of transitioning towards a more universal and adaptable structure.

## Features

- Conveniently store and retrieve your owned vehicles from a location of your choosing via commands.
- Identify whether you own a vehicle or not.
- Once your vehicle is impounded, the retrieval process becomes constrained to a fixed and static impound lot location.
- Support is extended to aircrafts and boats.
- Includes a tracking system to locate lost vehicles easily, either within a garage, on the map, or at the impound lot.
- The process of spawning vehicles is primarily handled via ox_core.
- Logs for specific actions are handled by ox_lib's [logger](https://overextended.dev/ox_lib/Modules/Logger/Server#liblogger) module, Discord is no longer supported.
- Only ox_core is supported and comes integrated by default.

## Installation

##### _If you download the source code via the green `Code` button, you'll need to build the resource. Information on how to do this is provided below. If you prefer not to build it, you can download latest release and drag and drop it into your server. However, any changes made to the built resource will need to be re-built to apply the changes._

### Dependencies

- [oxmysql](https://github.com/overextended/oxmysql)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_core](https://github.com/overextended/ox_core)

### Building this resource

1. Download and install the LTS version of Node.js.
2. Open a command-line terminal (e.g., Terminal, Command Prompt).
3. Enter `node --version` to verify the installation.
4. Run `npm install -g pnpm` to globally install the package manager [pnpm](https://pnpm.io).
5. Download or clone the repository with `git clone https://github.com/arlofonseca/fivem-parking`.
6. Install all dependencies with `pnpm i`.
7. Build the resource with `pnpm build`.

Use `pnpm watch` to rebuild whenever a file is modified.

## Usage

### Commands

#### `/list` _(alias: `/vl`)_

- Displays a list of your owned vehicles.

#### `/park` _(alias: `/vp`)_

- Stores your vehicle into your vehicle garage.

#### `/get [vehicleId]` _(alias: `/vg`)_

- Retrieve your vehicle from your vehicle garage via its unique identifier.

*If you do not know the unique identifier of your vehicle, you can find it when executing the `/list` command.*

#### [ADMIN] `/deletevehicle [plate]`

- Removes a vehicle from the database.

*This action cannot be reversed.*

#### [ADMIN] `/admincar [model]`

- Spawns a saves the provided vehicle model to both the database and your vehicle garage.

## Credits

- [BerkieB](https://github.com/BerkieBb) originally made this resource. I wanted it publicly available, so here it is.
