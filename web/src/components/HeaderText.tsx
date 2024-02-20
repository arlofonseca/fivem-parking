import clsx from 'clsx';
import { LucideIcon } from 'lucide-react';
import React from 'react';

interface Props {
  Icon?: LucideIcon;
  size?: number;
  className?: string;
  children?: React.ReactNode;
  iconClassName?: string;
  onClick?: () => void;
}

const HeaderText: React.FC<Props> = ({ Icon, size, className, children, iconClassName, onClick }: Props) => {
  return (
    <>
      <div
        className={clsx(
          'flex items-center gap-2 bg-secondary px-2 py-[7px] m-1 rounded-[2px] from-[#2f323d] via-[#3d3f49] to-[#292c37] text-[#2980b9] font-bold',
          className
        )}
        onClick={onClick}
      >
        {Icon && <Icon size={!size ? 15 : size} className={iconClassName} />}
        {children}
      </div>
    </>
  );
};

export default HeaderText;
