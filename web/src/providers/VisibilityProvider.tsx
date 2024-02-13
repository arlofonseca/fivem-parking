import React, { Context, ReactNode, createContext, useContext, useEffect, useState } from 'react';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { fetchNui } from '../utils/fetchNui';
import { isEnvBrowser } from '../utils/misc';

const VisibilityCtx: React.Context<VisibilityProviderValue | null> = createContext<VisibilityProviderValue | null>(
  null
);

interface VisibilityProviderValue {
  setVisible: (visible: boolean) => void;
  visible: boolean;
}

export const VisibilityProvider: React.FC<{ children: React.ReactNode }> = ({ children }: { children: ReactNode }) => {
  const [visible, setVisible] = useState(false);

  useNuiEvent<boolean>('setVisible', setVisible);

  useEffect((): (() => void) | undefined => {
    if (!visible) return;

    const keyHandler: (e: KeyboardEvent) => void = (e: KeyboardEvent): void => {
      if (['Backspace', 'Escape'].includes(e.code)) {
        if (!isEnvBrowser()) fetchNui('bgarage:nui:hideFrame');
        else setVisible(!visible);
      }
    };

    window.addEventListener('keydown', keyHandler);

    return (): void => window.removeEventListener('keydown', keyHandler);
  }, [visible]);

  return (
    <VisibilityCtx.Provider
      value={{
        visible,
        setVisible,
      }}
    >
      <div style={{ visibility: visible ? 'visible' : 'hidden', height: '100%' }}>{children}</div>
    </VisibilityCtx.Provider>
  );
};

export const useVisibility: () => VisibilityProviderValue = (): VisibilityProviderValue =>
  useContext<VisibilityProviderValue>(VisibilityCtx as Context<VisibilityProviderValue>);
