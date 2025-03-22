import { Ox } from '@overextended/ox_core';
import { PrismaClient } from '@prisma/client';

const db = new (class Database {
  prisma: PrismaClient;

  constructor() {
    this.prisma = new PrismaClient();
  }

  private async filterVehicle(filter: object) {
    try {
      return await this.prisma.vehicles.findFirst({ where: filter, select: { id: true } });
    } catch (error) {
      console.error('filterVehicle:', error);
    }
  }

  async getVehicleById(id: number) {
    try {
      return (await this.filterVehicle({ id })) ?? false;
    } catch (error) {
      console.error('getVehicleById:', error);
      return false;
    }
  }

  async getVehicleOwner(id: number, owner: number) {
    try {
      return (await this.filterVehicle({ id, owner })) ?? false;
    } catch (error) {
      console.error('getVehicleOwner:', error);
      return false;
    }
  }

  async getVehicleStatus(id: number, status: string) {
    try {
      return await this.filterVehicle({ id, stored: status });
    } catch (error) {
      console.error('getVehicleStatus:', error);
      return null;
    }
  }

  async getVehiclePlate(plate: string) {
    try {
      return await this.filterVehicle({ plate });
    } catch (error) {
      console.error('getVehiclePlate:', error);
      return null;
    }
  }

  async getOwnedVehicles(owner: number) {
    try {
      return await this.prisma.vehicles.findMany({
        where: { owner },
        select: { id: true, plate: true, owner: true, model: true, stored: true },
      });
    } catch (error) {
      console.error('getOwnedVehicles:', error);
      return [];
    }
  }

  async setVehicleStatus(id: number, status: string) {
    try {
      return await this.prisma.vehicles.update({ where: { id }, data: { stored: status } });
    } catch (error) {
      console.error('setVehicleStatus:', error);
    }
  }

  async deleteVehicle(plate: string) {
    try {
      return await this.prisma.vehicles.delete({ where: { plate } });
    } catch (error) {
      console.error('deleteVehicle:', error);
    }
  }
})();

export default db;
