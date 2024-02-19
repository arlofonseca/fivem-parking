import { Box, Grid } from '@mantine/core';
import React from 'react';
import MapWrapper from './components/MapWrapper';

const MapFrame: React.FC = () => {
  return (
    <Grid grow h="100%" mt={0} mb={0} className="w-full">
      <Grid.Col span={4} pb={0} pt={0} px="xs">
        <Box p={0}>
          <MapWrapper />
        </Box>
      </Grid.Col>
    </Grid>
  );
};

export default MapFrame;
