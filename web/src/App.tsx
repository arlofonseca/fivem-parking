import { debugData } from './utils/debugData';
import VehicleBrowser from './pages/browser';
import { useNuiEvent } from './hooks/useNuiEvent';
import { useState } from 'react';
import { useAppDispatch } from './state';
import { useExitListener } from './hooks/useExitListener';
import Vehicle from './pages/vehicle';
import Dev from './pages/dev';
import { isEnvBrowser } from './utils/misc';
import { vehicleClasses } from './state/models/filters';
import Popup from './pages/popup';
import vehicle from './pages/vehicle';

export default function App() {
    const [categories, setCategories] = useState<string[]>(['']);
    const dispatch = useAppDispatch();

    useExitListener(dispatch.visibility.setBrowserVisible);

    useNuiEvent('setVisible', (data: { categories: number[]; types: Record<string, true>; visible: boolean }): void => {
        const categories: string[] = [];
        for (let i: number = 0; i < data.categories.length; i++) categories.push(vehicleClasses[data.categories[i]]);
        setCategories(categories);
        dispatch.filters.setTypes(data.types);
        dispatch.visibility.setBrowserVisible(data.visible);
    });

    return (
        <>
            <VehicleBrowser categories={categories} />
            <Vehicle />
            <Popup />
            {isEnvBrowser() && <Dev />}
        </>
    );
}
