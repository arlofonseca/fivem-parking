import { useSyncExternalStore } from 'react';

export type MantineStoreSubscriber<Value> = (value: Value) => void;
type SetStateCallback<Value> = (value: Value) => Value;

export interface MantineStore<Value> {
  getState: () => Value;
  setState: (value: Value | SetStateCallback<Value>) => void;
  updateState: (value: Value | SetStateCallback<Value>) => void;
  initialize: (value: Value) => void;
}

export type MantineStoreValue<Store extends MantineStore<any>> = ReturnType<Store['getState']>;

export function createStore<Value extends Record<string, any>>(initialState: Value): MantineStore<Value> {
  let state: Value = initialState;
  let initialized: boolean = false;
  const listeners = new Set<MantineStoreSubscriber<Value>>();

  return {
    getState(): Value {
      return state;
    },

    updateState(value: Value | SetStateCallback<Value>): void {
      state = typeof value === 'function' ? value(state) : value;
    },

    setState(value: Value | SetStateCallback<Value>): void {
      this.updateState(value);
      listeners.forEach((listener: MantineStoreSubscriber<Value>): void => listener(state));
    },

    initialize(value: Value): void {
      if (!initialized) {
        state = value;
        initialized = true;
      }
    },
  };
}

export function useStore<Store extends MantineStore<any>>(store: Store): ReturnType<Store['getState']> {
  return useSyncExternalStore<MantineStoreValue<Store>>(
    (): any => store.getState(),
    (): any => store.getState()
  );
}
