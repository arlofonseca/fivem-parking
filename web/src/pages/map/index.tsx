import React from 'react';
import { Box, createStyles, Grid, Stack } from '@mantine/core';
import MapWrapper from './components/MapWrapper';

const useStyles = createStyles((theme) => ({
    container: {
        height: '100%',
        backgroundColor: theme.colors.durple[6],
        borderRadius: theme.radius.md,
        boxShadow: theme.shadows.md,
        padding: theme.spacing.md,
    },
}));

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
