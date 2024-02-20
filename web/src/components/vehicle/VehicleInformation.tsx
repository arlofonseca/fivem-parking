import clsx from 'clsx';
import { Ambulance, Bike, CarFront, MapPinned, ParkingSquare, ParkingSquareOff, Sailboat } from 'lucide-react';
import React from 'react';
import { FaCar, FaHelicopter, FaMotorcycle, FaPlane, FaShuttleVan, FaTrain, FaTruck } from 'react-icons/fa';
import { Vehicle } from '../../@types/Vehicle';
import TextBlock from '../TextBlock';

interface Props {
  className?: string;
  vehicleData: Vehicle;
}

const vehicleTypeIcons: Record<string, any> = {
  car: <FaCar size={14} strokeWidth={2.5} />,
  van: <FaShuttleVan size={14} strokeWidth={2.5} />,
  truck: <FaTruck size={14} strokeWidth={2.5} />,
  bicycle: <Bike size={14} strokeWidth={2.5} />,
  motorcycle: <FaMotorcycle size={14} strokeWidth={2.5} />,
  boat: <Sailboat size={14} strokeWidth={2.5} />,
  helicopter: <FaHelicopter size={14} strokeWidth={2.5} />,
  plane: <FaPlane size={14} strokeWidth={2.5} />,
  train: <FaTrain size={14} strokeWidth={2.5} />,
  emergency: <Ambulance size={14} strokeWidth={2.5} />,
};

const VehicleInformation: React.FC<Props> = ({ className, vehicleData }: Props) => {
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
              iconClassName={`${vehicleData.location === 'impound' ? 'text-red' : vehicleData.location === 'outside' ? 'text-orange' : 'text-white'}`}
              className="ml-auto text-[10px] !p-[3px]"
              size={14}
            ></TextBlock>
          </div>
        </div>
      </div>
    </>
  );
};

export default VehicleInformation;
