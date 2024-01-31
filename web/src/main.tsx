import { StrictMode } from 'react';
import ReactDOM from 'react-dom/client';
import { theme } from './theme';
import { MantineProvider } from '@mantine/core';
import App from './App';
import './index.css';
import { isEnvBrowser } from './utils/misc';
import { Provider } from 'react-redux';
import { store } from './state';
import LocaleProvider from './providers/LocaleProvider';
import { HashRouter } from 'react-router-dom';
import { fetchNui } from './utils/fetchNui';
import { ModalsProvider } from '@mantine/modals';

if (isEnvBrowser()) {
    const root = document.getElementById('root');

    root!.style.backgroundImage = 'url("")';
    root!.style.backgroundSize = 'cover';
    root!.style.backgroundRepeat = 'no-repeat';
    root!.style.backgroundPosition = 'center';
}

ReactDOM.createRoot(document.getElementById('root')!).render(
    <StrictMode>
        <HashRouter>
            <MantineProvider theme={theme} withGlobalStyles withNormalizeCSS>
                <Provider store={store}>
                    <LocaleProvider>
                        <ModalsProvider
                            modalProps={{
                                size: 'xs',
                                centered: true,
                                transition: 'slide-up',
                                // Modals would overflow the page with slide-up transition
                                styles: { inner: { overflow: 'hidden' } },
                            }}
                        >
                            <App />
                        </ModalsProvider>
                    </LocaleProvider>
                </Provider>
            </MantineProvider>
        </HashRouter>
    </StrictMode>
);
