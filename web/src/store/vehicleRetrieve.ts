import { create } from 'zustand';

export type Action = {
    fetchData: (data: any) => void;
};

const RetrieveState = {
    plate: '',
    model: '',
    status: '',
    location: '',
    fuel: '',
};

export const vehicleRetrieve: any = create<any & Action>(
    (set: (arg0: { plate: any; model: any; status: any; location: any; fuel: any }) => void) => ({
        ...RetrieveState,
        fetchData: (data: any): void => {
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
