import { LoadingOverlay, MantineTheme, UseStylesOptions, createStyles } from '@mantine/core';
import { useState } from 'react';
import GarageTable from './components/GarageTable';

const useStyles: (
    params: void,
    options?: UseStylesOptions<string> | undefined
) => {
    classes: {
        garage: string;
    };
    cx: (...args: any) => string;
    theme: MantineTheme;
} = createStyles((theme: MantineTheme) => ({
    garage: {
        height: 880,
        margin: 20,
        display: 'flex',
        gap: 15,
    },
}));

const Garage: () => JSX.Element = () => {
    const { classes } = useStyles();
    const [status] = useState(false);

    return (
        <div className={classes.garage}>
            <GarageTable />
            <LoadingOverlay
                visible={status}
                overlayOpacity={0.95}
                overlayColor={'rgb(34, 35, 37)'}
                transitionDuration={250}
                style={{ left: 760, width: 1040, height: '96%', top: 19, borderRadius: '0.25rem' }}
            />
        </div>
    );
};

export default Garage;
