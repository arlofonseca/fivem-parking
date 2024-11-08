import * as Cfx from "@nativewrappers/fivem/server";
import { CreateVehicle, GetPlayer, GetVehicle, Ox, SpawnVehicle } from "@overextended/ox_core/server";
import { addCommand, cache } from "@overextended/ox_lib/server";
import * as config from "../config.json";
import * as db from "./db";
import { getArea, hasItem, removeItem, sendLog, sendChatMessage } from "./utils";

const restrictedGroup: string = `group.${config.ace_group}`;

async function listVehicles(source: number) {
  const player = GetPlayer(source);

  if (!player?.charId) return [];

  const vehicles = await db.getOwnedVehicles(player.charId);
  if (!vehicles || vehicles.length === 0) {
    sendChatMessage(source, "^#d73232You do not own any vehicles!");
    return [];
  }

  emitNet("fivem-parking:client:listVehicles", source, vehicles);

  return vehicles;
}

async function parkVehicle(source: number): Promise<boolean> {
  const player = GetPlayer(source);

  if (!player?.charId) return false;

  const ped: number = GetVehiclePedIsIn(GetPlayerPed(source), false);
  if (ped === 0) {
    sendChatMessage(source, "^#d73232You are not inside a vehicle!");
    return false;
  }

  const vehicle = GetVehicle(ped);
  if (!vehicle?.owner) {
    sendChatMessage(source, `^#d73232ERROR ^#ffffffYou are not the owner of this vehicle (^#5e81ac${vehicle?.plate || "unknown"}^#ffffff).`);
    return false;
  }

  if (!hasItem(source, config.money_item, config.parking_cost)) {
    sendChatMessage(source, `^#d73232ERROR ^#ffffffYou need $${config.parking_cost} to park your vehicle.`);
    return false;
  }

  const success: boolean = await removeItem(source, config.money_item, config.parking_cost);

  if (!success) return false;

  vehicle.setStored("stored", true);
  sendChatMessage(source, `^#5e81acYou paid ^#ffffff$${config.parking_cost} ^#5e81acto park your vehicle ^#ffffff${vehicle.model} ^#5e81acwith plate number ^#ffffff${vehicle.plate}.`);

  const [x, y, z] = player.getCoords();
  // @ts-ignore
  await sendLog(`[VEHICLE] ${player.get("name")} (${source}) just parked vehicle #${vehicle.id} with plate #${vehicle.plate} at X: ${x} Y: ${y} Z: ${z}, dimension: #${GetPlayerRoutingBucket(source)}.`);

  return true;
}

async function getVehicle(source: number, args: { vehicleId: number }): Promise<boolean> {
  const player = GetPlayer(source);

  if (!player?.charId) return false;

  const vehicleId: number = args.vehicleId;
  const owner = await db.getVehicleOwner(vehicleId, player.charId);
  if (!owner) {
    sendChatMessage(source, `^#d73232You cannot retrieve a vehicle you do not own!`);
    return false;
  }

  const status = await db.getVehicleStatus(vehicleId, "stored");
  if (!status) {
    sendChatMessage(source, `^#d73232ERROR ^#ffffffVehicle with id ${vehicleId} is not stored; it is either outside or at the impound lot.`);
    return false;
  }

  if (!hasItem(source, config.money_item, config.retrieval_cost)) {
    sendChatMessage(source, `^#d73232ERROR ^#ffffffYou need $${config.retrieval_cost} to retrieve your vehicle.`);
    return false;
  }

  const success: boolean = await removeItem(source, config.money_item, config.retrieval_cost);

  if (!success) return false;

  await Cfx.Delay(100);

  const vehicle = await SpawnVehicle(vehicleId, player.getCoords());
  if (!vehicle) {
    sendChatMessage(source, "^#d73232ERROR ^#ffffffFailed to spawn vehicle.");
    return false;
  }

  vehicle.setStored("outside", false);
  sendChatMessage(source, `^#5e81acYou paid ^#ffffff$${config.retrieval_cost} ^#5e81acto retrieve your vehicle.`);

  const [x, y, z] = player.getCoords();
  // @ts-ignore
  await sendLog(`[VEHICLE] ${player.get("name")} (${source}) just spawned their vehicle #${vehicle.id}! Position: ${x} ${y} ${z} - dimension: ${GetPlayerRoutingBucket(source)}.`);

  return true;
}

