import { Divider, Tooltip, Transition } from '@mantine/core';
import debounce from 'debounce';
import { ParkingSquare, RefreshCw, X } from 'lucide-react';
import React, { Dispatch, SetStateAction, createContext, useEffect, useState } from 'react';
import { useExitListener } from '../hooks/useExitListener';
import { useNuiEvent } from '../hooks/useNuiEvent';
import Garage from '../icons/garage.svg';
import Tow from '../icons/tow.svg';
import { Options } from '../types/Options';
import { Vehicle } from '../types/Vehicle';
import { debugData } from '../utils/debugData';
import { fetchNui } from '../utils/fetchNui';
import { generateType } from '../utils/generateType';
import Button from './Main/Button';
import HeaderText from './Main/header-text';
import SearchPopover from './Main/search-popover';
import VehicleContainer from './Main/vehicle-container';

debugData([
    {
        action: 'setVisible',
        data: {
            visible: true,
        },
    },
]);

/**
debugData([
  {
    action: 'bgarage:nui:setVehicles',
    data: Array.from(
      { length: 30 },
      (
        _: unknown,
        index: number
      ): {
        owner: string | number;
        model: string | number;
        plate: string;
        modelName: string;
        location: string;
        type: string;
        temporary: boolean;
      } => ({
        owner: 'vipex',
        model: `${index}`,
        plate: `Plate ${index}`,
        modelName: `Something ${index}`,
        location: Math.random() >= 0.5 ? 'parked' : 'impound',
        type: generateType(),
        temporary: false,
      })
    ),
  },
]);
 */

interface Tabs {
    [key: string]: JSX.Element;
}

export interface AppContextType {
    options: Options;
    setOptions: Dispatch<SetStateAction<Options>>;
    impoundPrice: number;
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
    const [impoundPrice, setImpoundPrice] = useState(500);

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
    useNuiEvent('bgarage:nui:setImpoundPrice', setImpoundPrice);

