import clsx from 'clsx';
import { LucideIcon } from 'lucide-react';
import React from 'react';

interface Props {
  Icon?: LucideIcon;
  size?: number;
  text?: string;
  className?: string;
  children?: React.ReactNode;
  svg?: any;
  iconClassName?: string;
  onClick?: () => void;
}

const HeaderText: React.FC<Props> = ({ Icon, size, className, children, iconClassName, svg, onClick }: Props) => {
  return (
    <>
      <div
        className={clsx(
          'flex items-center gap-2 bg-[#1a1b1e] px-2 py-[7px] m-1 rounded-[2px] from-[#2f323d] via-[#3d3f49] to-[#292c37] text-[#2980b9] font-bold',
          className
        )}
        onClick={onClick}
      >
        {Icon && <Icon size={!size ? 16 : size} className={iconClassName} />}
        {svg && <img src={svg} alt="" className="w-5" />}
        {children}
      </div>
    </>
  );
};

export default HeaderText;