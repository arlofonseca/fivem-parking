import { MutableRefObject, useEffect, useRef } from 'react';
import { noop } from '../utils/misc';

interface NuiMessageData<T = unknown> {
    action: string;
    data: T;
}

type NuiHandlerSignature<T> = (data: T) => void;

export const useNuiEvent: <T = unknown>(action: string, handler: (data: T) => void) => void = <T = unknown>(
    action: string,
    handler: (data: T) => void
): void => {
    const savedHandler: MutableRefObject<NuiHandlerSignature<T>> = useRef(noop);

    useEffect((): void => {
        savedHandler.current = handler;
    }, [handler]);

    useEffect((): (() => void) => {
        const eventListener: (event: MessageEvent<NuiMessageData<T>>) => void = (
            event: MessageEvent<NuiMessageData<T>>
        ): void => {
            const { action: eventAction, data } = event.data;

            if (savedHandler.current) {
                if (eventAction === action) {
                    savedHandler.current(data);
                }
            }
        };

        window.addEventListener('message', eventListener);
        return (): void => window.removeEventListener('message', eventListener);
    }, [action]);
};
