import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function getOwnedVehicles(owner: number) {
  try {
    return await prisma.vehicles.findMany({ where: { owner }, select: { id: true, plate: true, owner: true, model: true, stored: true } });
  } catch (error) {
    console.error('getOwnedVehicles:', error);
    return [];
  }
}

export async function getVehicleStatus(vehicleId: number, status: string) {
  try {
    return await prisma.vehicles.findFirst({ where: { id: vehicleId, stored: status }, select: { id: true } });
  } catch (error) {
    console.error('getVehicleStatus:', error);
  }
}

export async function getVehicleOwner(vehicleId: number, owner: number) {
  try {
    return await prisma.vehicles.findFirst({ where: { id: vehicleId, owner: owner }, select: { id: true } });
  } catch (error) {
    console.error('getVehicleOwner:', error);
    return false;
  }
}

export async function getVehiclePlate(plate: string) {
  try {
    return await prisma.vehicles.findFirst({ where: { plate: plate }, select: { id: true } });
  } catch (error) {
    console.error('getVehiclePlate:', error);
  }
}

export async function setVehicleStatus(vehicleId: number, status: string) {
  try {
    return await prisma.vehicles.update({ where: { id: vehicleId }, data: { stored: status } });
  } catch (error) {
    console.error('setVehicleStatus:', error);
  }
}

export async function deleteVehicle(plate: string) {
  try {
    return await prisma.vehicles.delete({ where: { plate: plate } });
  } catch (error) {
    console.error('deleteVehicle:', error);
  }
}
