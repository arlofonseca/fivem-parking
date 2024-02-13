import { Menu, ScrollArea, Modal } from '@mantine/core';
import { KeySquare, LayoutGrid, List, MapPinned } from 'lucide-react';
import React, { Dispatch, SetStateAction, useContext, useState } from 'react';
import { Vehicle } from '../../types/Vehicle';
import { fetchNui } from '../../utils/fetchNui';
import VehicleInfo from './vehicle-info';
import ConfirmModal from './confirm-modal';
import Button from './button';
import clsx from 'clsx';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { Options } from '../../types/Options';
import { AppContext, AppContextType } from '../App';

interface Props {
    className?: string;
    vehicles: Vehicle[];
    inImpound: boolean;
}

const VehicleContainer: React.FC<Props> = React.memo(({ className, vehicles, inImpound }: Props) => {
    const [confirmModalState, setConfirModalState] = useState(false);
    const [selectedVehicle, setSelectedVehicle] = useState<Vehicle | undefined>(undefined);

    const { options, setOptions } = useContext(AppContext) as AppContextType;

    const handleModalConfirm = () => {
        setConfirModalState(false);
        fetchNui('bgarage:nui:impound:retrieve', selectedVehicle);
        setSelectedVehicle(undefined);
    };

    const handleGridChange = (usingGrid: boolean) => {
        setOptions({
            usingGrid: usingGrid,
        });

        fetchNui('bgarage:nui:save', {
            usingGrid: usingGrid,
        });
    };
    return (
        <>
            <ConfirmModal
                opened={confirmModalState}
                title="Confirmation"
                onClose={() => {
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
                        onClick={() => {
                            handleGridChange(false);
                        }}
                    />
                    <Button
                        Icon={LayoutGrid}
                        size={18}
                        className={clsx('hover:-translate-y-[2px] transition-all', options.usingGrid && 'border-blue')}
                        onClick={() => {
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
                                                    disabled={vehicle.location === 'impound' && !inImpound}
                                                    onClick={() => {
                                                        if (inImpound) {
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
                                                onClick={() => {
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
