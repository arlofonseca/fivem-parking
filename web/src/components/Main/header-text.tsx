import { LucideIcon } from "lucide-react";
import clsx from "clsx";
import React from "react";

interface Props {
  Icon?: LucideIcon;
  size?: number;
  text?: string;
  className?: string;
  children?: React.ReactNode;
  iconClassName?: string;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  svg?: any;
}

const HeaderText: React.FC<Props> = ({
  Icon,
  size,
  className,
  children,
  iconClassName,
  svg,
}) => {
  return (
    <>
      <div
        className={clsx(
          "flex items-center gap-2 bg-[#1a1b1e] px-3 py-2 mt-1 rounded-[2px] from-[#2f323d] via-[#3d3f49] to-[#292c37] text-[#2fffd2] font-bold",
          className
        )}
      >
        {Icon && <Icon size={!size ? 16 : size} className={iconClassName} />}
        {svg && <img src={svg} alt="" className="w-5" />}
        {children}
      </div>
    </>
  );
};

export default HeaderText;
