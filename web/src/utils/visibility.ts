import { StoreApi, UseBoundStore, create } from 'zustand';

export const useVisibility: UseBoundStore<
    StoreApi<{
        visible: boolean;
        setVisible: (value: boolean) => void;
    }>
> = create<{ visible: boolean; setVisible: (value: boolean) => void }>((set) => ({
    visible: false,
    setVisible: (value: boolean): void => set({ visible: value }),
}));