    // Looks horrible, needs to be re-written in the future.
    const tabs: Tabs = {
        Garage: (
            <>
                {Object.values(vehicles ?? {}).filter((vehicle: Vehicle): boolean => vehicle.location !== 'impound')
                    .length > 0 ? (
                    <>
                        <div className="">
                            <VehicleContainer
                                impoundOpen={impoundOpen}
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
                {Object.values(vehicles ?? {}).filter((vehicle: Vehicle): boolean => vehicle.location === 'impound')
                    .length > 0 ? (
                    <VehicleContainer
                        impoundOpen={impoundOpen}
                        vehicles={
                            searchQuery.length > 0
                                ? filteredVehicles ?? []
                                : Object.values(vehicles ?? {}).filter(
                                      (vehicle: Vehicle): boolean => vehicle.location === 'impound'
                                  )
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

    const debouncedOnChange: debounce.DebouncedFunction<() => void> = debounce(filterVehicles, 500);

    const handleSearchInputChange: (event: React.ChangeEvent<HTMLInputElement>) => void = (
        event: React.ChangeEvent<HTMLInputElement>
    ): void => {
        const value: string = event.target.value;
        setSearchQuery(value);
        debouncedOnChange();
        setLoading(true);
    };

    return (
        <AppContext.Provider
            value={{
                options: options,
                setOptions: setOptions,
                impoundPrice: impoundPrice,
            }}
        >
            <Transition mounted={visible} transition={'pop'} timingFunction="ease" duration={400}>
                {(styles: React.CSSProperties) => {
                    return (
                        <div className="flex w-[100dvw] h-[100dvh] justify-center items-center" style={styles}>
                            <div className="bg-[#25262b] h-[65dvh] w-[50dvw] px-4 py-1 rounded-[2px] overflow-hidden">
                                <header className="flex items-center justify-center font-main mb-1 text-blue text-xl">
                                    <HeaderText Icon={ParkingSquare} className="mr-auto" size={20} />
                                    <div className="flex gap-2 mr-auto">
                                        <Tooltip
                                            label="Stored Vehicles"
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
                                            label="Impounded Vehicles"
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
                                        <SearchPopover onChange={handleSearchInputChange} className="" />
                                        <Button
                                            className={`hover:bg-transparent hover:border-red transition-all rounded text-red !px-2 !py-[7px] rounded-[2px]`}
                                            size={16}
                                            Icon={X}
                                            onClick={(): void => {
                                                fetchNui('bgarage:nui:hideFrame');
                                            }}
                                        />
                                    </div>
                                    {/* <Button
                  className={`hover:border-blue !px-2 !py-[7px] rounded-[2px]`}
                  size={16}
                  Icon={Cog}
                  /> */}
                                </header>

                                <Divider />

                                {loading ? (
                                    <>
                                        <div className="w-full h-full flex justify-center items-center">
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

// dummy data was autogenerated prior which is far more better than this
// really only using this to debug the 'search' feature to search when searching for exact model/plate
// will remove when things are finalized
debugData([
    {
        action: 'bgarage:nui:setVehicles',
        data: [
            {
                owner: 'vipex',
                model: 'fugitive',
                plate: 'UL66Y8QD',
                modelName: 'Fugitive',
                location: 'parked',
                type: 'car',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'akuma',
                plate: 'H54MPQ6W',
                modelName: 'Akuma',
                location: 'outside',
                type: 'motorcycle',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'bmx',
                plate: 'KG0UCL33',
                modelName: 'BMX',
                location: 'parked',
                type: 'bicycle',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'scorcher',
                plate: '2IOMWCRU',
                modelName: 'Scorcher',
                location: 'parked',
                type: 'bicycle',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'primo',
                plate: 'NJBV537S',
                modelName: 'Primo',
                location: 'parked',
                type: 'car',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'seashark',
                plate: '3X5IHQ6Y',
                modelName: 'Seashark',
                location: 'parked',
                type: 'boat',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'granger',
                plate: 'ZUFX2HTK',
                modelName: 'Granger40',
                location: 'parked',
                type: 'emergency',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'raiju',
                plate: '8EIKHTZC',
                modelName: 'Raiju ST',
                location: 'parked',
                type: 'plane',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'hunter',
                plate: 'ACAHKQ4E',
                modelName: 'FH-1 Hunter',
                location: 'parked',
                type: 'helicopter',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'mule',
                plate: 'D5IJUW4G',
                modelName: 'Mule',
                location: 'outside',
                type: 'truck',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'stockade',
                plate: 'J5Y66PCZ',
                modelName: 'Stockade',
                location: 'parked',
                type: 'truck',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'fcr1000',
                plate: '7GNC2NA5',
                modelName: 'FCR 1000',
                location: 'parked',
                type: 'motorcycle',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'youga',
                plate: 'QTX8E6G4',
                modelName: 'Youga Classic',
                location: 'parked',
                type: 'van',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'train',
                plate: 'QTX8E6G4',
                modelName: 'Train',
                location: 'parked',
                type: 'train',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'dodo',
                plate: '7Q9QLARS',
                modelName: 'Dodo',
                location: 'parked',
                type: 'plane',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'blazer',
                plate: 'CI6AGG22',
                modelName: 'Blazer',
                location: 'outside',
                type: 'off-road',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'skimmer',
                plate: 'NHGUOE7D',
                modelName: 'Skimmer',
                location: 'outside',
                type: 'boat',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'nemesis',
                plate: '48OHCYBU',
                modelName: 'Nemesis',
                location: 'parked',
                type: 'motorcycle',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'cogcabrio',
                plate: '9RJSMHX2',
                modelName: 'Cog Cabrio',
                location: 'parked',
                type: 'car',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'insurgent',
                plate: '3MVWGHDB',
                modelName: 'Insurgent',
                location: 'parked',
                type: 'emergency',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'sanchez',
                plate: 'XWIQKTUG',
                modelName: 'Sanchez',
                location: 'parked',
                type: 'motorcycle',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'blimp',
                plate: 'NYDTEQE9',
                modelName: 'Atomic Blimp',
                location: 'parked',
                type: 'plane',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'trash',
                plate: 'VZIK4M0P',
                modelName: 'Trashmaster',
                location: 'parked',
                type: 'truck',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'cruiser',
                plate: '62WTSBQZ',
                modelName: 'Cruiser',
                location: 'outside',
                type: 'bicycle',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'riot',
                plate: 'TM6BT5OC',
                modelName: 'Riot',
                location: 'parked',
                type: 'emergency',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'riot',
                plate: 'TM6BT5OC',
                modelName: 'Riot',
                location: 'parked',
                type: 'emergency',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'rhapsody',
                plate: 'S8H3KAOV',
                modelName: 'Rhapsody',
                location: 'outside',
                type: 'car',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'packer',
                plate: '004ZO2W8',
                modelName: 'Packer RT',
                location: 'parked',
                type: 'truck',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'akula',
                plate: 'PG882TGC',
                modelName: 'Akula',
                location: 'parked',
                type: 'helicopter',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'flap',
                plate: 'P8C81M0J',
                modelName: '900 Flap',
                location: 'parked',
                type: 'motorcycle',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: '300r',
                plate: 'XNY2RL6R',
                modelName: '300R',
                location: 'parked',
                type: 'car',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: '104widebody',
                plate: '2FDJ0EX5',
                modelName: '10F Widebody',
                location: 'parked',
                type: 'car',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'hotstring',
                plate: 'K631DO2Q',
                modelName: 'Hotstring Hellfire',
                location: 'parked',
                type: 'car',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'seasparrow',
                plate: '5RWHHRZF',
                modelName: 'Sea Sparrow',
                location: 'parked',
                type: 'helicopter',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'speedo',
                plate: 'B04HXJP6',
                modelName: 'Speedo',
                location: 'outside',
                type: 'van',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'asea',
                plate: '1XZA188A',
                modelName: 'Asea',
                location: 'impound',
                type: 'car',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'sopent10',
                plate: '9SK7HF20',
                modelName: 'Sopen T-10',
                location: 'impound',
                type: 'van',
                temporary: false,
            },
            {
                owner: 'vipex',
                model: 'adder',
                plate: '4DKR1WMN',
                modelName: 'Adder',
                location: 'impound',
                type: 'car',
                temporary: false,
            },
        ],
    },
]);

export default App;
