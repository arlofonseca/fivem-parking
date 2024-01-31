import { MutableRefObject, useEffect, useRef } from 'react';
import { noop } from '../utils/misc';

interface Data<T = unknown> {
    action: string;
    data: T;
}

type Handler<T> = (data: T) => void;

/**
 * A hook that manage events listeners for receiving data from the client scripts
 * @param action The specific `action` that should be listened for.
 * @param handler The callback function that will handle data relayed by this hook
 *
 * @example
 * useNuiEvent<{visibility: true, wasVisible: 'something'}>('setVisible', (data) => {
 *   // whatever logic you want
 * })
 *
 **/
export const useNuiEvent: <T = any>(action: string, handler: (data: T) => void) => void = <T = any>(
    action: string,
    handler: (data: T) => void
): void => {
    const cache: MutableRefObject<Handler<T>> = useRef(noop);

    useEffect((): void => {
        cache.current = handler;
    }, [handler]);

    useEffect((): (() => void) => {
        const eventListener: (event: MessageEvent<Data<T>>) => void = (event: MessageEvent<Data<T>>) => {
            const { action: action, data } = event.data;

            if (cache.current) {
                if (action === action) {
                    cache.current(data);
                }
            }
        };

        window.addEventListener('message', eventListener);
        return (): void => window.removeEventListener('message', eventListener);
    }, [action]);
};
