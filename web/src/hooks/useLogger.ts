import { useEffect } from 'react';

export function useLogger(componentName: string, props: any[]): null {
  useEffect((): (() => void) => {
    console.log(`${componentName} mounted`, ...props);
    return (): void => console.log(`${componentName} unmounted`);
  }, []);

  return null;
}
