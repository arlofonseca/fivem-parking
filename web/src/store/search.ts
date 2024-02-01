import create, { StoreApi, UseBoundStore } from 'zustand';

interface Props {
    value: string;
    setValue: (value: string) => void;
}

export const Search: UseBoundStore<StoreApi<Props>> = create<Props>(
    (
        set: (
            partial: Props | Partial<Props> | ((state: Props) => Props | Partial<Props>),
            replace?: boolean | undefined
        ) => void
    ) => ({
        value: '',
        setValue: (value: string): void => set({ value: value }),
    })
);
