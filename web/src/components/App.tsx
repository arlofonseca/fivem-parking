import { Divider, Tooltip, Transition } from '@mantine/core';
import debounce from 'debounce';
import { Cog, ParkingSquare, RefreshCw } from 'lucide-react';
import React, { useEffect, useState } from 'react';
import { useNuiEvent } from '../hooks/useNuiEvent';
import Garage from '../icons/garage.svg';
import Tow from '../icons/tow.svg';
import { Vehicle } from '../types/Vehicle';
import { debugData } from '../utils/debugData';
import { fetchNui } from '../utils/fetchNui';
import { isEnvBrowser } from '../utils/misc';
import './App.css';
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

interface Tabs {
    [key: string]: JSX.Element;
}

const App: React.FC = React.memo(() => {
    const [visible, setVisible] = useState(false);
    const [currentTab, setCurrentTab] = useState('Garage');
    const [vehicles, setVehicles] = useState<Vehicle[] | undefined>(undefined);
    const [loading, setLoading] = useState(false);
    const [inImpound, setInImpound] = useState(false);
    const [filteredVehicles, setFilteredVehicles] = useState<Vehicle[] | undefined>(undefined);
    const [searchQuery, setSearchQuery] = useState('');

    useNuiEvent('setVisible', (data: { visible: boolean; inImpound: boolean }) => {
        setVisible(data.visible);
        setInImpound(data.inImpound);
    });

    useNuiEvent('nui:state:vehicles', setVehicles);

    // Looks horrible, needs to be re-written in the future.
    const tabs: Tabs = {
        Garage: (
            <>
                {Object.values(vehicles ?? {}).filter((vehicle) => vehicle.location !== 'impound').length > 0 ? (
                    <VehicleContainer
                        inImpound={inImpound}
                        vehicles={
                            searchQuery.length > 0
                                ? filteredVehicles ?? []
                                : Object.values(vehicles ?? {}).filter((vehicle) => vehicle.location !== 'impound')
                        }
                    />
                ) : (
                    <div className="w-full h-full flex items-center justify-center font-inter">Empty.</div>
                )}
            </>
        ),
        Impound: (
            <>
                {Object.values(vehicles ?? {}).filter((vehicle) => vehicle.location === 'impound').length > 0 ? (
                    <VehicleContainer
                        inImpound={inImpound}
                        vehicles={
                            searchQuery.length > 0
                                ? filteredVehicles ?? []
                                : Object.values(vehicles ?? {}).filter((vehicle) => vehicle.location === 'impound')
                        }
                    />
                ) : (
                    <div className="w-full h-full flex items-center justify-center font-inter">Empty.</div>
                )}
            </>
        ),
    };

    useEffect(() => {
        if (!visible) return;

        const keyHandler = (e: KeyboardEvent) => {
            if (['Escape'].includes(e.code)) {
                if (!isEnvBrowser()) fetchNui('hideFrame');
                else setVisible(!visible);
            }
        };

        if (inImpound) {
            setCurrentTab('Impound');
        }

        window.addEventListener('keydown', keyHandler);

        return () => window.removeEventListener('keydown', keyHandler);
    }, [visible, inImpound]);

    const handleButtonClick = (tab: string) => {
        if (!loading) {
            setLoading(true);
            setCurrentTab(tab);
            setTimeout(() => {
                setLoading(false);
            }, 500);
        }
    };
    const filterVehicles = () => {
        const filterVehicles = (data: Vehicle[], query: string) => {
            return data
                ? Object.values(data).filter((vehicle) => {
                      const queryLower = query.toLowerCase();
                      return vehicle.modelName.toLowerCase().includes(queryLower) || vehicle.plate.includes(queryLower);
                  })
                : [];
        };

        const vehiclesToQuery = Object.values(vehicles ?? []).filter((vehicle) =>
            currentTab === 'Garage' ? vehicle.location !== 'impound' : vehicle.location === 'impound'
        );

        setFilteredVehicles(filterVehicles(vehiclesToQuery ?? [], searchQuery));

        setLoading(false);
    };

    const debouncedOnChange = debounce(filterVehicles, 500);

    const handleSearchInputChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        const value = event.target.value;
        setSearchQuery(value);
        debouncedOnChange();
        setLoading(true);
    };

    return (
        <Transition mounted={visible} transition={'pop'} timingFunction="ease" duration={400}>
            {(styles) => {
                return (
                    <div className="flex w-[100dvw] h-[100dvh] justify-center items-center" style={styles}>
                        <div className="bg-[#25262b] h-[65dvh] w-[50dvw] px-4 py-1 rounded-[2px] overflow-hidden">
                            <header className="flex items-center justify-center font-main mb-1 text-neon text-xl">
                                <HeaderText Icon={ParkingSquare} className="mr-auto" size={20} />
                                <div className="flex gap-2 mr-auto">
                                    <Tooltip
                                        label="Garage"
                                        classNames={{
                                            tooltip: '!bg-[#1a1b1e] font-inter text-neon rounded-[2px]',
                                        }}
                                    >
                                        <div>
                                            <Button
                                                svg={Garage}
                                                disabled={inImpound}
                                                className={`${currentTab === 'Garage' && 'border-neon'} is-dirty`}
                                                onClick={() => {
                                                    handleButtonClick('Garage');
                                                }}
                                            />
                                        </div>
                                    </Tooltip>
                                    <Tooltip
                                        label="Impound"
                                        classNames={{
                                            tooltip: '!bg-[#1a1b1e] font-inter text-neon rounded-[2px]',
                                        }}
                                    >
                                        <div>
                                            <Button
                                                svg={Tow}
                                                className={`${currentTab === 'Impound' && 'border-neon'}`}
                                                onClick={() => {
                                                    handleButtonClick('Impound');
                                                }}
                                            />
                                        </div>
                                    </Tooltip>
                                </div>
                                <SearchPopover onChange={handleSearchInputChange} />
                                <Button
                                    className={`hover:border-neon !px-2 !py-[7px] rounded-[2px]`}
                                    size={16}
                                    Icon={Cog}
                                ></Button>
                            </header>

                            <Divider />

                            {loading ? (
                                <>
                                    <div className="w-full h-full flex justify-center items-center">
                                        <RefreshCw className="text-neon animate-spin" size={20} strokeWidth={2.5} />
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
    );
});

export default App;
