import { createModel } from '@rematch/core';
import { RootModel } from '.';
import { store } from '..';
import { fetchNui } from '../../utils/fetchNui';
import { VehicleData } from './vehicles';

interface SelectedVehicle extends VehicleData {
    model: string;
}

export const vehicleData = createModel<RootModel>()({
    state: {
        name: '',
        make: '',
        class: 0,
    } as SelectedVehicle,

    reducers: {
        setState(state, payload: SelectedVehicle) {
            return (state = payload);
        },
    },
    effects: (dispatch) => ({
        getVehicleData(payload: string) {
            try {
                const vehicle = { ...store.getState().vehicles[payload], model: payload };
                fetchNui('clickVehicle', vehicle);
                dispatch.vehicleData.setState(vehicle);
            } catch {
                const vehicleData: SelectedVehicle = {
                    make: 'Dinka',
                    name: 'Blista',
                    model: 'blista',
                    type: 'automobile',
                    class: 0,
                };
                dispatch.vehicleData.setState(vehicleData);
            }
        },
        getSingleVehicle(payload: string) {
            return store.getState().vehicles[payload];
        },
    }),
});
