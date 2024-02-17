import { MantineProvider } from '@mantine/core';
import '@mantine/core/styles.css';
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './index.scss';
import { isEnvBrowser } from './utils/misc';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <MantineProvider defaultColorScheme="dark">
      <App />
    </MantineProvider>
  </React.StrictMode>
);

// https://github.com/overextended/ox_mdt/blob/master/web/src/main.tsx#L44
if (isEnvBrowser()) {
  const root: HTMLElement | null = document.getElementById('root');

  root!.style.backgroundImage = 'url("https://i.imgur.com/iPTAdYV.png")'; // Night time image
  // root!.style.backgroundImage = 'url("https://i.imgur.com/3pzRj9n.png")'; // Day time image
  root!.style.backgroundSize = 'cover';
  root!.style.backgroundRepeat = 'no-repeat';
  root!.style.backgroundPosition = 'center';
}
