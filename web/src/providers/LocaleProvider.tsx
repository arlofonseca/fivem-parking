import { Context, createContext, useContext, useEffect, useState } from 'react';
import { useIsFirstRender } from '../hooks/useIsFirstRender';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { debugData } from '../utils/debugData';
import { fetchNui } from '../utils/fetchNui';
import { isEnvBrowser } from '../utils/misc';

debugData([
    {
        action: 'setLocale',
        data: {
            ui: {
                // todo
            },
        },
    },
]);

interface Locale {
    ui: {
        // todo
    };
}

interface LocaleContextValue {
    locale: Locale;
    setLocale: (locales: Locale) => void;
}

const LocaleCtx: Context<LocaleContextValue | null> = createContext<LocaleContextValue | null>(null);

const LocaleProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const isFirst: boolean = useIsFirstRender();
    const [locale, setLocale] = useState<Locale>({
        ui: {
            // todo
        },
    });

    useEffect((): void => {
        if (!isFirst && !isEnvBrowser()) return;
        fetchNui('loadLocale');
    }, []);

    useNuiEvent('setLocale', async (data: Locale): Promise<void> => setLocale(data));

    return <LocaleCtx.Provider value={{ locale, setLocale }}>{children}</LocaleCtx.Provider>;
};

export default LocaleProvider;

export const useLocales: () => LocaleContextValue = (): LocaleContextValue =>
    useContext<LocaleContextValue>(LocaleCtx as Context<LocaleContextValue>);
