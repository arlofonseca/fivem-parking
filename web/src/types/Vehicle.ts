export interface Vehicle {
    owner: string | number;
    model: string | number;
    plate: string | number;
    modelName: string;
    props: { plate: string | number };
    location: 'outside' | 'parked' | 'impound';
    type: 'car' | 'van' | 'truck' | 'bicycle' | 'motorcycle' | 'boat' | 'helicopter' | 'plane' | 'train' | 'emergency';
    temporary: boolean;
}