async function returnVehicle(source: number, args: { vehicleId: number }): Promise<boolean> {
  const player = GetPlayer(source);

  if (!player?.charId) return false;

  const vehicleId: number = args.vehicleId;
  const coords = player.getCoords();
  if (!getArea({ x: coords[0], y: coords[1], z: coords[2] }, config.impound_location)) {
    sendChatMessage(source, "^#d73232You are not in the impound area!");
    return false;
  }

  const owner = await db.getVehicleOwner(vehicleId, player.charId);
  if (!owner) {
    sendChatMessage(source, `^#d73232You cannot restore a vehicle you do not own!`);
    return false;
  }

  const status = await db.getVehicleStatus(vehicleId, "impound");
  if (!status) {
    sendChatMessage(source, `^#d73232ERROR ^#ffffffVehicle with id ${vehicleId} is not impounded.`);
    return false;
  }

  if (!hasItem(source, config.money_item, config.impound_cost)) {
    sendChatMessage(source, `^#d73232ERROR ^#ffffffYou need $${config.impound_cost} to restore this vehicle.`);
    return false;
  }

  const success: boolean = await removeItem(source, config.money_item, config.impound_cost);

  if (!success) return false;

  await db.setVehicleStatus(vehicleId, "stored");
  sendChatMessage(source, `^#5e81acYou paid ^#ffffff$${config.impound_cost} ^#5e81acto restore your vehicle`);

  return true;
}

async function adminDeleteVehicle(source: number, args: { plate: string }): Promise<boolean> {
  const player = GetPlayer(source);

  if (!player?.charId) return false;

  const plate: string = args.plate;
  const result = await db.getVehiclePlate(plate);
  if (!result) {
    sendChatMessage(source, `^#d73232ERROR ^#ffffffVehicle with plate number ${plate} does not exist.`);
    return false;
  }

  const success = await db.deleteVehicle(plate);
  if (!success) {
    sendChatMessage(source, `^#d73232ERROR ^#ffffffFailed to delete vehicle with plate number ${plate}.`);
    return false;
  }

  sendChatMessage(source, `^#5e81acSuccessfully deleted vehicle with plate number ^#ffffff${plate}.`);

  return true;
}

async function adminSetVehicle(source: number, args: { model: string }): Promise<boolean> {
  const player = GetPlayer(source);

  if (!player?.charId) return false;

  const model: string = args.model;
  const data = { owner: player.charId, model: model };

  await Cfx.Delay(100);

  const vehicle = await CreateVehicle(data, player.getCoords());
  if (!vehicle || vehicle.owner !== player.charId) {
    sendChatMessage(source, `^#d73232ERROR ^#ffffffFailed to spawn vehicle or set ownership.`);
    return false;
  }

  vehicle.setStored("outside", false);
  sendChatMessage(source, `^#5e81acSuccessfully spawned vehicle ^#ffffff${vehicle.make} ${vehicle.model} ^#5e81acwith plate number ^#ffffff${vehicle.plate} ^#5e81acand set it as owned.`);

  return true;
}

async function adminGiveVehicle(source: number, args: { playerId: number; model: string }): Promise<boolean> {
  const player = GetPlayer(source);

  if (!player?.charId) return false;

  const playerId: number = args.playerId;
  const target = GetPlayer(playerId);
  if (!target?.charId) {
    sendChatMessage(source, `^#d73232ERROR ^#ffffffNo player found with id ${playerId}.`);
    return false;
  }

  const model: string = args.model;
  const data = { owner: target.charId, model: model };

  await Cfx.Delay(100);

  const vehicle = await CreateVehicle(data, player.getCoords());
  if (!vehicle || vehicle.owner !== target.charId) {
    sendChatMessage(source, `^#d73232ERROR ^#ffffffFailed to give vehicle to ${target.get("name")}.`);
    return false;
  }

  vehicle.setStored("stored", true);
  sendChatMessage(source, `^#5e81acSuccessfully gave vehicle ^#ffffff${vehicle.make} ${model} (${vehicle.plate}) ^#5e81acto ^#ffffff${target.get("name")}^#5e81a.`);

  return true;
}

