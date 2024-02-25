import { ScrollArea } from '@mantine/core';
import clsx from 'clsx';
import React, { useContext, useState } from 'react';
import { Vehicle } from '../../@types/Vehicle';
import { AppContext, AppContextType } from '../../App';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { locales } from '../../store/Locales';
import { fetchNui } from '../../utils/fetchNui';
import ConfirmModal from '../modals/ConfirmationModal';
import VehicleInformation from './VehicleInformation';

interface Props {
  className?: string;
  vehicles: Vehicle[];
}

const VehicleContainer: React.FC<Props> = ({ className, vehicles }: Props) => {
  const [confirmModalState, setConfirModalState] = useState(false);
  const [selectedVehicle, setSelectedVehicle] = useState<Vehicle | undefined>(undefined);
  const [_price, setPrice] = useState(500);
  const { options, state } = useContext(AppContext) as AppContextType;

  const handleConfirmModal: () => void = (): void => {
    setConfirModalState(false);
    if (state) {
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
        <ScrollArea
          h={580}
          className={className}
          classNames={{
            scrollbar: '-m-2',
          }}
        >
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
                  <button
                    className="hover:-translate-y-[2px]  transition-all"
                    onClick={(): void => {
                      if (vehicle.location === 'outside') return;

                      if (vehicle.location === 'impound' && !state) return;

                      setSelectedVehicle(vehicle);
                      setConfirModalState(true);
                    }}
                  >
                    <VehicleInformation vehicleData={vehicle} />
                  </button>
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
