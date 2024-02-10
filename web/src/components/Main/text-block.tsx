/* eslint-disable @typescript-eslint/no-explicit-any */
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
}

const Button: React.FC<Props> = ({ Icon, size, className, children, svg, iconClassName }) => {
    return (
        <>
            <p
                className={clsx(
                    'flex gap-1 font-inter font-semibold text-xs px-2 py-1 bg-[#25262b] border-[2px] border-[#272e3c] from-[#202433] to-[#313745]',
                    className
                )}
            >
                {Icon && <Icon size={!size ? 16 : size} className={iconClassName} />}
                {svg && <img src={svg} alt="" className="w-5" />}
                {children}
            </p>
        </>
    );
};

export default Button;
