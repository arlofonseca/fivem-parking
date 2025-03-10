import lib from "@overextended/ox_lib/client";

onNet("fivem-parking:client:listVehicles", (vehicles: { id: number; plate: string; model: string; stored: string | null }[]) => {
  const options = vehicles.map(vehicle => ({
    title: `${vehicle.model} (${vehicle.plate})`,
    description: `${vehicle.stored}`,
    metadata: [{ label: "ID", value: `#${vehicle.id}` }]
  }));

  lib.registerContext({
    id: "vehicle_menu",
    title: "Your Vehicles",
    options: options,
  });

  lib.showContext("vehicle_menu");
});
