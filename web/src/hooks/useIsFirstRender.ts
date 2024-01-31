import { useRef } from 'react';

export const useIsFirstRender: () => boolean = (): boolean => {
    const isFirst: React.MutableRefObject<boolean> = useRef(true);

    if (isFirst.current) {
        isFirst.current = false;

        return true;
    }

    return isFirst.current;
};
