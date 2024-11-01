import { oxmysql } from '@overextended/oxmysql';

export interface VehicleData {
  id: number;
  plate: string;
  owner: string;
  model: string;
  stored: string | null;
}

export async function fetchVehiclesTable(): Promise<VehicleData[]> {
  try {
    return await oxmysql.query<VehicleData[]>('SELECT * FROM vehicles');
  } catch (error) {
    console.error('fetchVehiclesTable:', error);
    return [];
  }
}

export async function getOwnedVehicles(owner: number): Promise<VehicleData[]> {
  try {
    const vehicles: VehicleData[] = await oxmysql.rawExecute<VehicleData[]>(
      'SELECT id, plate, owner, model, stored FROM vehicles WHERE owner = ?',
      [owner],
    );
    return vehicles || [];
  } catch (error) {
    console.error('getOwnedVehicles:', error);
    return [];
  }
}

export async function getVehicleById(vehicleId: number): Promise<VehicleData | null> {
  try {
    const result = await oxmysql.query<VehicleData[]>(
      'SELECT id, plate, owner, model, stored FROM vehicles WHERE id = ?',
      [vehicleId],
    );
    return result.length > 0 ? result[0] : null;
  } catch (error) {
    console.error('getVehicleById:', error);
    return null;
  }
}

export async function getVehicleStatus(vehicleId: number, status: string): Promise<boolean> {
  try {
    const result = await oxmysql.prepare<1>('SELECT 1 FROM vehicles WHERE id = ? AND stored = ?', [
      vehicleId,
      status,
    ]);
    return !!result;
  } catch (error) {
    console.error('getVehicleStatus:', error);
    return false;
  }
}

export async function getVehicleOwner(vehicleId: number, owner: number): Promise<boolean> {
  try {
    const result = await oxmysql.prepare<1>('SELECT 1 FROM vehicles WHERE id = ? AND owner = ?', [
      vehicleId,
      owner,
    ]);
    return result !== null;
  } catch (error) {
    console.error('getVehicleOwner:', error);
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

export async function setVehicleStatus(vehicleId: number, status: string): Promise<boolean | null> {
  try {
    const result = await oxmysql.rawExecute('UPDATE vehicles SET stored = ? WHERE id = ?', [
      status,
      vehicleId,
    ]);
    return result && result.affectedRows !== undefined && result.affectedRows > 0;
  } catch (error) {
    console.error('setVehicleStatus:', error);
    return false;
  }
}

export async function deleteVehicle(plate: string): Promise<boolean | 0 | null | undefined> {
  try {
    const result = await oxmysql.rawExecute('DELETE FROM vehicles WHERE plate = ?', [plate]);
    return result && result.affectedRows && result.affectedRows > 0;
  } catch (error) {
    console.error('deleteVehicle:', error);
    return false;
  }
}
