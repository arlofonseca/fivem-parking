import { Box, createStyles, Grid, MantineTheme, UseStylesOptions } from '@mantine/core';
import React from 'react';
import MapWrapper from './components/MapWrapper';

const useStyles: (
    params: void,
    options?: UseStylesOptions<string> | undefined
) => {
    classes: {
        container: string;
    };
    cx: (...args: any) => string;
    theme: MantineTheme;
} = createStyles(
    (
        theme: MantineTheme
    ): {
        container: {
            height: string;
            backgroundColor: string;
            borderRadius: string;
            boxShadow: string;
            padding: string;
        };
    } => ({
        container: {
            height: '100%',
            backgroundColor: theme.colors.durple[6],
            borderRadius: theme.radius.md,
            boxShadow: theme.shadows.md,
            padding: theme.spacing.md,
        },
    })
);

const Map: React.FC = () => {
    const { classes } = useStyles();

    return (
        <Grid grow h="100%" mt={0} mb={0}>
            <Grid.Col span={4} pb={0} pt={0} px="xs">
                <Box className={classes.container} p={0}>
                    <MapWrapper />
                </Box>
            </Grid.Col>
        </Grid>
    );
};

export default Map;
