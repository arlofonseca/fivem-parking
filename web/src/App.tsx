import { Divider, Tooltip, Transition } from '@mantine/core';
import clsx from 'clsx';
import debounce from 'debounce';
import { LayoutGrid, List, ParkingSquare, RefreshCw, X } from 'lucide-react';
import React, { Dispatch, SetStateAction, createContext, useEffect, useState } from 'react';
import { Options } from './@types/Options';
import { Vehicle } from './@types/Vehicle';
import Button from './components/button';
import HeaderText from './components/header-text';
import InfoModal from './components/info-modal';
import SearchPopover from './components/search-popover';
import VehicleContainer from './components/vehicle-container';
import { useExitListener } from './hooks/useExitListener';
import { useNuiEvent } from './hooks/useNuiEvent';
import Garage from './icons/garage.svg';
import Tow from './icons/tow.svg';
import { locales } from './store/Locales';
import { vehicleData } from './store/vehicleData';
import { debugData } from './utils/debugData';
import { fetchNui } from './utils/fetchNui';

debugData([
  {
    action: 'setVisible',
    data: {
      visible: true,
    },
  },
]);

debugData([
  {
    action: 'bgarage:nui:setVehicles',
    data: vehicleData,
  },
]);

interface Tabs {
  [key: string]: JSX.Element;
}

export interface AppContextType {
  options: Options;
  setOptions: Dispatch<SetStateAction<Options>>;
  impoundPrice: number;
  impoundOpen: boolean;
  garagePrice: number;
}

export const AppContext: React.Context<AppContextType | undefined> = createContext<AppContextType | undefined>(
  undefined
);