async function adminViewVehicles(source: number, args: { playerId: number }): Promise<boolean> {
  const player = GetPlayer(source);

  if (!player?.charId) return false;

  const playerId: number = args.playerId;
  const target = GetPlayer(playerId);
  if (!target?.charId) {
    sendChatMessage(source, `^#d73232ERROR ^#ffffffNo player found with id ${playerId}.`);
    return false;
  }

  const vehicles = await db.getOwnedVehicles(target.charId);
  if (vehicles.length === 0) {
    sendChatMessage(source, `^#d73232ERROR ^#ffffffNo vehicles found for player with id ${playerId}.`);
    return false;
  }

  sendChatMessage(source, `^#5e81ac--------- ^#ffffff${target.get("name")} (${playerId}) Owned Vehicles ^#5e81ac---------`);
  sendChatMessage(source, vehicles.map((vehicle: { id: number; plate: string; model: string; stored: string | null }): string => `ID: ^#5e81ac${vehicle.id} ^#ffffff| Plate: ^#5e81ac${vehicle.plate} ^#ffffff| Model: ^#5e81ac${vehicle.model} ^#ffffff| Status: ^#5e81ac${vehicle.stored ?? "N/A"}^#ffffff --- `).join("\n"));

  await sendLog(`${player.get("name")} (${source}) just used '/playervehicles' on ${target.get("name")} (${target.source}).`);

  return true;
}

addCommand("savevehicles", async (source: number) => {
  const player = GetPlayer(source);

  if (!player?.charId) return;

  try {
    sendChatMessage(source, `^#5e81acSaving all vehicles...`);
    await Cfx.Delay(500);
    Ox.SaveAllVehicles();
    sendChatMessage(source, `^#c78946Successfully saved all vehicles!`);
  } catch (error) {
    console.error("/savevehicles:", error)
    sendChatMessage(source, `^#d73232Failed to save all vehicles!`);
  }
}, {
  restricted: "group.admin",
});

addCommand(["list", "vl"], listVehicles, {
  restricted: false,
});

addCommand(["park", "vp"], parkVehicle, {
  restricted: false,
});

addCommand(["get", "vg"], getVehicle, {
  params: [
    {
      name: "vehicleId",
      paramType: "number",
      optional: false,
    },
  ],
  restricted: false,
});

addCommand(["impound", "rv"], returnVehicle, {
  params: [
    {
      name: "vehicleId",
      paramType: "number",
      optional: false,
    },
  ],
  restricted: false,
});

addCommand(["adeletevehicle", "delveh"], adminDeleteVehicle, {
  params: [
    {
      name: "plate",
      paramType: "string",
      optional: false,
    },
  ],
  restricted: restrictedGroup,
});

addCommand(["admincar", "acar"], adminSetVehicle, {
  params: [
    {
      name: "model",
      paramType: "string",
      optional: false,
    },
  ],
  restricted: restrictedGroup,
});

addCommand(["addvehicle"], adminGiveVehicle, {
  params: [
    {
      name: "playerId",
      paramType: "number",
      optional: false,
    },
    {
      name: "model",
      paramType: "string",
      optional: false,
    },
  ],
  restricted: restrictedGroup,
});

addCommand(["playervehicles"], adminViewVehicles, {
  params: [
    {
      name: "playerId",
      paramType: "number",
      optional: false,
    },
  ],
  restricted: restrictedGroup,
});

on("onResourceStop", async (resourceName: string): Promise<void> => {
  if (resourceName !== "fivem-parking") return;

  try {
    console.log(`\x1b[33m[${cache.resource}] Saving all vehicles...\x1b[0m`);
    Ox.SaveAllVehicles();
    console.log(`\x1b[32m[${cache.resource}] Successfully saved all vehicles.\x1b[0m`);
  } catch (error) {
    console.error(`\x1b[31m[${cache.resource}] Failed to save vehicles: ${error}\x1b[0m`);
  }
});
