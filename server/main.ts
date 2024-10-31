import * as Cfx from '@nativewrappers/fivem/server';
import {
  CreateVehicle,
  GetPlayer,
  GetVehicle,
  OxPlayer,
  OxVehicle,
  SpawnVehicle,
} from '@overextended/ox_core/server';
import { addCommand, cache } from '@overextended/ox_lib/server';
import * as config from '../config.json';
import * as db from './db';
import { VehicleData } from './db';

const restrictedGroup: string = `group.${config.ace_group}`;

async function getVehicles(source: number): Promise<VehicleData[]> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return [];

  const vehicles: VehicleData[] = await db.fetchVehicles(player.charId);

  if (vehicles.length > 0) {
    exports.chat.addMessage(source, `^#5e81ac--------- ^#ffffffYour Vehicles ^#5e81ac---------`);
    exports.chat.addMessage(
      source,
      vehicles
        .map(
          vehicle =>
            `ID: ^#5e81ac${vehicle.id} ^#ffffff| Plate: ^#5e81ac${vehicle.plate} ^#ffffff| Model: ^#5e81ac${vehicle.model} ^#ffffff| Status: ^#5e81ac${vehicle.stored}^#ffffff - `,
        )
        .join('\n'),
    );
  } else {
    exports.chat.addMessage(source, '^#d73232ERROR ^#ffffffYou do not own any vehicles.');
  }

  return vehicles;
}

async function parkVehicle(source: number): Promise<boolean | undefined> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return;

  // @ts-ignore
  const ped: number = GetVehiclePedIsIn(GetPlayerPed(`${source}`), false);
  if (ped === 0) {
    exports.chat.addMessage(source, '^#d73232ERROR ^#ffffffYou are not inside of a vehicle.');
    return false;
  }

  const vehicle: OxVehicle = GetVehicle(ped);
  if (!vehicle.owner) {
    exports.chat.addMessage(
      source,
      `^#d73232ERROR ^#ffffffYou are not the owner of this vehicle with plate number ${vehicle.plate}.`,
    );
    return false;
  }

  const count = exports.ox_inventory.GetItemCount(source, 'money');
  if (count < config.parking_cost) {
    exports.chat.addMessage(
      source,
      `^#d73232ERROR ^#ffffffYou do not have enough money to park the vehicle. You need $${config.parking_cost}.`,
    );
    return false;
  }

  const result = await exports.ox_inventory.RemoveItem(source, 'money', config.parking_cost);
  if (!result) return false;

  const success: boolean = await db.storeVehicle('stored', vehicle.id, player.charId);
  if (!success) return false;

  vehicle.setStored('stored', true);
  exports.chat.addMessage(
    source,
    `^#5e81acYou paid ^#ffffff$${config.parking_cost} ^#5e81acto park your vehicle ^#ffffff${vehicle.model} ^#5e81acwith plate number ^#ffffff${vehicle.plate}`,
  );

  return true;
}

async function retrieveVehicle(
  source: number,
  args: { vehicleId: number },
): Promise<boolean | undefined> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return;

  const id: number = args.vehicleId;
  const coords: [] = player.getCoords();

  const status: boolean = await db.getVehicleStatus(id, 'stored');
  if (!status) {
    exports.chat.addMessage(
      source,
      `^#d73232ERROR ^#ffffffVehicle with id ${id} does not exist or is not stored.`,
    );
    return false;
  }

  const owner: boolean = await db.getVehicleOwner(id, player.charId);
  if (!owner) {
    exports.chat.addMessage(source, '^#d73232ERROR ^#ffffffYou are not the owner of this vehicle.');
    return false;
  }

  const count = exports.ox_inventory.GetItemCount(source, 'money');
  if (count < config.retrieval_cost) {
    exports.chat.addMessage(
      source,
      `^#d73232ERROR ^#ffffffYou do not have enough money to retrieve the vehicle. You need $${config.retrieval_cost}.`,
    );
    return false;
  }

  const result = await exports.ox_inventory.RemoveItem(source, 'money', config.retrieval_cost);
  if (!result) return false;

  const success = await SpawnVehicle(id, coords);
  if (!success) {
    exports.chat.addMessage(source, '^#d73232ERROR ^#ffffffFailed to spawn vehicle.');
    return false;
  }

  success.setStored('outside', false);
  exports.chat.addMessage(
    source,
    `^#5e81acYou paid ^#ffffff$${config.retrieval_cost} ^#5e81acto retrieve your vehicle`,
  );

  TaskWarpPedIntoVehicle(GetPlayerPed(`${source}`), success.entity, -1);

  return true;
}

