import { Stack, Text, Center, Loader } from '@mantine/core';
import { useState } from 'react';
import { TbSearch } from 'react-icons/tb';
import { useLocales } from '../../../providers/LocaleProvider';
import { RootState, useAppSelector } from '../../../state';
import VehicleInformation from './VehicleInformation';
import { VehicleData } from '../../../state/models/vehicles';

const VehicleList: React.FC = () => {
    const vehicles = useAppSelector((state: RootState) => state.listVehicles);
    const isLoading: boolean = useAppSelector((state: RootState): boolean => state.isLoading);
    const { locale } = useLocales();

    return (
        <>
            {isLoading ? (
                <Center style={{ position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%, -50%)' }}>
                    <Loader />
                </Center>
            ) : (
                <>
                    {Object.keys(vehicles).length > 0 ? (
                        <Stack spacing="sm">
                            {Object.entries(vehicles).map((vehicle: [string, VehicleData], index: number) => (
                                <VehicleInformation key={`vehicle-${index}`} vehicle={vehicle[1]} index={vehicle[0]} />
                            ))}
                        </Stack>
                    ) : (
                        <Center>
                            <Stack align="center">
                                <TbSearch fontSize={48} />
                                <Text size="xl">{'No vehicles found'}</Text>
                            </Stack>
                        </Center>
                    )}
                </>
            )}
        </>
    );
};

export default VehicleList;
