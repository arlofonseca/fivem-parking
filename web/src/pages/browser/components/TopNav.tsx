import { Select } from '@mantine/core';
import { useEffect } from 'react';
import { TbCar } from 'react-icons/tb';
import { useDebounce } from '../../../hooks/useDebounce';
import { useIsFirstRender } from '../../../hooks/useIsFirstRender';
import { useLocales } from '../../../providers/LocaleProvider';
import { RootState, useAppDispatch, useAppSelector } from '../../../state';
import Filters from './Filters';
import { FilterState } from '../../../state/models/filters';

const TopNav: React.FC<{ categories: string[] }> = ({ categories }: { categories: string[] }) => {
    const { locale } = useLocales();
    const isFirst: boolean = useIsFirstRender();
    const filters: FilterState = useAppSelector((state: RootState): FilterState => state.filters);
    const dispatch = useAppDispatch();
    const debouncedFilters: FilterState = useDebounce(filters);

    useEffect((): void => {
        if (isFirst) return;
        dispatch.filters.filterVehicles(filters);
    }, [debouncedFilters]);

    return (
        <>
            <Filters />
            <Select
                label={'Lorem ipsum'}
                icon={<TbCar fontSize={20} />}
                searchable
                clearable
                nothingFound={'Lorem ipsum'}
                // onChange={(value) => dispatch.filters.setState({ key: 'types', value })}
                // value={filters.types}
                data={categories}
                width="100%"
                styles={{
                    root: {
                        width: '100%',
                    },
                }}
            />
        </>
    );
};

export default TopNav;
