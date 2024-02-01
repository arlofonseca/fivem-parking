import { useEffect, useState } from 'react';

function useDebounce<T>(value: T, delay?: number): T {
    const [debouncedValue, setDebouncedValue] = useState<T>(value);

    useEffect((): (() => void) => {
        const timer: number = setTimeout((): void => setDebouncedValue(value), delay || 500);

        return (): void => {
            clearTimeout(timer);
        };
    }, [value, delay]);

    return debouncedValue;
}

export default useDebounce;
