import { Box, Stack, NumberInput, ActionIcon, Group, Modal } from '@mantine/core';
import FilterSlider from '../../../components/FilterSlider';
import { TbFilter, TbReceipt2 } from 'react-icons/tb';
import { RootState, useAppDispatch, useAppSelector } from '../../../state';
import Search from './Search';
import { useState } from 'react';
import { useLocales } from '../../../providers/LocaleProvider';
import { FilterState } from '../../../state/models/filters';

const Filters: React.FC = () => {
    const { locale } = useLocales();
    const dispatch = useAppDispatch();
    const filterState = useAppSelector((state: RootState): FilterState => state.filters);
    const [open, setOpen] = useState(false);

    return (
        <>
            <Group sx={{ width: '100%' }} position="apart">
                <ActionIcon
                    variant="outline"
                    color="blue"
                    size="lg"
                    onClick={() => setOpen(true)}
                    sx={{ height: 36, width: 36 }}
                >
                    <TbFilter fontSize={20} />
                </ActionIcon>
                <Search />
            </Group>
            <Modal opened={open} onClose={() => setOpen(false)} size="xs" title={'Lorem ipsum'} closeOnEscape={false}>
                <Box mb={15}>
                    <Stack>
                        <NumberInput
                            label={'Lorem ipsum'}
                            hideControls
                            // value={filterState}
                            // onChange={(value) => dispatch.filters.setState({ key: 'price', value })}
                            icon={<TbReceipt2 fontSize={20} />}
                        />
                        <FilterSlider
                            label={'Lorem ipsum'}
                            min={0}
                            max={16}
                            value={0}
                            onChange={function (value: number): void {
                                throw new Error('Function not implemented.');
                            }} // value={filterState.types}
                            // onChange={(value) => dispatch.filters.setState({ key: 'seats', value })}
                        />
                        <FilterSlider
                            label={'Lorem ipsum'}
                            max={8}
                            min={0}
                            value={0}
                            onChange={function (value: number): void {
                                throw new Error('Function not implemented.');
                            }} // value={filterState.doors}
                            // onChange={(value) => dispatch.filters.setState({ key: 'doors', value })}
                        />
                    </Stack>
                </Box>
            </Modal>
        </>
    );
};

export default Filters;
