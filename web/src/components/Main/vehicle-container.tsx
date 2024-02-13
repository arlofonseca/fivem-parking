import { Menu, ScrollArea } from '@mantine/core';
import clsx from 'clsx';
import { KeySquare, LayoutGrid, List, MapPinned } from 'lucide-react';
import React, { useContext, useState } from 'react';
import { Vehicle } from '../../types/Vehicle';
import { fetchNui } from '../../utils/fetchNui';
import { AppContext, AppContextType } from '../App';
import Button from './Button';
import ConfirmModal from './confirm-modal';
import VehicleInfo from './vehicle-info';

interface Props {
  className?: string;
  vehicles: Vehicle[];
  impoundOpen: boolean;
}

const VehicleContainer: React.FC<Props> = React.memo(({ className, vehicles, impoundOpen }: Props) => {
  const [confirmModalState, setConfirModalState] = useState(false);
  const [selectedVehicle, setSelectedVehicle] = useState<Vehicle | undefined>(undefined);

  const { options, setOptions } = useContext(AppContext) as AppContextType;

  const handleModalConfirm: () => void = (): void => {
    setConfirModalState(false);
    fetchNui('bgarage:nui:impound:retrieve', selectedVehicle);
    setSelectedVehicle(undefined);
  };

  const handleGridChange: (usingGrid: boolean) => void = (usingGrid: boolean): void => {
    setOptions({
      usingGrid: usingGrid,
    });

    fetchNui('bgarage:nui:saveSettings', {
      usingGrid: usingGrid,
    });
  };
  return (
    <>
      <ConfirmModal
        opened={confirmModalState}
        title="Are you sure?"
        onClose={(): void => {
          setConfirModalState(false);
          setSelectedVehicle(undefined);
        }}
        onConfirm={handleModalConfirm}
      />

      <div className="flex flex-col gap-2 justify-center">
        <div className="ml-auto mt-2 flex gap-2">
          <Button
            Icon={List}
            size={18}
            className={clsx('hover:-translate-y-[2px] transition-all', !options.usingGrid && 'border-blue')}
            onClick={(): void => {
              handleGridChange(false);
            }}
          />
          <Button
            Icon={LayoutGrid}
            size={18}
            className={clsx('hover:-translate-y-[2px] transition-all', options.usingGrid && 'border-blue')}
            onClick={(): void => {
              handleGridChange(true);
            }}
          />
        </div>
        <ScrollArea h={620} className={className}>
          <div
            className={clsx(
              ' gap-2',
              options.usingGrid
                ? 'grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4'
                : 'flex flex-col m-3 -mt-1'
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
                            if (impoundOpen) {
                              setSelectedVehicle(vehicle);
                              setConfirModalState(true);
                              return;
                            }

                            fetchNui('bgarage:nui:garage:retrieve', vehicle);

                            fetchNui('bgarage:nui:hideFrame');
                          }}
                        >
                          <button className="flex gap-1 items-center">
                            <KeySquare size={16} strokeWidth={2.5} /> Get Vehicle
                          </button>
                        </Menu.Item>
                      )}

                      <Menu.Item
                        onClick={(): void => {
                          fetchNui('bgarage:nui:getLocation', vehicle);
                        }}
                      >
                        <button className="flex gap-1 items-center">
                          <MapPinned size={16} strokeWidth={2.5} /> Locate Vehicle
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
});

export default VehicleContainer;
