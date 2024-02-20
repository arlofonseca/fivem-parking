import clsx from 'clsx';
import React from 'react';

interface Props {
  Icon?: any;
  size?: number;
  text?: string;
  className?: string;
  children?: React.ReactNode;
  iconClassName?: string;
  onClick?: () => void;
  disabled?: boolean;
}

const Button: React.FC<Props> = ({ Icon, size, className, children, iconClassName, onClick, disabled }: Props) => {
  return (
    <>
      <button
        onClick={onClick}
        disabled={disabled}
        className={clsx(
          'flex gap-1 items-center rounded-[2px] font-inter font-semibold text-xs px-2 py-1 bg-gradient-to-r border-[2px] border-[#272e3c] ffrom-[#2f323d] via-[#3d3f49] to-[#292c37] text-[#2980b9]',
          className,
          disabled && 'opacity-50'
        )}
      >
        {Icon && <Icon size={!size ? 15 : size} className={iconClassName} />}
        {children}
      </button>
    </>
  );
};

export default Button;
