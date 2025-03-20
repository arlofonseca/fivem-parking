import * as Cfx from "@nativewrappers/fivem";
import { GetPlayer, SpawnVehicle } from "@overextended/ox_core/server";
import { cache } from "@overextended/ox_lib";
import { addCommand, onClientCallback } from "@overextended/ox_lib/server";
import * as config from "../../config.json";
import { Garage } from "./class";
import * as db from "./db";
import { hasItem, removeItem, sendChatMessage, sendLog } from "./utils";

const restrictedGroup = `group.${config.ace_group}`;

on("onResourceStop", async (resource: string): Promise<void> => {
  if (resource !== cache.resource) return;

  try {
    console.log(`\x1b[33m[${cache.resource}] Saving all vehicles...\x1b[0m`);
    await db.saveAllVehicles();
    console.log(`\x1b[32m[${cache.resource}] Successfully saved all vehicles.\x1b[0m`);
  } catch (error) {
    console.error(`\x1b[31m[${cache.resource}] Failed to save vehicles: ${error}\x1b[0m`);
  }
});

onClientCallback("fivem-parking:server:spawnVehicle", async (source: number, vehicleId: number) => {
  const player = GetPlayer(source);

  if (!player?.charId) return false;

  const vehicle = await db.getVehicleById(vehicleId);
  if (!vehicle) {
    sendChatMessage(source, "^#d73232Something went wrong.");
    return false;
  }

  const owner = await db.getVehicleOwner(vehicleId, player.charId);
  if (!owner) {
    sendChatMessage(source, "^#d73232You cannot spawn a vehicle you do not own!");
    return false;
  }

  if (!hasItem(source, config.money_item, config.retrieval_cost)) {
    sendChatMessage(source, `^#d73232You need ^#ffffff$${config.retrieval_cost} ^#d73232to retrieve your vehicle.`);
    return false;
  }

  const money = await removeItem(source, config.money_item, config.retrieval_cost);
  if (!money) return false;

  await Cfx.Delay(100);

  const success = await SpawnVehicle(vehicleId, player.getCoords());
  if (!success) {
    sendChatMessage(source, "^#d73232Failed to spawn the vehicle.");
    return;
  }

  await db.setVehicleStatus(vehicleId, "outside");
  sendChatMessage(source, `^#5e81acYou paid ^#ffffff$${config.retrieval_cost} ^#5e81acto retrieve your vehicle.`);
  await sendLog(`[VEHICLE] ${player.get("name")} (${source}) just spawned their vehicle #${vehicleId}! Position: ${player.getCoords()[0]} ${player.getCoords()[1]} ${player.getCoords()[2]} - dimension: ${GetPlayerRoutingBucket(String(source))}.`);
});

addCommand(["list", "vg"], Garage.prototype.listVehicles, {
  restricted: false,
});

addCommand(["park", "vp"], Garage.prototype.parkVehicle, {
  restricted: false,
});

addCommand(["impound", "rv"], Garage.prototype.returnVehicle, {
  params: [
    {
      name: "vehicleId",
      paramType: "number",
      optional: false,
    },
  ],
  restricted: false,
});

addCommand(["addvehicle"], Garage.prototype.adminGiveVehicle, {
  params: [
    {
      name: "model",
      paramType: "string",
      optional: false,
    },
    {
      name: "playerId",
      paramType: "number",
      optional: false,
    },
  ],
  restricted: restrictedGroup,
});

addCommand(["adeletevehicle", "delveh"], Garage.prototype.adminDeleteVehicle, {
  params: [
    {
      name: "plate",
      paramType: "string",
      optional: false,
    },
  ],
  restricted: restrictedGroup,
});

addCommand(["admincar", "acar"], Garage.prototype.adminSetVehicle, {
  params: [
    {
      name: "model",
      paramType: "string",
      optional: false,
    },
  ],
  restricted: restrictedGroup,
});

addCommand(["aviewvehicles", "viewveh"], Garage.prototype.adminViewVehicles, {
  params: [
    {
      name: "playerId",
      paramType: "number",
      optional: false,
    },
  ],
  restricted: restrictedGroup,
});