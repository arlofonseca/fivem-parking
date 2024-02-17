import React, { Context, ReactNode, createContext, useContext, useEffect, useState } from 'react';
import { useKeyPress } from '../hooks/useKeyPress';
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

/**
 * 'VisibilityProvider' component for managing visibility state and providing it through context.
 *
 * @param children - React children elements to be wrapped by the provider.
 * @returns JSX element representing the VisibilityProvider.
 */
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

    useKeyPress('keydown');

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

/**
 * 'useVisibility' hook for accessing the visibility state from the context.
 *
 * @returns 'VisibilityProviderValue' containing functions and properties related to visibility.
 */
export const useVisibility: () => VisibilityProviderValue = (): VisibilityProviderValue =>
  useContext<VisibilityProviderValue>(VisibilityCtx as Context<VisibilityProviderValue>);
