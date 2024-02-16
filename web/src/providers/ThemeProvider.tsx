import { createContext, useContext, useEffect, useState } from 'react';

type Theme = 'dark' | 'light' | 'system';

type Props = {
  children: React.ReactNode;
  defaultTheme?: Theme;
  storageKey?: string;
};

interface ThemeProviderValue {
  setTheme: (theme: Theme) => void;
  theme: Theme;
}

const currentState: ThemeProviderValue = {
  setTheme: (): null => null,
  theme: 'system',
};

const ThemeCtx: React.Context<ThemeProviderValue> = createContext<ThemeProviderValue>(currentState);

/**
 * 'ThemeProvider' component for managing the theme state and providing it through context.
 *
 * @param {React.ReactNode} children - React children elements to be wrapped by the provider.
 * @returns JSX element representing the ThemeProvider.
 */
export function ThemeProvider({ children, defaultTheme = 'system', storageKey = 'vite-ui-theme', ...props }: Props) {
  const [theme, setTheme] = useState<Theme>((): Theme => (localStorage.getItem(storageKey) as Theme) || defaultTheme);

  useEffect((): void => {
    const root: HTMLElement = window.document.documentElement;

    root.classList.remove('light', 'dark');

    if (theme === 'system') {
      const systemTheme: 'dark' | 'light' = window.matchMedia('(prefers-color-scheme: dark)').matches
        ? 'dark'
        : 'light';

      root.classList.add(systemTheme);
      return;
    }

    root.classList.add(theme);
  }, [theme]);

  const value = {
    theme,
    setTheme: (theme: Theme): void => {
      localStorage.setItem(storageKey, theme);
      setTheme(theme);
    },
  };

  return (
    <ThemeCtx.Provider {...props} value={value}>
      {children}
    </ThemeCtx.Provider>
  );
}

/**
 * 'useTheme' hook for accessing the theme state from the context.
 *
 * @returns {ThemeProviderValue} 'ThemeProviderValue' containing functions and properties related to the theme.
 */
export const useTheme: () => ThemeProviderValue = (): ThemeProviderValue => {
  const context: ThemeProviderValue = useContext(ThemeCtx);

  if (context === undefined) throw new Error('useTheme must be used within a ThemeProvider');

  return context;
};
