import { createModel } from '@rematch/core';
import { RootModel } from '.';

interface VisibilityState {
    browser: boolean;
    vehicle: boolean;
    admin: boolean;
}

export const visibility = createModel<RootModel>()({
    state: {
        browser: false,
        vehicle: false,
        admin: false,
    } as VisibilityState,
    reducers: {
        setBrowserVisible(state, payload: boolean) {
            return {
                ...state,
                browser: payload,
            };
        },
        setVehicleVisible(state, payload: boolean) {
            return {
                ...state,
                vehicle: payload,
            };
        },
        setAdminVisible(state, payload: boolean) {
            return {
                ...state,
                admin: payload,
            };
        },
    },
});
