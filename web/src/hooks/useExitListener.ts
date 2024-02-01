import { useEffect, useRef } from 'react';
import { fetchNui } from '../utils/fetchNui';
import { noop } from '../utils/misc';

type VisibilityStatus = (bool: boolean) => void;

const KeyListener: string[] = ['Escape'];

export const useExitListener: (visibleSetter: VisibilityStatus, cb?: () => void) => void = (
    visibleSetter: VisibilityStatus,
    cb?: () => void
): void => {
    const setterRef: React.MutableRefObject<VisibilityStatus> = useRef<VisibilityStatus>(noop);

    useEffect((): void => {
        setterRef.current = visibleSetter;
    }, [visibleSetter]);

    useEffect((): (() => void) => {
        const keyHandler: (e: KeyboardEvent) => void = (e: KeyboardEvent): void => {
            if (KeyListener.includes(e.code)) {
                setterRef.current(false);
                cb && cb();
                fetchNui('exit');
            }
        };

        window.addEventListener('keyup', keyHandler);
        return (): void => window.removeEventListener('keyup', keyHandler);
    }, []);
};
