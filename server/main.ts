import * as Cfx from '@nativewrappers/fivem/server';
import { CreateVehicle, GetPlayer, GetVehicle, Ox, OxPlayer, OxVehicle, SpawnVehicle } from '@overextended/ox_core/server';
import { addCommand, cache } from '@overextended/ox_lib/server';
import { Data } from '../@types/Data';
import * as config from '../config.json';
import * as db from './db';
import { getArea, hasItem, removeItem, sendLog, sendNotification } from './utils';

const pendingTransfers = new Map<number, { vehicleId: number; playerId: number }>();
const transferCooldowns: Map<number, number> = new Map();

const restrictedGroup: string = `group.${config.ace_group}`;
const cooldownDuration: number = 10 * 60 * 1000; // 10 mins

async function listVehicles(source: number): Promise<Data[]> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return [];

  const vehicles: Data[] | undefined = await db.getOwnedVehicles(player.charId);
  if (!vehicles || vehicles.length === 0) {
    sendNotification(source, '^#d73232ERROR ^#ffffffYou do not own any vehicles.');
    return [];
  }

  sendNotification(source, `^#5e81ac--------- ^#ffffffYour Vehicles ^#5e81ac---------`);
  sendNotification(source, vehicles.map(vehicle => `ID: ^#5e81ac${vehicle.id} ^#ffffff| Plate: ^#5e81ac${vehicle.plate} ^#ffffff| Model: ^#5e81ac${vehicle.model} ^#ffffff| Status: ^#5e81ac${vehicle.stored ? 'Stored' : 'Not Stored'}^#ffffff --- `).join('\n'));
  return vehicles;
}

async function parkVehicle(source: number): Promise<boolean> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return false;

  // @ts-ignore
  const ped: number = GetVehiclePedIsIn(GetPlayerPed(source), false);
  if (ped === 0) {
    sendNotification(source, '^#d73232You are not inside a vehicle!');
    return false;
  }

  const vehicle: OxVehicle = GetVehicle(ped);
  if (!vehicle || !vehicle.owner) {
    sendNotification(source, `^#d73232ERROR ^#ffffffYou are not the owner of this vehicle (^#5e81ac${vehicle?.plate || 'unknown'}^#ffffff).`);
    return false;
  }

  if (!hasItem(source, config.money_item, config.parking_cost)) {
    sendNotification(source, `^#d73232ERROR ^#ffffffYou need $${config.parking_cost} to park your vehicle.`);
    return false;
  }

  const success: boolean = await removeItem(source, config.money_item, config.parking_cost);
  if (!success) return false;

  const update = await db.setVehicleStatus(vehicle.id, 'stored');
  if (!update) return false;

  vehicle.setStored('stored', true);
  sendNotification(source, `^#5e81acYou paid ^#ffffff$${config.parking_cost} ^#5e81acto park your vehicle ^#ffffff${vehicle.model} ^#5e81acwith plate number ^#ffffff${vehicle.plate}.`);

  const [x, y, z] = player.getCoords()
  const date = new Date();
  const formattedDate = `${date.getMonth() + 1}/${date.getDate()}/${date.getFullYear()} ${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}`;
  // @ts-ignore
  await sendLog(`**[${formattedDate}]** [VEHICLE] (${player.get('name')}) (${source}) just parked vehicle #${vehicle.id} with plate #${vehicle.plate} at X: ${x} Y: ${y} Z: ${z}, dimension: #${GetPlayerRoutingBucket(source)}.`);
  return true;
}

async function getVehicle(source: number, args: { vehicleId: number }): Promise<boolean> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return false;

  const vehicleId: number = args.vehicleId;
  const owner: number[] | false | undefined = await db.getVehicleOwner(vehicleId, player.charId);
  if (!owner) {
    sendNotification(source, `^#d73232You cannot retrieve a vehicle you do not own!`);
    return false;
  }

  const status: 1 | undefined = await db.getVehicleStatus(vehicleId, 'stored');
  if (!status) {
    sendNotification(source, `^#d73232ERROR ^#ffffffVehicle with id ${vehicleId} is not stored; it is either outside or at the impound lot.`);
    return false;
  }

  if (!hasItem(source, config.money_item, config.retrieval_cost)) {
    sendNotification(source, `^#d73232ERROR ^#ffffffYou need $${config.retrieval_cost} to retrieve your vehicle.`);
    return false;
  }

  await Cfx.Delay(100);

  const vehicle: OxVehicle | undefined = await SpawnVehicle(vehicleId, player.getCoords());
  if (!vehicle) {
    sendNotification(source, '^#d73232ERROR ^#ffffffFailed to spawn vehicle.');
    return false;
  }

  const success: boolean = await removeItem(source, config.money_item, config.retrieval_cost);
  if (!success) return false;

  const update = await db.setVehicleStatus(vehicleId, 'outside');
  if (!update) return false;

  vehicle.setStored('outside', false);
  sendNotification(source, `^#5e81acYou paid ^#ffffff$${config.retrieval_cost} ^#5e81acto retrieve your vehicle.`);

  const date = new Date();
  const formattedDate = `${date.getMonth() + 1}/${date.getDate()}/${date.getFullYear()} ${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}`;
  // @ts-ignore
  await sendLog(`**[${formattedDate}]** [VEHICLE] (${player.get('name')}) (${source}) just spawned their vehicle #${vehicle.id}! Position: ${player.getCoords()} - dimension: ${GetPlayerRoutingBucket(source)}.`);
  return true;
}

