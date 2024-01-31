import { Box, createStyles, Stack, Text, Transition } from '@mantine/core';
import { useMemo, useState } from 'react';
import { VehicleData } from '../../state/models/vehicles';
import StatBar from '../vehicle/components/StatBar';
import { useLocales } from '../../providers/LocaleProvider';
import { useAppSelector } from '../../state';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { vehicleTypeToGroup } from '../../state/models/vehicles';
import { useAppDispatch } from '../../state';
import { formatNumber } from '../../utils/formatNumber';

const useStyles = createStyles((theme) => ({
    wrapper: {
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'flex-end',
        height: '100%',
        width: '100%',
    },

    box: {
        height: 'fit-content',
        width: 300,
        backgroundColor: theme.colors.dark[7],
        padding: 10,
        borderTopLeftRadius: theme.radius.sm,
        borderBottomLeftRadius: theme.radius.sm,
    },
}));

const Popup: React.FC = () => {
    const { classes } = useStyles();
    const { locale } = useLocales();
    const dispatch = useAppDispatch();
    const [visible, setVisible] = useState(false);
    const topStats = useAppSelector((state) => state.topStats);
    const [vehicle, setVehicle] = useState<VehicleData>({
        name: '',
        class: 0,
        make: '',
        type: 'automobile',
    });

    useNuiEvent('setStatsVisible', (data: [string, number] | false) => {
        if (!data) return setVisible(false);
        const vehicle = dispatch.vehicleData.getSingleVehicle(data[0]);
        // vehicle.types = data[1];
        setVehicle(vehicle);
        setVisible(true);
    });

    return (
        <Transition mounted={visible} transition="slide-left">
            {(style) => (
                <Box style={style} className={classes.wrapper}>
                    <Box className={classes.box}>
                        <Stack>
                            <Text align="center" size={20} weight={700}>{`${vehicle.make} ${vehicle.name}`}</Text>
                            <Text align="center" color="teal" size={20} weight={700}>
                                {formatNumber(1)}
                            </Text>
                        </Stack>
                    </Box>
                </Box>
            )}
        </Transition>
    );
};

export default Popup;
