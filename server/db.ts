import { oxmysql } from '@overextended/oxmysql';

export interface VehicleData {
  id: number;
  plate: string;
  owner: string;
  model: string;
  stored: string | null;
}

export async function fetchVehicles(owner: number): Promise<VehicleData[]> {
  try {
    const vehicles = await oxmysql.rawExecute<VehicleData[]>('SELECT id, plate, owner, model, stored FROM vehicles WHERE owner = ?', [owner]);
    return vehicles || [];
  } catch (error) {
    console.error('fetchVehicles:', error);
    return [];
  }
}

export async function storeVehicle(status: string, vehicleId: number, owner: number): Promise<boolean> {
  try {
    const result = await oxmysql.rawExecute('UPDATE vehicles SET stored = ? WHERE id = ? AND owner = ?', [status, vehicleId, owner]);
    if (result && result.affectedRows && result.affectedRows > 0) return true;
    return false;
  } catch (error) {
    console.error('storeVehicle:', error);
    return false;
  }
}

export async function getVehicleStatus(vehicleId: number, status: string): Promise<boolean> {
  try {
    const result = await oxmysql.prepare<1>('SELECT 1 FROM vehicles WHERE id = ? AND stored = ?', [vehicleId, status]);
    return !!result;
  } catch (error) {
    console.error('getVehicleStatus:', error);
    return false;
  }
}

export async function updateVehicleStatus(vehicleId: number, status: string) {
  try {
    const result = await oxmysql.rawExecute('UPDATE vehicles SET stored = ? WHERE id = ?', [status, vehicleId]);
    return result && result.affectedRows !== undefined && result.affectedRows > 0;
  } catch (error) {
    console.error('updateVehicleStatus:', error);
    return false;
  }
}

export async function getVehicleOwner(vehicleId: number, owner: number): Promise<boolean> {
  try {
    const result = await oxmysql.prepare<1>('SELECT 1 FROM vehicles WHERE id = ? AND owner = ?', [vehicleId, owner]);
    return result !== null;
  } catch (error) {
    console.error('isVehicleOwner:', error);
    return false;
  }
}

export async function deleteVehicle(plate: string) {
  try {
    const result = await oxmysql.rawExecute('DELETE FROM vehicles WHERE plate = ?', [plate]);
    return result && result.affectedRows && result.affectedRows > 0;
  } catch (error) {
    console.error('deleteVehicle:', error);
    return false;
  }
}

export async function getVehiclePlate(plate: string): Promise<boolean> {
  try {
    const result = await oxmysql.prepare<1>('SELECT 1 FROM vehicles WHERE plate = ?', [plate]);
    return result !== null;
  } catch (error) {
    console.error('getVehiclePlate:', error);
    return false;
  }
}
