import * as Cfx from '@nativewrappers/fivem/server';
import { CreateVehicle, GetPlayer, GetVehicle, OxPlayer, OxVehicle, SpawnVehicle } from '@overextended/ox_core/server';
import { addCommand } from '@overextended/ox_lib/server';
import * as config from '../config.json';
import * as db from './db';
import { VehicleData } from './db';

const restrictedGroup: string = `group.${config.ace_group}`;

async function getVehicles(source: number): Promise<VehicleData[]> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return [];

  const vehicles = await db.fetchVehicles(player.charId);

  if (vehicles.length > 0) {
    exports.chat.addMessage(source, `^#5e81ac--------- ^#ffffffYour Vehicles ^#5e81ac---------`);
    exports.chat.addMessage(source, vehicles.map(vehicle => `ID: ^#5e81ac${vehicle.id} ^#ffffff| Plate: ^#5e81ac${vehicle.plate} ^#ffffff| Model: ^#5e81ac${vehicle.model} ^#ffffff| Status: ^#5e81ac${vehicle.stored}^#ffffff - `).join('\n'));
  } else {
    exports.chat.addMessage(source, '^#d73232ERROR ^#ffffffYou do not own any vehicles.');
  }

  return vehicles;
}

async function parkVehicle(source: number): Promise<boolean | undefined> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return;

  // @ts-ignore
  const ped = GetVehiclePedIsIn(GetPlayerPed(source), false);
  if (ped === 0) {
    exports.chat.addMessage(source, '^#d73232ERROR ^#ffffffYou are not inside of a vehicle.');
    return false;
  }

  const vehicle: OxVehicle = GetVehicle(ped);
  if (!vehicle.owner) {
    exports.chat.addMessage(source, `^#d73232ERROR ^#ffffffYou are not the owner of this vehicle with plate number ${vehicle.plate}.`);
    return false;
  }

  const success: boolean = await db.storeVehicle('stored', vehicle.id, player.charId);
  if (!success) {
    exports.chat.addMessage(source, '^#d73232ERROR ^#ffffffFailed to store the vehicle in the database.');
    return false;
  }

  vehicle.setStored('stored', true);
  exports.chat.addMessage(source, `^#5e81acSuccessfully parked vehicle ^#ffffff${vehicle.model} ^#5e81acwith plate number ^#ffffff${vehicle.plate}`);

  return true;
}

async function retrieveVehicle(source: number, args: { vehicleId: number }): Promise<boolean | undefined> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return;

  const id: number = args.vehicleId;
  const coords: [] = player.getCoords();

  const status: boolean = await db.getVehicleStatus(id);
  if (!status) {
    exports.chat.addMessage(source, `^#d73232ERROR ^#ffffffVehicle with id ${id} does not exist or is not stored.`);
    return false;
  }

  const owner: boolean = await db.getVehicleOwner(id, player.charId);
  if (!owner) {
    exports.chat.addMessage(source, '^#d73232ERROR ^#ffffffYou are not the owner of this vehicle.');
    return false;
  }

  const result = await SpawnVehicle(id, coords);
  if (!result) {
    exports.chat.addMessage(source, '^#d73232ERROR ^#ffffffFailed to spawn vehicle.');
    return false;
  }

  result.setStored('outside', false);
  exports.chat.addMessage(source, '^#5e81acSuccessfully spawned vehicle.');

  // @ts-ignore
  TaskWarpPedIntoVehicle(GetPlayerPed(source), result.entity, -1);

  return true;
}

async function deleteVehicle(source: number, args: { plate: string }): Promise<boolean | undefined> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return;

  const plate: string = args.plate;

  const exists: boolean = await db.getVehiclePlate(plate);
  if (!exists) {
    exports.chat.addMessage(source, `^#d73232ERROR ^#ffffffVehicle with plate number ${plate} does not exist.`);
    return false;
  }

  const result = await db.deleteVehicle(plate);
  if (!result) {
    exports.chat.addMessage(source, `^#d73232ERROR ^#ffffffFailed to delete vehicle with plate number ${plate}.`);
    return false;
  }

  exports.chat.addMessage(source, `^#5e81acSuccessfully deleted vehicle with plate number ^#ffffff${plate}`);
  return true;
}

async function setVehicleOwned(source: number, args: { model: string }): Promise<void> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return;

  const coords: [] = player.getCoords();

  const vehicle: OxVehicle = await CreateVehicle({ owner: player.charId, model: args.model }, coords);
  if (!vehicle?.owner) {
    exports.chat.addMessage(source, `^#5e81acSuccessfully spawned vehicle ^#ffffff${args.model} ^#5e81acwith plate number ^#ffffff${vehicle.plate} ^#5e81acand set it as owned`);
    return;
  }

  vehicle.setStored('outside', false);

  // @ts-ignore
  TaskWarpPedIntoVehicle(GetPlayerPed(source), vehicle.entity, -1);
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

addCommand(['deletevehicle'], deleteVehicle, {
  params: [
    {
      name: 'plate',
      paramType: 'string',
      optional: false,
    },
  ],
  restricted: restrictedGroup,
});

addCommand(['admincar'], setVehicleOwned, {
  params: [
    {
      name: 'model',
      paramType: 'string',
      optional: false,
    },
  ],
  restricted: restrictedGroup,
});