async function returnVehicle(
  source: number,
  args: { vehicleId: number },
): Promise<boolean | undefined> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return;

  const vehicleId: number = args.vehicleId;

  const status: boolean = await db.getVehicleStatus(vehicleId, 'impound');
  if (!status) {
    exports.chat.addMessage(
      source,
      `^#d73232ERROR ^#ffffffVehicle with id ${vehicleId} is not impounded.`,
    );
    return false;
  }

  const owner: boolean = await db.getVehicleOwner(vehicleId, player.charId);
  if (!owner) {
    exports.chat.addMessage(source, '^#d73232ERROR ^#ffffffYou are not the owner of this vehicle.');
    return false;
  }

  const count = exports.ox_inventory.GetItemCount(source, 'money');
  if (count < config.impound_cost) {
    exports.chat.addMessage(
      source,
      `^#d73232ERROR ^#ffffffYou do not have enough money to retrieve this vehicle. You need $${config.impound_cost}.`,
    );
    return false;
  }

  const result = await exports.ox_inventory.RemoveItem(source, 'money', config.impound_cost);
  if (!result) return false;

  const success: boolean | null = await db.updateVehicleStatus(vehicleId, 'stored');
  if (!success) return false;

  exports.chat.addMessage(
    source,
    `^#5e81acSuccessfully restored vehicle with id ^#ffffff${vehicleId}`,
  );

  return true;
}

async function adminDeleteVehicle(
  source: number,
  args: { plate: string },
): Promise<boolean | undefined> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return;

  const plate: string = args.plate;

  const exists: boolean = await db.getVehiclePlate(plate);
  if (!exists) {
    exports.chat.addMessage(
      source,
      `^#d73232ERROR ^#ffffffVehicle with plate number ${plate} does not exist.`,
    );
    return false;
  }

  const result: boolean | 0 | null | undefined = await db.deleteVehicle(plate);
  if (!result) return false;

  exports.chat.addMessage(
    source,
    `^#5e81acSuccessfully deleted vehicle with plate number ^#ffffff${plate}`,
  );
  return true;
}

async function adminSetVehicle(source: number, args: { model: string }): Promise<void> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return;

  const coords: [] = player.getCoords();

  const vehicle: OxVehicle = await CreateVehicle(
    { owner: player.charId, model: args.model },
    coords,
  );
  if (!vehicle?.owner) return;

  vehicle.setStored('outside', false);
  exports.chat.addMessage(
    source,
    `^#5e81acSuccessfully spawned vehicle ^#ffffff${args.model} ^#5e81acwith plate number ^#ffffff${vehicle.plate} ^#5e81acand set it as owned`,
  );

  TaskWarpPedIntoVehicle(GetPlayerPed(`${source}`), vehicle.entity, -1);
}

async function adminGiveVehicle(
  source: number,
  args: { playerId: number; model: string },
): Promise<void> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return;

  const owner: number = args.playerId;
  const model: string = args.model;

  const coords = player.getCoords();
  const data = { model, owner, stored: 'stored' };

  // we aren't spawning the vehicle here so we don't
  // need to pass coords, although I can't seem to make CreateVehicle work
  // without passing it, at least it still works.
  const vehicle = await CreateVehicle(data, coords);
  if (!vehicle) return;

  vehicle.setStored('stored', true);
  exports.chat.addMessage(
    source,
    `^#5e81acSuccessfully gave vehicle ^#ffffff${model} ^#5e81acto player with id ^#ffffff${owner}`,
  );
}

addCommand(['list', 'vl'], getVehicles, {
  restricted: false,
});

addCommand(['park', 'vp'], parkVehicle, {
  restricted: false,
});

addCommand(['get', 'vg'], retrieveVehicle, {
  params: [
    {
      name: 'vehicleId',
      paramType: 'number',
      optional: false,
    },
  ],
  restricted: false,
});

addCommand(['impound', 'rv'], returnVehicle, {
  params: [
    {
      name: 'vehicleId',
      paramType: 'number',
      optional: false,
    },
  ],
  restricted: false,
});

addCommand(['deletevehicle'], adminDeleteVehicle, {
  params: [
    {
      name: 'plate',
      paramType: 'string',
      optional: false,
    },
  ],
  restricted: restrictedGroup,
});

addCommand(['admincar'], adminSetVehicle, {
  params: [
    {
      name: 'model',
      paramType: 'string',
      optional: false,
    },
  ],
  restricted: restrictedGroup,
});

addCommand(['addvehicle'], adminGiveVehicle, {
  params: [
    {
      name: 'playerId',
      paramType: 'number',
      optional: false,
    },
    {
      name: 'model',
      paramType: 'string',
      optional: false,
    },
  ],
  restricted: restrictedGroup,
});

on('onResourceStart', async (resourceName: string): Promise<void> => {
  if (resourceName !== 'fivem-parking') return;

  await Cfx.Delay(100);

  try {
    console.log(`\x1b[32m[${cache.resource}] Successfully started ${cache.resource}.\x1b[0m`);
  } catch (error) {
    console.error(`\x1b[31m[${cache.resource}] Failed to start ${cache.resource}: ${error}\x1b[0m`);
  }
});
