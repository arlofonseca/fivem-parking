import { Input } from '@mantine/core';
import { TbSearch } from 'react-icons/tb';
import { RootState, useAppDispatch, useAppSelector } from '../../../state';
import { FilterState } from '../../../state/models/filters';

const Search: React.FC = () => {
    const filterState = useAppSelector((state: RootState): FilterState => state.filters);
    const dispatch = useAppDispatch();

    return (
        <>
            <Input
                icon={<TbSearch />}
                // value={filterState.search}
                // onChange={(e: React.ChangeEvent<HTMLInputElement>) =>
                // dispatch.filters.setState({ key: 'search', value: e.target.value })
                // }
            />
        </>
    );
};

export default Search;