async function returnVehicle(source: number, args: { vehicleId: number }): Promise<boolean> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return false;

  const vehicleId: number = args.vehicleId;
  const coords = player.getCoords();
  if (!getArea({ x: coords[0], y: coords[1], z: coords[2] }, config.impound_location)) {
    sendNotification(source, '^#d73232You are not in the impound area!');
    return false;
  }

  const owner: number[] | false | undefined = await db.getVehicleOwner(vehicleId, player.charId);
  if (!owner) {
    sendNotification(source, `^#d73232You cannot restore a vehicle you do not own!`);
    return false;
  }

  const status: 1 | undefined = await db.getVehicleStatus(vehicleId, 'impound');
  if (!status) {
    sendNotification(source, `^#d73232ERROR ^#ffffffVehicle with id ${vehicleId} is not impounded.`);
    return false;
  }

  if (!hasItem(source, config.money_item, config.impound_cost)) {
    sendNotification(source, `^#d73232ERROR ^#ffffffYou need $${config.impound_cost} to restore this vehicle.`);
    return false;
  }

  const success: boolean = await removeItem(source, config.money_item, config.impound_cost);
  if (!success) return false;

  const update = await db.setVehicleStatus(vehicleId, 'stored');
  if (!update) return false;

  sendNotification(source, `^#5e81acYou paid ^#ffffff$${config.impound_cost} ^#5e81acto restore your vehicle`);
  return true;
}

async function adminDeleteVehicle(source: number, args: { plate: string }): Promise<boolean> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return false;

  const plate: string = args.plate;
  const result: number | undefined = await db.getVehiclePlate(plate);
  if (!result) {
    sendNotification(source, `^#d73232ERROR ^#ffffffVehicle with plate number ${plate} does not exist.`);
    return false;
  }

  const success = await db.deleteVehicle(plate);
  if (!success) {
    sendNotification(source, `^#d73232ERROR ^#ffffffFailed to delete vehicle with plate number ${plate}.`);
    return false;
  }

  sendNotification(source, `^#5e81acSuccessfully deleted vehicle with plate number ^#ffffff${plate}.`);
  return true;
}

async function adminSetVehicle(source: number, args: { model: string }): Promise<boolean> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return false;

  const model: string = args.model;
  const data = { owner: player.charId, model: model };

  await Cfx.Delay(100);

  const vehicle: OxVehicle | undefined = await CreateVehicle(data, player.getCoords());
  if (!vehicle || vehicle.owner !== player.charId) {
    sendNotification(source, `^#d73232ERROR ^#ffffffFailed to spawn vehicle or set ownership.`);
    return false;
  }

  vehicle.setStored('outside', false);
  sendNotification(source, `^#5e81acSuccessfully spawned vehicle ^#ffffff${vehicle.make} ${vehicle.model} ^#5e81acwith plate number ^#ffffff${vehicle.plate} ^#5e81acand set it as owned.`);
  return true;
}

async function adminGiveVehicle(source: number, args: { playerId: number; model: string }): Promise<boolean> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return false;

  const playerId: number = args.playerId;
  const target: OxPlayer = GetPlayer(playerId);
  if (!target?.charId) {
    sendNotification(source, `^#d73232ERROR ^#ffffffNo player found with id ${playerId}.`);
    return false;
  }

  const model: string = args.model;
  const data = { owner: target.charId, model: model };

  await Cfx.Delay(100);

  const vehicle: OxVehicle | undefined = await CreateVehicle(data, player.getCoords());
  if (!vehicle || vehicle.owner !== target.charId) {
    sendNotification(source, `^#d73232ERROR ^#ffffffFailed to give vehicle ${model} to player with id ${playerId}.`);
    return false;
  }

  vehicle.setStored('stored', true);
  sendNotification(source, `^#5e81acSuccessfully gave vehicle ^#ffffff${vehicle.make} ${model} (${vehicle.plate}) ^#5e81acto ^#ffffff${target.get('name')}.`);
  return true;
}

async function adminViewVehicles(source: number, args: { playerId: number }): Promise<boolean> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return false;

  const playerId: number = args.playerId;
  const target: OxPlayer = GetPlayer(playerId);
  if (!target?.charId) {
    sendNotification(source, `^#d73232ERROR ^#ffffffNo player found with id ${playerId}.`);
    return false;
  }

  const vehicles: Data[] = await db.getOwnedVehicles(target.charId);
  if (vehicles.length === 0) {
    sendNotification(source, `^#d73232ERROR ^#ffffffNo vehicles found for player with id ${playerId}.`);
    return false;
  }

  sendNotification(source, `^#5e81ac--------- ^#ffffff${target.get('name')} (${playerId}) Owned Vehicles ^#5e81ac---------`);
  sendNotification(source, vehicles.map(vehicle => `ID: ^#5e81ac${vehicle.id} ^#ffffff| Plate: ^#5e81ac${vehicle.plate} ^#ffffff| Model: ^#5e81ac${vehicle.model} ^#ffffff| Status: ^#5e81ac${vehicle.stored}^#ffffff --- `).join('\n'));
  return true;
}

