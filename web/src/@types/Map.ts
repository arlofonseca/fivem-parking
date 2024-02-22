export interface Map {
  plate: string;
  modelName: string;
  coords: number;
  location: 'outside' | 'parked' | 'impound';
}
