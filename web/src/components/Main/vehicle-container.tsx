/* eslint-disable @typescript-eslint/no-explicit-any */
import { Menu, ScrollArea } from '@mantine/core';
import { KeySquare, MapPinned } from 'lucide-react';
import React from 'react';
import { Vehicle } from '../../types/Vehicle';
import { fetchNui } from '../../utils/fetchNui';
import VehicleInfo from './vehicle-info';

interface Props {
    className?: string;
    vehicles: Vehicle[];
    inImpound: boolean;
}

const VehicleContainer: React.FC<Props> = React.memo(({ className, vehicles, inImpound }) => {
    return (
        <>
            <ScrollArea h={620} className={className}>
                <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2">
                    {Object.values(vehicles).map((vehicle, index) => {
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
                                            <Menu.Item disabled={vehicle.location === 'impound' && !inImpound}>
                                                <button
                                                    className="flex gap-1 items-center"
                                                    onClick={() => {
                                                        fetchNui(
                                                            inImpound
                                                                ? 'bgarage:cb:impound:retrieve'
                                                                : 'bgarage:cb:garage:retrieve',
                                                            vehicle
                                                        );
                                                        fetchNui('hideFrame');
                                                    }}
                                                >
                                                    <KeySquare size={16} strokeWidth={2.5} /> Get Vehicle
                                                </button>
                                            </Menu.Item>
                                        )}

                                        <Menu.Item>
                                            <button
                                                className="flex gap-1 items-center"
                                                onClick={() => {
                                                    fetchNui('bgarage:cb:getLocation', vehicle);
                                                }}
                                            >
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
        </>
    );
});

export default VehicleContainer;
