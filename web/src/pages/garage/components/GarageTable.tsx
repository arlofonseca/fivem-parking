import { Button, MantineTheme, createStyles } from '@mantine/core';
import dayjs from 'dayjs';
import relativeTime from 'dayjs/plugin/relativeTime';
import React from 'react';

dayjs.extend(relativeTime);

const useStyles = createStyles((theme: MantineTheme) => ({
    main: {
        display: 'block',
        width: '23%',
        height: '20%',
        color: theme.colorScheme === 'dark' ? theme.colors.dark[0] : theme.black,
        fontFamily: `Greycliff CF, ${theme.fontFamily}`,
        marginTop: 1,
        padding: 10,
        borderRadius: 5,
        backgroundColor: '#1d1e20',
        border: `0.1px solid rgba(42, 42, 42, 1)`,
        transition: 'background-color 0.3s ease-in-out',

        '&:hover': {
            backgroundColor: '#17181b',
        },
    },
    strong: {
        marginRight: 3,
    },
    buttons: {
        marginTop: 10,
        display: 'flex',
        justifyContent: 'space-between',
    },
}));

interface VehicleData {
    plate: string;
    model: string;
    status: string;
    fuel: string;
}

const GarageTable: React.FC = () => {
    const { classes } = useStyles();

    const vehicleData: VehicleData = {
        plate: 'ABC123',
        model: 'adder',
        status: 'parked',
        fuel: '92.3%',
    };

    return (
        <div className={classes.main}>
            <strong className={classes.strong}>Plate:</strong> {vehicleData.plate}
            <br />
            <strong className={classes.strong}>Model:</strong> {vehicleData.model}
            <br />
            <strong className={classes.strong}>Status:</strong> {vehicleData.status}
            <br />
            <strong className={classes.strong}>Fuel:</strong> {vehicleData.fuel}
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