async function initiateTransfer(source: number, args: { vehicleId: number; playerId: number; confirm?: string }): Promise<boolean> {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return false;

  const vehicleId: number = args.vehicleId;
  const playerId: number = args.playerId;
  const confirm: string | undefined = args.confirm;

  const time: number = Date.now();
  const lastTransfer: number | undefined = transferCooldowns.get(source);

  if (lastTransfer && time - lastTransfer < cooldownDuration) {
    const timeLeft: number = Math.ceil((cooldownDuration - (time - lastTransfer)) / 1000);
    sendNotification(source, `^#d73232You must wait ^#ffffff${timeLeft} ^#d73232seconds before transferring another vehicle.`);
    return false;
  }

  if (confirm === 'confirm') {
    const pending: { vehicleId: number; playerId: number } | undefined = pendingTransfers.get(source);
    if (!pending) {
      sendNotification(source, `^#d73232You have no pending vehicle transfer to confirm!`);
      return false;
    }

    if (player.charId === pending.playerId) {
      sendNotification(source, `^#d73232Cannot transfer vehicle ownership to yourself!`);
      return false;
    }

    const success = await db.transferVehicle(pending.vehicleId, pending.playerId);
    if (!success) {
      sendNotification(source, `^#d73232ERROR ^#ffffffFailed to transfer vehicle ownership.`);
      return false;
    }

    const target: OxPlayer = GetPlayer(pending.playerId);
    if (target) {
      sendNotification(target.source, `^#5e81acYou have received ownership of a new vehicle!`);
    }

    sendNotification(source, `^#c78946Successfully transferred ownership of vehicle.`);
    pendingTransfers.delete(source);
    transferCooldowns.set(source, time);
    return true;
  }

  if (confirm) {
    sendNotification(source, `^#d73232Invalid confirmation; use "confirm" to proceed.`);
    return false;
  }

  const target: OxPlayer = GetPlayer(playerId);
  if (!target?.charId) {
    sendNotification(source, `^#d73232ERROR ^#ffffffNo player found with id ${playerId}.`);
    return false;
  }

  const owner: false | 1[] = await db.getVehicleOwner(vehicleId, player.charId);
  if (!owner) {
    sendNotification(source, `^#d73232You cannot transfer a vehicle you do not own!`);
    return false;
  }

  pendingTransfers.set(source, { vehicleId, playerId });
  sendNotification(source, `^#5e81acPlease confirm the transfer of vehicle with id ^#c78946(${vehicleId}) ^#5e81acto ^#c78946${target.get('name')} (${playerId}) ^#5e81acby typing the command again with "confirm".`);
  return false;
}

addCommand('savevehicles', async (source: number) => {
  const player: OxPlayer = GetPlayer(source);
  if (!player?.charId) return;

  try {
    sendNotification(source, `^#5e81acSaving all vehicles...`);
    await Cfx.Delay(500);
    await Ox.SaveAllVehicles();
    sendNotification(source, `^#c78946Successfully saved all vehicles!`);
  } catch (error) {
    console.error('/savevehicles:', error)
    sendNotification(source, `^#d73232Failed to save all vehicles!`);
  }
}, {
  restricted: 'group.admin',
});

addCommand(['list', 'vl'], listVehicles, {
  restricted: false,
});

addCommand(['park', 'vp'], parkVehicle, {
  restricted: false,
});

addCommand(['get', 'vg'], getVehicle, {
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

addCommand(['viewvehicles'], adminViewVehicles, {
  params: [
    {
      name: 'playerId',
      paramType: 'number',
      optional: false,
    },
  ],
  restricted: restrictedGroup,
});

addCommand(['transfervehicle'], initiateTransfer, {
  params: [
    {
      name: 'vehicleId',
      paramType: 'number',
      optional: false,
    },
    {
      name: 'playerId',
      paramType: 'number',
      optional: false,
    },
    {
      name: 'confirm',
      paramType: 'string',
      optional: true,
    },
  ],
  restricted: false,
});

on('onResourceStop', async (resourceName: string): Promise<void> => {
  if (resourceName !== 'fivem-parking') return;

  try {
    console.log(`\x1b[33m[${cache.resource}] Saving all vehicles...\x1b[0m`);
    await Ox.SaveAllVehicles();
    console.log(`\x1b[32m[${cache.resource}] Successfully saved all vehicles.\x1b[0m`);
  } catch (error) {
    console.error(`\x1b[31m[${cache.resource}] Failed to save vehicles: ${error}\x1b[0m`);
  }
});
