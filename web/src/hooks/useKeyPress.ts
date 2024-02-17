// https://github.com/Byte-Labs-Project/bl_customs/blob/main/web/src/hooks/useKeyPress.ts
import React from 'react';

/**
 * A hook that tracks whether a specific key is currently pressed.
 *
 * @param targetKey - The key to be tracked (e.g., 'Enter', 'Escape').
 * @returns A boolean indicating whether the specified key is currently pressed.
 */
export const useKeyPress = (targetKey: KeyboardEvent['key']) => {
  const [keyPressed, setKeyPressed] = React.useState(false);

  const downHandler = React.useCallback(
    ({ key }: KeyboardEvent) => {
      if (key === targetKey) {
        setKeyPressed(true);
      }
    },
    [targetKey]
  );

  const upHandler = React.useCallback(
    ({ key }: KeyboardEvent) => {
      if (key === targetKey) {
        setKeyPressed(false);
      }
    },
    [targetKey]
  );

  React.useEffect(() => {
    window.addEventListener('keydown', downHandler);
    window.addEventListener('keyup', upHandler);

    return () => {
      window.removeEventListener('keydown', downHandler);
      window.removeEventListener('keyup', upHandler);
    };
  }, [downHandler, upHandler]);

  return keyPressed;
};

export default useKeyPress;
