import * as Cfx from "@nativewrappers/fivem/server";
import { GetPlayer, Ox } from "@overextended/ox_core/server";
import { addCommand } from "@overextended/ox_lib/server";
import * as config from "../../config.json";
import { GarageManager } from "./class";
import { sendChatMessage } from "./utils";

const restrictedGroup = `group.${config.ace_group}`;

addCommand(["list", "vl"], GarageManager.prototype.listVehicles, {
  restricted: false,
});

addCommand(["park", "vp"], GarageManager.prototype.parkVehicle, {
  restricted: false,
});

addCommand(["get", "vg"], GarageManager.prototype.getVehicle, {
  params: [
    {
      name: "vehicleId",
      paramType: "number",
      optional: false,
    },
  ],
  restricted: false,
});

addCommand(["impound", "rv"], GarageManager.prototype.returnVehicle, {
  params: [
    {
      name: "vehicleId",
      paramType: "number",
      optional: false,
    },
  ],
  restricted: false,
});

addCommand(["adeletevehicle", "delveh"], GarageManager.prototype.adminDeleteVehicle, {
  params: [
    {
      name: "plate",
      paramType: "string",
      optional: false,
    },
  ],
  restricted: restrictedGroup,
});

addCommand(["admincar", "acar"], GarageManager.prototype.adminSetVehicle, {
  params: [
    {
      name: "model",
      paramType: "string",
      optional: false,
    },
  ],
  restricted: restrictedGroup,
});

addCommand(["addvehicle"], GarageManager.prototype.adminGiveVehicle, {
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

addCommand(["playervehicles"], GarageManager.prototype.adminViewVehicles, {
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
    Ox.SaveAllVehicles();
    sendChatMessage(source, "^#c78946Successfully saved all vehicles!");
  } catch (error) {
    console.error("/savevehicles:", error);
    sendChatMessage(source, "^#d73232Failed to save all vehicles!");
  }
}, {
  restricted: restrictedGroup,
});