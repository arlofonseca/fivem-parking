import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

export async function getVehicleStatus(vehicleId: number, status: string) {
  return await prisma.vehicles.findFirst({ where: { id: vehicleId, stored: status }, select: { id: true } });
}

export async function getVehicleOwner(vehicleId: number, owner: number) {
  return await prisma.vehicles.findFirst({ where: { id: vehicleId, owner: owner }, select: { id: true } });
}

export async function getVehiclePlate(plate: string) {
  return await prisma.vehicles.findFirst({ where: { plate: plate }, select: { id: true } });
}

export async function getOwnedVehicles(owner: number) {
  return await prisma.vehicles.findMany({ where: { owner }, select: { id: true, plate: true, owner: true, model: true, stored: true } });
}

export async function setVehicleStatus(vehicleId: number, status: string) {
  return await prisma.vehicles.update({ where: { id: vehicleId }, data: { stored: status } });
}

export async function deleteVehicle(plate: string) {
  return await prisma.vehicles.delete({ where: { plate: plate } });
}
