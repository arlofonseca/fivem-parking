import clsx from 'clsx';
import {
    Bike,
    CarFront,
    MapPinned,
    ParkingSquare,
    ParkingSquareOff,
    Plane,
    Sailboat,
    TrainFront,
    Truck,
} from 'lucide-react';
import React from 'react';
import Helicopter from '../../icons/helicopter.svg';
import Motorcycle from '../../icons/motorcycle.svg';
import PoliceCar from '../../icons/policeCar.svg';
import Van from '../../icons/van.svg';
import { Vehicle } from '../../types/Vehicle';
import TextBlock from './text-block';

interface Props {
    className?: string;
    vehicleData: Vehicle;
}

const vehicleTypeIcons: Record<string, any> = {
    car: <CarFront size={16} strokeWidth={2.5} />,
    van: <img src={Van} alt="van" className="w-5" />,
    truck: <Truck size={16} strokeWidth={2.5} />,
    bicycle: <Bike size={16} strokeWidth={2.5} />,
    motorcycle: <img src={Motorcycle} alt="motorcycle" className="w-5" />,
    boat: <Sailboat size={16} strokeWidth={2.5} />,
    helicopter: <img src={Helicopter} alt="helicopter" className="w-5" />,
    plane: <Plane size={16} strokeWidth={2.5} className="w-5" />,
    train: <TrainFront size={16} strokeWidth={2.5} />,
    emergency: <img src={PoliceCar} alt="policeCar" className="w-5" />,
};

const VehicleInfo: React.FC<Props> = ({ className, vehicleData }: Props) => {
    const icon: any = vehicleTypeIcons[vehicleData.type];

    return (
        <>
            <div
                className={clsx(
                    'bg-[#1a1b1e] px-3 py-2 mt-1 rounded-[2px] from-[#2f323d] via-[#3d3f49] to-[#292c37]',
                    className
                )}
            >
                <div className="flex flex-col gap-2">
                    <p className="flex gap-1 items-center ml-1">
                        {!icon ? <CarFront size={16} strokeWidth={2.5} /> : <>{icon}</>}

                        <span className="font-inter text-sm truncate font-semibold">{vehicleData.modelName}</span>
                        <TextBlock className="ml-auto !p-[2px]" size={12}>
                            <span className="text-[10px] uppercase">{vehicleData.plate}</span>
                        </TextBlock>
                    </p>
                    <div className="flex gap-1 items-center">
                        <TextBlock Icon={MapPinned} className="text-[10px] !p-[3px] capitalize" size={14}>
                            {vehicleData.location}
                        </TextBlock>

                        <TextBlock
                            Icon={vehicleData.location === 'impound' ? ParkingSquareOff : ParkingSquare}
                            iconClassName={`${vehicleData.location !== 'parked' && 'text-red'}`}
                            className="ml-auto text-[10px] !p-[3px]"
                            size={14}
                        ></TextBlock>
                    </div>
                </div>
            </div>
        </>
    );
};

export default VehicleInfo;
