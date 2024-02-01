import { create } from 'zustand';

export type Action = {
    saveData: (data: any) => void;
};

const StoreState = {
    plate: '',
    model: '',
    status: '',
    location: '',
    fuel: '',
};

export const vehicleStore: any = create<any & Action>(
    (set: (arg0: { plate: any; model: any; status: any; location: any; fuel: any }) => void) => ({
        ...StoreState,
        saveData: (data: any): void => {
            set({
                plate: data.plate,
                model: data.model,
                status: data.status,
                location: data.location,
                fuel: data.fuel,
            });
        },
    })
);
