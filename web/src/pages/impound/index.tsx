import { LoadingOverlay, MantineTheme, UseStylesOptions, createStyles } from '@mantine/core';
import { useState } from 'react';
import ImpoundTable from './components/ImpoundTable';

const useStyles: (
    params: void,
    options?: UseStylesOptions<string> | undefined
) => {
    classes: {
        impound: string;
    };
    cx: (...args: any) => string;
    theme: MantineTheme;
} = createStyles(
    (theme: MantineTheme): { impound: { height: number; margin: number; display: 'flex'; gap: number } } => ({
        impound: {
            height: 880,
            margin: 20,
            display: 'flex',
            gap: 15,
        },
    })
);

const Impound: () => JSX.Element = () => {
    const { classes } = useStyles();
    const [status] = useState(false);

    return (
        <div className={classes.impound}>
            <ImpoundTable />
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

export default Impound;
