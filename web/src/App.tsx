import { Button, Transition, createStyles } from '@mantine/core';
import { Route, Routes } from 'react-router-dom';
import NavMenu from './components/Navigation';
import { useExitListener } from './hooks/useExitListener';
import { useNuiEvent } from './hooks/useNuiEvent';
import Garage from './pages/garage';
import { Locale } from './store/locale';
import { useVisibility } from './store/visibilityStore';
import { isEnvBrowser } from './utils/misc';

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
                    <div style={{ ...style, display: 'flex', width: '100%', margin: 50, height: 920 }}>
                        <NavMenu />
                        <div
                            style={{
                                backgroundColor: '#1c1d1f',
                                width: 1520,
                                borderTopRightRadius: 5,
                                borderBottomRightRadius: 5,
                            }}
                        >
                            <Routes>
                                <Route path="/garage" element={<Garage />} />
                            </Routes>
                        </div>
                    </div>
                )}
            </Transition>
            {!visible && isEnvBrowser() && (
                <Button
                    style={{ color: 'black', position: 'absolute' }}
                    variant="default"
                    onClick={() => {
                        setVisible(true);
                    }}
                >
                    Open
                </Button>
            )}
        </div>
    );
}

export default App;
