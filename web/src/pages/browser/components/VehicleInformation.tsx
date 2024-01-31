import { Paper, Group, Stack, Title, MantineTheme } from '@mantine/core';
import React from 'react';
import IconGroup from '../../../components/IconGroup';
import { TbReceipt2 } from 'react-icons/tb';
import { GiCarDoor, GiHeavyBullets } from 'react-icons/gi';
import { MdAirlineSeatReclineNormal } from 'react-icons/md';
import { useAppDispatch } from '../../../state';
import { formatNumber } from '../../../utils/formatNumber';

const VehicleInformation: React.FC<{
    vehicle: { make: string; name: string };
    index: string;
}> = ({ vehicle, index }) => {
    const dispatch = useAppDispatch();

    return (
        <>
            <Paper
                onClick={(): void => {
                    dispatch.visibility.setVehicleVisible(true);
                    dispatch.vehicleData.getVehicleData(index);
                }}
                shadow="md"
                p="md"
                withBorder
                sx={(theme: MantineTheme) => ({
                    width: '100%',
                    border: '#25262B 1px solid',
                    backgroundColor: theme.colors.dark[6],
                    '&:hover': { backgroundColor: theme.colors.dark[5], cursor: 'pointer' },
                })}
            >
                <Stack sx={{ width: '100%' }}>
                    <Group position="apart" noWrap>
                        <Title order={4}>{`${vehicle.make} ${vehicle.name}`}</Title>
                    </Group>
                </Stack>
            </Paper>
        </>
    );
};

export default VehicleInformation;
