// https://github.com/overextended/ox_vehicledealer/blob/main/web/src/hooks/useDebounce.ts
import { useEffect, useState } from 'react';

export function useDebounce<T>(value: T, delay?: number): T {
    const [debouncedValue, setDebouncedValue] = useState<T>(value);

    useEffect((): (() => void) => {
        const timer: number = setTimeout((): any => setDebouncedValue(value), delay || 500);

        return (): void => {
            clearTimeout(timer);
        };
    }, [value, delay]);

    return debouncedValue;
}
