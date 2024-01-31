import { Button, MantineTheme, UseStylesOptions, createStyles } from '@mantine/core';
import { IconCar, IconGasStation, IconKey, IconMapPin } from '@tabler/icons-react';
import dayjs from 'dayjs';
import relativeTime from 'dayjs/plugin/relativeTime';
import React from 'react';

dayjs.extend(relativeTime);

const useStyles: (
    params: void,
    options?: UseStylesOptions<string> | undefined
) => {
    classes: {
        main: string;
        buttons: string;
    };
    cx: (...args: any) => string;
    theme: MantineTheme;
} = createStyles((theme: MantineTheme) => ({
    main: {
        display: 'block',
        width: '20%',
        height: '20%',
        color: theme.colorScheme === 'dark' ? theme.colors.dark[0] : theme.black,
        fontFamily: `Greycliff CF, ${theme.fontFamily}`,
        marginTop: 5,
        padding: 10,
        borderRadius: 5,
        backgroundColor: '#1d1e20',
        border: `0.1px solid rgb(42, 42, 42, 1)`,

        '&:hover': {
            backgroundColor: '#17181b',
        },
    },
    buttons: {
        marginTop: 10,
        display: 'flex',
        justifyContent: 'space-between',
    },
}));

// todo
const GarageTable: React.FC = () => {
    const { classes } = useStyles();

    // Dummy debug data for a vehicle
    const vehicleData = {
        plate: 'ABC123',
        model: 'adder',
        status: 'parked',
        fuel: '92.3%',
    };

    return (
        <div className={classes.main}>
            <IconKey size={20} color="blue" />
            <strong>Plate:</strong> {vehicleData.plate}
            <br />
            <IconCar size={20} color="green" />
            <strong>Model:</strong> {vehicleData.model}
            <br />
            <IconMapPin size={20} color="red" />
            <strong>Status:</strong> {vehicleData.status}
            <br />
            <IconGasStation size={20} color="yellow" />
            <strong>Fuel:</strong> {vehicleData.fuel}
            <br />
            <div className={classes.buttons}>
                <Button size="sm" onClick={() => console.log('Retrieve button clicked')}>
                    Retrieve
                </Button>
                <Button size="sm" onClick={() => console.log('Inspect button clicked')}>
                    Inspect
                </Button>
            </div>
        </div>
    );
};

export default GarageTable;
