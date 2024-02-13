import { useIntersection } from '@mantine/hooks';
import React from 'react';

export const useInfiniteScroll: (
    onIntersect: () => void,
    threshold?: number
) => {
    ref: (element: any) => void;
} = (onIntersect: () => void, threshold?: number): { ref: (element: any) => void } => {
    const lastElementRef: React.MutableRefObject<null> = React.useRef(null);
    const { ref, entry } = useIntersection({
        root: lastElementRef.current,
        threshold: threshold || 1.0,
    });

    React.useEffect((): void => {
        if (entry && entry.isIntersecting) {
            onIntersect();
        }
    }, [entry]);

    return { ref };
};
