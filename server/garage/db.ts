import { Ox } from "@overextended/ox_core";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function filterVehicle(filter: object) {
  try {
    return await prisma.vehicles.findFirst({ where: filter, select: { id: true } });
  } catch (error) {
    console.error("filterVehicle:", error);
  }
}

export async function getVehicleById(id: number) {
  return filterVehicle({ id }) ?? false;
}

export async function getVehicleOwner(id: number, owner: number) {
  return filterVehicle({ id, owner }) ?? false;
}

export async function getVehicleStatus(id: number, status: string) {
  return filterVehicle({ id, stored: status });
}

export async function getVehiclePlate(plate: string) {
  return filterVehicle({ plate });
}

export async function getOwnedVehicles(owner: number) {
  try {
    return await prisma.vehicles.findMany({ where: { owner }, select: { id: true, plate: true, owner: true, model: true, stored: true } });
  } catch (error) {
    console.error("getOwnedVehicles:", error);
    return [];
  }
}

export async function setVehicleStatus(id: number, status: string) {
  try {
    return await prisma.vehicles.update({ where: { id }, data: { stored: status } });
  } catch (error) {
    console.error("setVehicleStatus:", error);
  }
}

export async function deleteVehicle(plate: string) {
  try {
    return await prisma.vehicles.delete({ where: { plate } });
  } catch (error) {
    console.error("deleteVehicle:", error);
  }
}

export async function saveAllVehicles() {
  try {
    return Ox.SaveAllVehicles();
  } catch (error) {
    console.error("saveAllVehicles:", error);
  }
}