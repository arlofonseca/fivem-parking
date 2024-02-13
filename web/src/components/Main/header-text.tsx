import { Tooltip } from '@mantine/core';
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
  tooltipLabel: string;
}

const HeaderText: React.FC<Props> = ({ Icon, size, className, children, iconClassName, svg, tooltipLabel }: Props) => {
  return (
    <>
      <Tooltip
        label={tooltipLabel}
        classNames={{
          tooltip: '!bg-[#1a1b1e] font-inter text-white rounded-[2px]',
        }}
      >
        <div
          className={clsx(
            'flex items-center gap-2 bg-[#1a1b1e] px-3 py-2 mt-1 rounded-[2px] from-[#2f323d] via-[#3d3f49] to-[#292c37] text-[#2980b9] font-bold',
            className
          )}
        >
          {Icon && <Icon size={!size ? 16 : size} className={iconClassName} />}
          {svg && <img src={svg} alt="" className="w-5" />}
          {children}
        </div>
      </Tooltip>
    </>
  );
};

export default HeaderText;
