// https://github.com/BubbleDK/bub-mdt/blob/main/web/src/pages/dispatch/index.tsx
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import React from 'react';
import { MapContainer } from 'react-leaflet';
import { useSetDispatchMap } from '../../../state/map';
import Map from './map';

const MapWrapper: React.FC = () => {
  const setMap = useSetDispatchMap();

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
      ref={setMap}
      zoom={6}
      maxZoom={6}
      minZoom={2}
      zoomControl={false}
      className="mt-14"
      crs={CRS}
      style={{ width: '100%', height: '50dvh', borderRadius: '2px', zIndex: 1 }}
    >
      <Map />
    </MapContainer>
  );
};

export default MapWrapper;
