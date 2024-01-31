import { createModel } from '@rematch/core';
import { RootModel } from '.';
import { store } from '..';

export interface FilterState {
    types: string[];
}

type PayloadKey = 'model' | 'make' | 'name' | 'class' | 'types';
type PayloadValue = string | string[] | string | string | undefined;

export const vehicleClasses = [
    'Compacts',
    'Sedans',
    'SUVs',
    'Coupes',
    'Muscle',
    'Sports Classics',
    'Sports',
    'Super',
    'Motorcycles',
    'Off-road',
    'Industrial',
    'Utility',
    'Vans',
    'Cycles',
    'Boats',
    'Helicopters',
    'Planes',
    'Service',
    'Emergency',
    'Military',
    'Commercial',
    'Trains',
    'Open Wheel',
];

export const filters = createModel<RootModel>()({
    state: {
        types: [],
    } as FilterState,
    reducers: {
        setState(state, payload: { key: PayloadKey; value: PayloadValue }) {
            return {
                ...state,
                [payload.key]: payload.value,
            };
        },
        setTypes(state, payload: Record<string, true>) {
            return { ...state, types: Object.keys(payload) };
        },
    },
    effects: (dispatch) => ({
        filterVehicles(payload: FilterState) {
            const vehiclesArray = Object.entries(store.getState().vehicles);
            const filteredVehicles = vehiclesArray.filter((value) => {
                const vehicle = value[1];

                if (!payload.types.includes(vehicle.type)) return false;

                const vehicleModel = `${vehicle.make} ${vehicle.name}`;
                console.log(vehicleModel);

                return true;
            });

            dispatch.listVehicles.setVehicles(Object.fromEntries(filteredVehicles));
        },
    }),
});
