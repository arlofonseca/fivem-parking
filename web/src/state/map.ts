import { atom, useAtomValue, useSetAtom } from 'jotai';
import L from 'leaflet';

const mapAtom = atom<L.Map | null>(null);

export const useMap: () => L.Map | null = () => useAtomValue(mapAtom);
export const setMap = () => useSetAtom(mapAtom);