const App: React.FC = () => {
  const [visible, setVisible] = useState(false);
  const [currentTab, setCurrentTab] = useState('Garage');
  const [vehicles, setVehicles] = useState<Vehicle[] | undefined>(undefined);
  const [loading, setLoading] = useState(false);
  const [impoundOpen, setImpoundState] = useState(false);
  const [filteredVehicles, setFilteredVehicles] = useState<Vehicle[] | undefined>(undefined);
  const [searchQuery, setSearchQuery] = useState('');
  const [options, setOptions] = useState<Options>({ usingGrid: true });
  const [impoundPrice, setImpoundRetrieveFee] = useState(500);
  const [garagePrice, setGarageRetrieveFee] = useState(200);
  const [infoModalOpen, setInfoModalOpen] = useState(false);

  useNuiEvent('setVisible', (data: { visible: boolean; impoundOpen: boolean }): void => {
    setVisible(data.visible);
    setImpoundState(data.impoundOpen);

    if (!data.impoundOpen) return;

    setCurrentTab('Impound');
  });

  // Listening for an exit key, as of currently ["Escape"] only.
  useExitListener(setVisible);

  useNuiEvent('bgarage:nui:setVehicles', setVehicles);
  useNuiEvent('bgarage:nui:setOptions', setOptions);
  useNuiEvent('bgarage:nui:setImpoundPrice', setImpoundRetrieveFee);
  useNuiEvent('bgarage:nui:setGaragePrice', setGarageRetrieveFee);

  // Looks horrible, needs to be re-written in the future.
  const tabs: Tabs = {
    Garage: (
      <>
        {Object.values(vehicles ?? {}).filter((vehicle: Vehicle): boolean => vehicle.location !== 'impound').length >
        0 ? (
          <>
            <div className="">
              <VehicleContainer
                vehicles={
                  searchQuery.length > 0
                    ? filteredVehicles ?? []
                    : Object.values(vehicles ?? {}).filter(
                        (vehicle: Vehicle): boolean => vehicle.location !== 'impound'
                      )
                }
              />
            </div>
          </>
        ) : (
          <div className="w-full h-full flex items-center justify-center font-inter">Empty.</div>
        )}
      </>
    ),
    Impound: (
      <>
        {Object.values(vehicles ?? {}).filter((vehicle: Vehicle): boolean => vehicle.location === 'impound').length >
        0 ? (
          <VehicleContainer
            vehicles={
              searchQuery.length > 0
                ? filteredVehicles ?? []
                : Object.values(vehicles ?? {}).filter((vehicle: Vehicle): boolean => vehicle.location === 'impound')
            }
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center font-inter">Empty.</div>
        )}
      </>
    ),
  };

  useEffect((): void => {
    fetchNui('bgarage:nui:saveSettings', options);
  }, [options]);

  const handleButtonClick: (tab: string) => void = (tab: string): void => {
    if (!loading) {
      setLoading(true);
      setCurrentTab(tab);
      setSearchQuery('');
      setFilteredVehicles(undefined);
      setTimeout((): void => {
        setLoading(false);
      }, 500);
    }
  };

  const handleDisplayChange: (usingGrid: boolean) => void = (usingGrid: boolean): void => {
    setOptions({
      usingGrid: usingGrid,
    });

    fetchNui('bgarage:nui:saveSettings', {
      usingGrid: usingGrid,
    });
  };

  const filterVehicles: () => void = (): void => {
    const filterVehicles: (data: Vehicle[], query: string) => Vehicle[] = (
      data: Vehicle[],
      query: string
    ): Vehicle[] => {
      return data
        ? Object.values(data).filter((vehicle: Vehicle): boolean => {
            const queryLower: string = query.toLowerCase();
            return vehicle.modelName.toLowerCase().includes(queryLower) || vehicle.plate.includes(queryLower);
          })
        : [];
    };

    const vehiclesToQuery: Vehicle[] = Object.values(vehicles ?? []).filter((vehicle: Vehicle): boolean =>
      currentTab === 'Garage' ? vehicle.location !== 'impound' : vehicle.location === 'impound'
    );

    setFilteredVehicles(filterVehicles(vehiclesToQuery ?? [], searchQuery));
    setLoading(false);
  };

  const onChange: () => void = debounce(filterVehicles, 500);

  const handleSearchInputChange: (event: React.ChangeEvent<HTMLInputElement>) => void = (
    event: React.ChangeEvent<HTMLInputElement>
  ): void => {
    const value: string = event.target.value;
    setSearchQuery(value);
    onChange();
    setLoading(true);
  };

  return (
    <AppContext.Provider
      value={{
        options: options,
        setOptions: setOptions,
        impoundOpen: impoundOpen,
        impoundPrice: impoundPrice,
        garagePrice: garagePrice,
      }}
    >
      <Transition mounted={visible} transition={'pop'} timingFunction="ease" duration={400}>
        {(styles: React.CSSProperties) => {
          return (
            <div className="flex w-[100dvw] h-[100dvh] justify-center items-center" style={styles}>
              <InfoModal
                title="Created with ❤️"
                opened={infoModalOpen}
                onClose={(): void => {
                  setInfoModalOpen(false);
                }}
              />

              <div className="bg-[#25262b] h-[65dvh] w-[50dvw] px-4 py-1 rounded-[2px] overflow-hidden">
                <header className="flex items-center justify-center font-main mb-1 text-blue text-xl">
                  <HeaderText
                    Icon={ParkingSquare}
                    className="mr-auto hover:cursor-pointer border-[2px] border-transparent hover:border-blue transition-all"
                    size={20}
                    onClick={(): void => {
                      setInfoModalOpen(true);
                    }}
                  />
                  <div className="flex gap-2 mr-auto">
                    <Tooltip
                      label={locales.stored_vehicles}
                      classNames={{
                        tooltip: '!bg-[#1a1b1e] font-inter text-white rounded-[2px]',
                      }}
                    >
                      <div>
                        <Button
                          svg={Garage}
                          disabled={impoundOpen}
                          className={`${currentTab === 'Garage' && 'border-blue'} is-dirty`}
                          onClick={(): void => {
                            handleButtonClick('Garage');
                          }}
                        />
                      </div>
                    </Tooltip>
                    <Tooltip
                      label={locales.impounded_vehicles}
                      classNames={{
                        tooltip: '!bg-[#1a1b1e] font-inter text-white rounded-[2px]',
                      }}
                    >
                      <div>
                        <Button
                          svg={Tow}
                          className={`${currentTab === 'Impound' && 'border-blue'}`}
                          onClick={(): void => {
                            handleButtonClick('Impound');
                          }}
                        />
                      </div>
                    </Tooltip>
                  </div>
                  <div className="flex items-center">
                    <Button
                      className={`hover:bg-transparent hover:border-red transition-all text-red !px-2 !py-[7px] rounded-[2px] m-1`}
                      size={16}
                      Icon={X}
                      onClick={(): void => {
                        fetchNui('bgarage:nui:hideFrame');
                      }}
                    />
                  </div>
                </header>

                <Divider />

                <div className="flex gap-2 mt-2 mb-2 items-center">
                  <div className="flex gap-1 m-1">
                    <Button
                      Icon={List}
                      size={18}
                      className={clsx(
                        'hover:-translate-y-[2px] transition-all !px-2 !py-[7px]',
                        !options.usingGrid && 'border-blue'
                      )}
                      onClick={(): void => {
                        handleDisplayChange(false);
                      }}
                    />
                    <Button
                      Icon={LayoutGrid}
                      size={18}
                      className={clsx(
                        'hover:-translate-y-[2px] transition-all !px-2 !py-[7px]',
                        options.usingGrid && 'border-blue'
                      )}
                      onClick={(): void => {
                        handleDisplayChange(true);
                      }}
                    />
                  </div>

                  <div className="ml-auto">
                    <SearchPopover onChange={handleSearchInputChange} className="" />
                  </div>
                </div>

                {loading ? (
                  <>
                    <div className="w-full h-full flex justify-center items-center -mt-14">
                      <RefreshCw className="text-blue animate-spin" size={20} strokeWidth={2.5} />
                    </div>
                  </>
                ) : (
                  <>{tabs[currentTab]}</>
                )}
              </div>
            </div>
          );
        }}
      </Transition>
    </AppContext.Provider>
  );
};

export default App;
