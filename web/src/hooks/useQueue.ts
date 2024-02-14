// https://github.com/mantinedev/mantine/blob/master/packages/%40mantine/hooks/src/use-queue/use-queue.ts
import { useState } from 'react';

export function useQueue<T>({ initialValues = [], limit }: { initialValues?: T[]; limit: number }) {
  const [{ state, queue }, setState] = useState({
    state: initialValues.slice(0, limit),
    queue: initialValues.slice(limit),
  });

  const add: (...items: T[]) => void = (...items: T[]): void =>
    setState((current) => {
      const results = [...current.state, ...current.queue, ...items];

      return {
        state: results.slice(0, limit),
        queue: results.slice(limit),
      };
    });

  const update: (fn: (state: T[]) => T[]) => void = (fn: (state: T[]) => T[]): void =>
    setState((current: { state: T[]; queue: T[] }) => {
      const results: T[] = fn([...current.state, ...current.queue]);

      return {
        state: results.slice(0, limit),
        queue: results.slice(limit),
      };
    });

  const cleanQueue: () => void = (): void =>
    setState((current: { state: T[]; queue: T[] }) => ({ state: current.state, queue: [] }));

  return {
    state,
    queue,
    add,
    update,
    cleanQueue,
  };
}
