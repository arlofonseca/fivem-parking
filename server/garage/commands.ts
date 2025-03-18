import * as Cfx from "@nativewrappers/fivem/server";
import { GetPlayer } from "@overextended/ox_core/server";
import { addCommand } from "@overextended/ox_lib/server";
import * as config from "../../config.json";
import { Garage } from "./class";
import * as db from "./db";
import { sendChatMessage } from "./utils";

const restrictedGroup = `group.${config.ace_group}`;

addCommand(["list", "vl"], Garage.prototype.listVehicles, {
  restricted: false,
});

addCommand(["park", "vp"], Garage.prototype.parkVehicle, {
  restricted: false,
});

addCommand(["get", "vg"], Garage.prototype.getVehicle, {
  params: [
    {
      name: "vehicleId",
      paramType: "number",
      optional: false,
    },
  ],
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

addCommand(["addvehicle"], Garage.prototype.adminGiveVehicle, {
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

addCommand(["playervehicles"], Garage.prototype.adminViewVehicles, {
  params: [
    {
      name: "playerId",
      paramType: "number",
      optional: false,
    },
  ],
  restricted: restrictedGroup,
});

addCommand("savevehicles", async (source: number) => {
  const player = GetPlayer(source);

  if (!player?.charId) return;

  try {
    sendChatMessage(source, "^#5e81acSaving all vehicles...");
    await Cfx.Delay(500);
    await db.saveAllVehicles()
    sendChatMessage(source, "^#c78946Successfully saved all vehicles!");
  } catch (error) {
    console.error("/savevehicles:", error);
    sendChatMessage(source, "^#d73232Failed to save all vehicles!");
  }
}, {
  restricted: restrictedGroup,
});