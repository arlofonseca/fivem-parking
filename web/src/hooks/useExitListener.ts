import { useEffect, useRef } from 'react';
import { fetchNui } from '../utils/fetchNui';
import { noop } from '../utils/misc';

type VisibleStatus = (bool: boolean) => void;

const keys: string[] = ['Escape'];

export const useExitListener: (visibleSetter: VisibleStatus, cb?: () => void) => void = (
    visibleSetter: VisibleStatus,
    cb?: () => void
): void => {
    const set: React.MutableRefObject<VisibleStatus> = useRef<VisibleStatus>(noop);

    useEffect((): void => {
        set.current = visibleSetter;
    }, [visibleSetter]);

    useEffect((): (() => void) => {
        const keyHandler: (e: KeyboardEvent) => void = (e: KeyboardEvent): void => {
            if (keys.includes(e.code)) {
                set.current(false);
                cb && cb();
                fetchNui('exit');
            }
        };

        window.addEventListener('keyup', keyHandler);
        return (): void => window.removeEventListener('keyup', keyHandler);
    }, []);
};
