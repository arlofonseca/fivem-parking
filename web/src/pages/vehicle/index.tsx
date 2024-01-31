import { Box, Button, createStyles, Stack, Title, Transition } from '@mantine/core';
import { useExitListener } from '../../hooks/useExitListener';
import { useAppDispatch, useAppSelector } from '../../state';
import StatBar from './components/StatBar';
import Color from './components/Color';
import RetrieveModal from './components/RetriveModal';
import { useMemo, useState } from 'react';
import { useLocales } from '../../providers/LocaleProvider';
import { vehicleTypeToGroup } from '../../state/models/vehicles';

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

const Vehicle: React.FC = () => {
    const { classes } = useStyles();
    const { locale } = useLocales();
    const dispatch = useAppDispatch();
    const topStats = useAppSelector((state) => state.topStats);
    const vehicleVisibility = useAppSelector((state) => state.visibility.vehicle);
    const vehicleData = useAppSelector((state) => state.vehicleData);
    const [opened, setOpened] = useState(false);

    useExitListener(dispatch.visibility.setVehicleVisible);

    return (
        <Transition mounted={vehicleVisibility} transition="slide-left">
            {(style) => (
                <Box style={style} className={classes.wrapper}>
                    <Box className={classes.box}>
                        <Stack align="center">
                            <Title order={4}>{`${vehicleData.make} ${vehicleData.name}`}</Title>
                            <Color />
                            <Button fullWidth uppercase onClick={() => setOpened(true)}>
                                {'Vehicle successfully removed'}
                            </Button>
                        </Stack>
                    </Box>
                </Box>
            )}
        </Transition>
    );
};

export default Vehicle;
