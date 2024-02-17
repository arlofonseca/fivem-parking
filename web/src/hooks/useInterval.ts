// https://github.com/mantinedev/mantine/blob/master/packages/%40mantine/hooks/src/use-interval/use-interval.ts
import { useEffect, useRef, useState } from 'react';

/**
 * A hook for managing intervals with start, stop, and toggle functionality.
 *
 * @param fn - The function to be executed at each interval.
 * @param interval - The interval duration in milliseconds.
 * @returns An object with functions to start, stop, toggle the interval, and a boolean indicating its current state.
 */
export function useInterval(
  fn: () => void,
  interval: number
): {
  start: () => void;
  stop: () => void;
  toggle: () => void;
  active: boolean;
} {
  const [active, setActive] = useState(false);
  const intervalRef: React.MutableRefObject<number | undefined> = useRef<number>();
  const fnRef: React.MutableRefObject<(() => void) | undefined> = useRef<() => void>();

  useEffect((): void => {
    fnRef.current = fn;
  }, [fn]);

  const start: () => void = (): void => {
    setActive((old: boolean): true => {
      if (!old && !intervalRef.current) {
        intervalRef.current = window.setInterval(fnRef.current!, interval);
      }
      return true;
    });
  };

  const stop: () => void = (): void => {
    setActive(false);
    window.clearInterval(intervalRef.current);
    intervalRef.current = undefined;
  };

  const toggle: () => void = (): void => {
    if (active) {
      stop();
    } else {
      start();
    }
  };

  return { start, stop, toggle, active };
}
