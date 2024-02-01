import { Button, MantineTheme, Transition, UseStylesOptions, createStyles } from '@mantine/core';
import { Route, Routes } from 'react-router-dom';
import Navigation from './components/Navigation';
import { useExitListener } from './hooks/useExitListener';
import { useNuiEvent } from './hooks/useNuiEvent';
import Admin from './pages/admin';
import Garage from './pages/garage';
import Impound from './pages/impound';
import Map from './pages/map';
import Parking from './pages/parking';
import { isEnvBrowser } from './utils/misc';
import { useVisibility } from './utils/visibility';

const useStyles: (
    params: void,
    options?: UseStylesOptions<string> | undefined
) => {
    classes: {
        container: string;
    };
    cx: (...args: any) => string;
    theme: MantineTheme;
} = createStyles(
    (): {
        container: { width: string; height: string; display: 'flex'; justifyContent: 'center'; alignItems: 'center' };
    } => ({
        container: {
            width: '100%',
            height: '100%',
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
        },
    })
);

function App() {
    const { classes } = useStyles();
    const [visible, setVisible] = useVisibility(
        (state: { visible: boolean; setVisible: (value: boolean) => void }): [boolean, (value: boolean) => void] => [
            state.visible,
            state.setVisible,
        ]
    );

    useNuiEvent<{}>('bgarageDebug', (): void => {});

    useExitListener(setVisible);

    return (
        <div className={classes.container}>
            <Transition transition="slide-up" mounted={visible}>
                {(style: React.CSSProperties) => (
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
                                <Route path="/admin" element={<Admin />} />
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
                    onClick={(): void => {
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
