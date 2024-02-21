import { Moon, Sun } from 'lucide-react';
import React from 'react';
import { useTheme } from '../providers/ThemeProvider';
import { locales } from '../store/Locales';
import MenuButton from './Button';

const ThemeSwitcher: React.FC = () => {
  const { theme, setTheme } = useTheme();

  const handleThemeToggle: () => void = (): void => {
    setTheme(theme === 'dark' ? 'light' : 'dark');
  };

  return (
    <MenuButton
      size={18}
      className=" transition-all !px-2 !py-[7px] rounded-[2px] m-1"
      Icon={theme === 'dark' ? Sun : Moon}
      text={locales.change_theme}
      onClick={handleThemeToggle}
    />
  );
};

export default ThemeSwitcher;
