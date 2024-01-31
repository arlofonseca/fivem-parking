import { MantineProvider } from '@mantine/core';
import { ModalsProvider } from '@mantine/modals';
import React from 'react';
import ReactDOM from 'react-dom/client';
import { HashRouter } from 'react-router-dom';
import App from './App';
import './index.css';
import { debugData } from './utils/debugData';
import { isEnvBrowser } from './utils/misc';

debugData([
    {
        action: 'bgarageDebug',
        data: {
            garage: [
                {
                    id: 1,
                    title: 'Lorem ipsum',
                    description: 'Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum',
                    time: new Date().valueOf(),
                },
                {
                    id: 2,
                    title: 'Lorem ipsum',
                    description: 'Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum',
                    time: new Date().valueOf(),
                },
            ],

            impound: [
                {
                    id: 1,
                    title: 'Lorem ipsum',
                    message: 'Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum',
                    time: new Date().valueOf(),
                },
                {
                    id: 2,
                    title: 'A nice title',
                    message: 'Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum',
                    time: new Date().valueOf(),
                },
            ],

            test: {
                plate: '12345678910',
                model: 'Asea',
                status: 'parked',
                fuel: '92.8%',
                location: 'x, y, z',
            },
        },
    },
]);

if (isEnvBrowser()) {
    const root: HTMLElement | null = document.getElementById('root');

    root!.style.backgroundSize = 'cover';
    root!.style.backgroundRepeat = 'no-repeat';
    root!.style.backgroundPosition = 'center';
}

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
    <React.StrictMode>
        <MantineProvider theme={{ colorScheme: 'dark', fontFamily: 'Nunito, sans-serif' }}>
            <ModalsProvider>
                <HashRouter>
                    <App />
                </HashRouter>
            </ModalsProvider>
        </MantineProvider>
    </React.StrictMode>
);
