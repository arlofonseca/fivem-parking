import { createModel } from '@rematch/core';
import { RootModel } from '.';
import { isEnvBrowser } from '../../utils/misc';
import { fetchNui } from '../../utils/fetchNui';

export type VehicleType =
    | 'automobile'
    | 'heli'
    | 'bike'
    | 'plane'
    | 'trailer'
    | 'submarine'
    | 'quadbike'
    | 'blimp'
    | 'bicycle'
    | 'boat'
    | 'train';

export interface VehicleData {
    class: number;
    make: string;
    name: string;
    type: VehicleType;
}

interface Vehicles {
    [key: string]: VehicleData;
}

export const vehicleTypeToGroup = {
    automobile: 'land',
    bicycle: 'land',
    bike: 'land',
    quadbike: 'land',
    train: 'land',
    trailer: 'land',
    plane: 'air',
    heli: 'air',
    blimp: 'air',
    boat: 'sea',
    submarine: 'sea',
};

const gameVehicles: Vehicles = await (async () => {
    if (!isEnvBrowser()) {
        const resp = await fetch(``, {
            method: 'post',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
        });

        const vehicles = await resp.json();

        const blacklistedVehicles = Object.keys(await fetchNui<Record<string, true>>('getBlacklistedVehicles'));
        if (blacklistedVehicles.length <= 0) return vehicles;
        blacklistedVehicles.forEach((vehicle) => {
            delete vehicles[vehicle];
        });

        return vehicles;
    } else {
        return {
            blista: {
                class: 0,
                make: 'Dinka',
                name: 'Blista',
                type: 'automobile',
            },
            dominator: {
                class: 4,
                make: 'Vapid',
                name: 'Dominator',
                type: 'automobile',
            },
        } as Vehicles;
    }
})();

export const listVehicles = createModel<RootModel>()({
    state: {} as Vehicles,
    reducers: {
        setVehicles(state, payload: Vehicles) {
            return (state = payload);
        },
    },
});

export const vehicles = createModel<RootModel>()({
    state: gameVehicles,
});
