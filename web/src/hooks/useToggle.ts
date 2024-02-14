// https://github.com/mantinedev/mantine/blob/master/packages/%40mantine/hooks/src/use-toggle/use-toggle.ts
import { useReducer } from 'react';

export function useToggle<T = boolean>(
  options: readonly T[] = [false, true] as any
): readonly [T, (value?: React.SetStateAction<T>) => void] {
  const [[option], toggle] = useReducer((state: T[], action: React.SetStateAction<T>): T[] => {
    const value: T = action instanceof Function ? action(state[0]) : action;
    const index: number = Math.abs(state.indexOf(value));

    return state.slice(index).concat(state.slice(0, index));
  }, options as T[]);

  return [option, toggle as (value?: React.SetStateAction<T>) => void] as const;
}
