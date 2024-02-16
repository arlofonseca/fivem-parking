import { Moon, Sun } from 'lucide-react';
import React from 'react';
import { useTheme } from '../providers/ThemeProvider';
import { locales } from '../store/Locales';
import Button from './button';

const ThemeSwitcher: React.FC = () => {
  const { theme, setTheme } = useTheme();

  const handleThemeToggle: () => void = (): void => {
    setTheme(theme === 'dark' ? 'light' : 'dark');
  };

  return <Button Icon={theme === 'dark' ? Sun : Moon} text={locales.change_theme} onClick={handleThemeToggle} />;
};

export default ThemeSwitcher;
