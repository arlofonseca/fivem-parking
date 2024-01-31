import { Button, Transition, createStyles } from '@mantine/core';
import { Route, Routes } from 'react-router-dom';
import Navigation from './components/Navigation';
import { useExitListener } from './hooks/useExitListener';
import { useNuiEvent } from './hooks/useNuiEvent';
import Garage from './pages/garage';
import Impound from './pages/impound';
import Map from './pages/map';
import Parking from './pages/parking';
import { Locale } from './utils/locale';
import { isEnvBrowser } from './utils/misc';
import { useVisibility } from './utils/visibilityStore';

const useStyles = createStyles(() => ({
    container: {
        width: '100%',
        height: '100%',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
    },
}));

function App() {
    const { classes } = useStyles();
    const [visible, setVisible] = useVisibility((state) => [state.visible, state.setVisible]);

    useNuiEvent<{
        locale: { [key: string]: string };
    }>('bgarageDebug', (data) => {
        for (const name in data.locale) Locale[name] = data.locale[name];
    });

    useExitListener(setVisible);

    return (
        <div className={classes.container}>
            <Transition transition="slide-up" mounted={visible}>
                {(style) => (
                    <div style={{ ...style, display: 'flex', width: '50%', margin: 50, height: 700 }}>
                        <Navigation />
                        <div
                            style={{
                                backgroundColor: '#1c1d1f',
                                width: 750,
                                borderTopRightRadius: 5,
                                borderBottomRightRadius: 5,
                            }}
                        >
                            <Routes>
                                <Route path="/garage" element={<Garage />} />
                                <Route path="/impound" element={<Impound />} />
                                <Route path="/map" element={<Map />} />
                                <Route path="/parking" element={<Parking />} />
                            </Routes>
                        </div>
                    </div>
                )}
            </Transition>
            {!visible && isEnvBrowser() && (
                <Button
                    style={{ color: 'white', position: 'absolute' }}
                    variant="default"
                    onClick={() => {
                        setVisible(true);
                    }}
                >
                    Manage Vehicles
                </Button>
            )}
        </div>
    );
}

export default App;
