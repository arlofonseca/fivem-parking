// https://github.com/overextended/ox_vehicledealer/blob/main/web/src/hooks/useDebounce.ts
import { useEffect, useState } from 'react';

/**
 * A hook for debouncing a value.
 *
 * @param value - The value to be debounced.
 * @param delay - The debounce delay in milliseconds (default is 500ms).
 * @returns The debounced value.
 */
export function useDebounce<T>(value: T, delay?: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect((): (() => void) => {
    const timer = setTimeout((): any => setDebouncedValue(value), delay || 500);

    return (): void => {
      clearTimeout(timer);
    };
  }, [value, delay]);

  return debouncedValue;
}
