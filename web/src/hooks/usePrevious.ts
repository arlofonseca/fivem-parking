import { useEffect, useRef } from 'react';

export const usePrevious: (value: unknown) => unknown = (value: unknown): unknown => {
    const ref: React.MutableRefObject<unknown> = useRef<unknown>();

    useEffect((): void => {
        ref.current = value;
    }, [value]);

    return ref.current;
};
