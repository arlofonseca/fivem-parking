import { ColorInput } from '@mantine/core';
import { useEffect, useState } from 'react';
import { useDebounce } from '../../../hooks/useDebounce';
import { useIsFirstRender } from '../../../hooks/useIsFirstRender';
import { useLocales } from '../../../providers/LocaleProvider';
import { fetchNui } from '../../../utils/fetchNui';
import { isEnvBrowser } from '../../../utils/misc';
import { useAppDispatch } from '../../../state';

const Color: React.FC = () => {
    const { locale } = useLocales();
    const isFirst = useIsFirstRender();
    const [primaryColor, setPrimaryColor] = useState('');
    const [secondaryColor, setSecondaryColor] = useState('');
    const debouncePrimaryColor = useDebounce(primaryColor);
    const debounceSecondaryColor = useDebounce(secondaryColor);
    const dispatch = useAppDispatch();

    useEffect(() => {
        if (isFirst) return;
        if (!isEnvBrowser()) fetchNui('changeColor', [debouncePrimaryColor, debounceSecondaryColor]);
        dispatch.vehicleColor.setColors([debounceSecondaryColor, debounceSecondaryColor]);
    }, [debouncePrimaryColor, debounceSecondaryColor]);

    return (
        <>
            <ColorInput
                label={'Primary color'}
                format="rgb"
                value={primaryColor}
                onChange={(value) => setPrimaryColor(value)}
                sx={{ width: '100%' }}
            />
            <ColorInput
                label={'Secondary color'}
                format="rgb"
                value={secondaryColor}
                onChange={(value) => setSecondaryColor(value)}
                sx={{ width: '100%' }}
            />
        </>
    );
};

export default Color;
