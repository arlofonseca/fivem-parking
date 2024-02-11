export interface Management {
    owner: string | number;
    plate: string;
    location: 'outside' | 'parked' | 'impound';
}
