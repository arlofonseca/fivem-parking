/* eslint-disable @typescript-eslint/no-explicit-any */
import clsx from 'clsx';
import { LucideIcon } from 'lucide-react';
import React from 'react';

interface Props {
    Icon?: any;
    size?: number;
    text?: string;
    className?: string;
    children?: React.ReactNode;
    iconClassName?: string;
    onClick?: () => void;
    svg?: any;
    disabled?: boolean;
}

const TextBlock: React.FC<Props> = ({ Icon, size, className, children, iconClassName, onClick, disabled, svg }) => {
    return (
        <>
            <button
                onClick={onClick}
                disabled={disabled}
                className={clsx(
                    'flex gap-1 items-center rounded-[2px] font-inter font-semibold text-xs px-2 py-1 bg-gradient-to-r border-[2px] border-[#272e3c] ffrom-[#2f323d] via-[#3d3f49] to-[#292c37] text-[#2fffd2]',
                    className,
                    disabled && 'opacity-50'
                )}
            >
                {Icon && <Icon size={!size ? 16 : size} className={iconClassName} />}
                {svg && <img src={svg} alt="" className="w-5" />}

                {children}
            </button>
        </>
    );
};

export default TextBlock;
