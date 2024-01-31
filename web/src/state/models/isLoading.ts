import { createModel } from '@rematch/core';
import { RootModel } from '.';

export const isLoading = createModel<RootModel>()({
    state: false as boolean,
    reducers: {
        setState(state: boolean, payload: boolean): boolean {
            return (state = payload);
        },
    },
});
