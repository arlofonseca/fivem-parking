import * as Cfx from "@nativewrappers/fivem/server";
import { GetPlayer, SpawnVehicle } from "@overextended/ox_core/server";
import { cache } from "@overextended/ox_lib";
import * as config from "../../config.json";
import * as db from "./db";
import { hasItem, removeItem, sendChatMessage, sendLog } from "./utils";

on("onResourceStop", async (resource: string): Promise<void> => {
  if (resource !== cache.resource) return;

  try {
    console.log(`\x1b[33m[${cache.resource}] Saving all vehicles...\x1b[0m`);
    await db.saveAllVehicles()
    console.log(`\x1b[32m[${cache.resource}] Successfully saved all vehicles.\x1b[0m`);
  } catch (error) {
    console.error(`\x1b[31m[${cache.resource}] Failed to save vehicles: ${error}\x1b[0m`);
  }
});

onNet("fivem-parking:server:spawnVehicle", async (source: number, vehicleId: number) => {
  const player = GetPlayer(source);

  if (!player?.charId) return false;

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