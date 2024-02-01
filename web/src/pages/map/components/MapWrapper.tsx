// https://github.com/BubbleDK/bub-mdt/blob/main/web/src/pages/dispatch/index.tsx
import { MantineTheme, useMantineTheme } from '@mantine/core';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import React from 'react';
import { MapContainer } from 'react-leaflet';
import Map from './Map';

const MapWrapper: React.FC = () => {
    const theme: MantineTheme = useMantineTheme();

    const CRS: L.CRS & {
        projection: L.Projection;
        scale: (zoom: number) => number;
        zoom: (sc: number) => number;
        distance: (
            pos1: {
                lng: number;
                lat: number;
            },
            pos2: {
                lng: number;
                lat: number;
            }
        ) => number;
        transformation: L.Transformation;
        infinite: boolean;
    } = L.extend({}, L.CRS.Simple, {
        projection: L.Projection.LonLat,
        scale: function (zoom: number): number {
            return Math.pow(2, zoom);
        },
        zoom: function (sc: number): number {
            return Math.log(sc) / 0.6931471805599453;
        },
        distance: function (pos1: { lng: number; lat: number }, pos2: { lng: number; lat: number }): number {
            const x_difference: number = pos2.lng - pos1.lng;
            const y_difference: number = pos2.lat - pos1.lat;

            return Math.sqrt(x_difference * x_difference + y_difference * y_difference);
        },
        transformation: new L.Transformation(0.02072, 117.3, -0.0205, 172.8),
        infinite: false,
    });

    return (
        <MapContainer
            center={[0, -1024]}
            maxBoundsViscosity={1.0}
            preferCanvas
            zoom={6}
            maxZoom={6}
            minZoom={2}
            zoomControl={false}
            crs={CRS}
            style={{ width: '100%', height: '100%', borderRadius: theme.radius.md, zIndex: 1 }}
        >
            <Map />
            <React.Suspense></React.Suspense>
        </MapContainer>
    );
};

export default MapWrapper;
