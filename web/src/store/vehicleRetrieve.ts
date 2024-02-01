import { create } from 'zustand';

export type RetrieveAction = {
    fetchData: (data: any) => void;
};

const RetrieveState = {
    plate: '',
    model: '',
    status: '',
    location: '',
    fuel: '',
};

export const vehicleRetrieve: any = create<any & RetrieveAction>(
    (
        set: (arg0: { plate: any; model: any; status: any; location: any; fuel: any }) => void
    ): {
        fetchData: (data: any) => void;
        plate: string;
        model: string;
        status: string;
        location: string;
        fuel: string;
    } => ({
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
