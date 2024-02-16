import { Menu, ScrollArea } from '@mantine/core';
import clsx from 'clsx';
import { KeySquare, MapPinned } from 'lucide-react';
import React, { useContext, useState } from 'react';
import { Vehicle } from '../@types/Vehicle';
import { AppContext, AppContextType } from '../App';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { locales } from '../store/Locales';
import { fetchNui } from '../utils/fetchNui';
import ConfirmModal from './confirm-modal';
import VehicleInfo from './vehicle-info';

interface Props {
  className?: string;
  vehicles: Vehicle[];
}

const VehicleContainer: React.FC<Props> = ({ className, vehicles }: Props) => {
  const [confirmModalState, setConfirModalState] = useState(false);
  const [selectedVehicle, setSelectedVehicle] = useState<Vehicle | undefined>(undefined);
  const [_price, setPrice] = useState(500);
  const { options, setOptions, impoundOpen } = useContext(AppContext) as AppContextType;

  const handleConfirmModal: () => void = (): void => {
    setConfirModalState(false);
    if (impoundOpen) {
      fetchNui('bgarage:nui:retrieveFromImpound', selectedVehicle);
    } else {
      fetchNui('bgarage:nui:retrieveFromGarage', selectedVehicle);
    }

    setSelectedVehicle(undefined);
    fetchNui('bgarage:nui:hideFrame');
  };

  useNuiEvent('bgarage:nui:setImpoundPrice', (price: number): void => {
    setPrice(price);
  });

  return (
    <>
      <ConfirmModal
        opened={confirmModalState}
        title={locales.title}
        onClose={(): void => {
          setConfirModalState(false);
          setSelectedVehicle(undefined);
        }}
        onConfirm={handleConfirmModal}
      />

      <div className="flex flex-col gap-2 justify-center m-1">
        <ScrollArea h={620} className={className}>
          <div
            className={clsx(
              ' gap-2',
              options.usingGrid
                ? 'grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4'
                : 'flex flex-col -mt-1'
            )}
          >
            {Object.values(vehicles).map((vehicle: Vehicle, index: number) => {
              if (!vehicle) return;
              return (
                <>
                  <Menu
                    key={index}
                    transitionProps={{
                      transition: 'scale-y',
                    }}
                    classNames={{
                      dropdown:
                        '!bg-[#1a1b1e] p-1 rounded-[2px] from-[#2f323d] via-[#3d3f49] to-[#292c37] rounded-[2px]',
                      item: 'hover:bg-[#25262b] rounded-[2px] py-2 px-3 font-inter text-xs',
                    }}
                  >
                    <Menu.Target>
                      <button className="hover:-translate-y-[2px]  transition-all">
                        <VehicleInfo vehicleData={vehicle} />
                      </button>
                    </Menu.Target>
                    <Menu.Dropdown>
                      {vehicle.location !== 'outside' && (
                        <Menu.Item
                          disabled={vehicle.location === 'impound' && !impoundOpen}
                          onClick={(): void => {
                            setSelectedVehicle(vehicle);
                            setConfirModalState(true);
                          }}
                        >
                          <button className="flex gap-1 items-center">
                            <KeySquare size={16} strokeWidth={2.5} /> {locales.get_vehicle}
                          </button>
                        </Menu.Item>
                      )}

                      <Menu.Item
                        onClick={(): void => {
                          fetchNui('bgarage:nui:getLocation', vehicle);
                        }}
                      >
                        <button className="flex gap-1 items-center">
                          <MapPinned size={16} strokeWidth={2.5} /> {locales.locate_vehicle}
                        </button>
                      </Menu.Item>
                    </Menu.Dropdown>
                  </Menu>
                </>
              );
            })}
          </div>
        </ScrollArea>
      </div>
    </>
  );
};

export default VehicleContainer;
