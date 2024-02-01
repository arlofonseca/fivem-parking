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
        data: {},
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
