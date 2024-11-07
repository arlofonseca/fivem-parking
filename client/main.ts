import lib from "@overextended/ox_lib/client";
import { Data } from "../@types/Data";

onNet("fivem-parking:client:listVehicles", (vehicles: Data[]) => {
  const options = vehicles.map(vehicle => ({
    title: `${vehicle.model} (${vehicle.plate}) `,
    description: `${vehicle.stored}`,
    metadata: [
      { label: "ID", value: `#${vehicle.id}` }
    ]
  }));

  lib.registerContext({
    id: "vehicle_menu",
    title: "Your Vehicles",
    options: options,
  });

  lib.showContext("vehicle_menu");
});
