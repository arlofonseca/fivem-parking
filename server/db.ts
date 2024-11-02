import { oxmysql } from '@overextended/oxmysql';
import { Data } from '../@types/Data';

export async function getOwnedVehicles(owner: number): Promise<Data[]> {
  try {
    return await oxmysql.rawExecute<Data[]>('SELECT id, plate, owner, model, stored FROM vehicles WHERE owner = ?', [owner]);
  } catch (error) {
    console.error('getOwnedVehicles:', error);
    return [];
  }
}

export async function getVehicleStatus(vehicleId: number, status: string): Promise<1 | undefined> {
  try {
    return await oxmysql.prepare<1>('SELECT 1 FROM vehicles WHERE id = ? AND stored = ?', [vehicleId, status]);
  } catch (error) {
    console.error('getVehicleStatus:', error);
  }
}

export async function getVehicleOwner(vehicleId: number, owner: number): Promise<false | 1[]> {
  try {
    return await oxmysql.prepare<1[]>('SELECT 1 FROM vehicles WHERE id = ? AND owner = ?', [vehicleId, owner]);
  } catch (error) {
    console.error('getVehicleOwner:', error);
    return false;
  }
}

export async function getVehiclePlate(plate: string): Promise<1 | undefined> {
  try {
    return await oxmysql.prepare<1>('SELECT 1 FROM vehicles WHERE plate = ?', [plate]);
  } catch (error) {
    console.error('getVehiclePlate:', error);
  }
}

export async function setVehicleStatus(vehicleId: number, status: string) {
  try {
    return await oxmysql.rawExecute('UPDATE vehicles SET stored = ? WHERE id = ?', [status, vehicleId]);
  } catch (error) {
    console.error('setVehicleStatus:', error);
  }
}

export async function deleteVehicle(plate: string) {
  try {
    return await oxmysql.rawExecute('DELETE FROM vehicles WHERE plate = ?', [plate]);
  } catch (error) {
    console.error('deleteVehicle:', error);
  }
}

export async function transferVehicle(vehicleId: number, owner: number) {
  try {
    return await oxmysql.rawExecute('UPDATE vehicles SET owner = ? WHERE id = ?', [owner, vehicleId]);
  } catch (error) {
    console.error('transferVehicle:', error);
  }
}
