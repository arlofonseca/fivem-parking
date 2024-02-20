import clsx from 'clsx';
import { LucideIcon } from 'lucide-react';
import React from 'react';

interface Props {
  Icon?: LucideIcon;
  size?: number;
  className?: string;
  children?: React.ReactNode;
  iconClassName?: string;
}

const TextBlock: React.FC<Props> = ({ Icon, size, className, children, iconClassName }: Props) => {
  return (
    <>
      <p
        className={clsx(
          'flex gap-1 font-inter font-semibold text-xs px-2 py-1 bg-[#25262b] border-[2px] border-bordercolor from-[#202433] to-[#313745]',
          className
        )}
      >
        {Icon && <Icon size={!size ? 15 : size} className={iconClassName} />}
        {children}
      </p>
    </>
  );
};

export default TextBlock;
