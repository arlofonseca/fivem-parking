import { ActionIcon, Button, Drawer, Stack, Tooltip } from '@mantine/core';
import { FaWrench } from 'react-icons/fa';
import { useState } from 'react';
import { debugData } from '../../utils/debugData';

const Dev: React.FC = () => {
    const [opened, setOpened] = useState(false);

    return (
        <>
            <Tooltip label="Options" position="bottom">
                <ActionIcon
                    onClick={() => setOpened(true)}
                    radius="xl"
                    variant="filled"
                    color="orange"
                    sx={{ position: 'absolute', bottom: 0, right: 0, width: 50, height: 50 }}
                    size="xl"
                    mr={50}
                    mb={50}
                >
                    <FaWrench size={24} />
                </ActionIcon>
            </Tooltip>

            <Drawer opened={opened} onClose={() => setOpened(false)} title="Options" padding="md">
                <Stack>
                    <Button
                        onClick={() =>
                            debugData([
                                {
                                    action: 'setVisible',
                                    data: { visible: true, categories: [0, 1, 2, 3, 4], types: { automobile: true } },
                                },
                            ])
                        }
                    >
                        Garage
                    </Button>
                    <Button
                        onClick={() => {
                            debugData([
                                {
                                    action: 'setAdminVisible',
                                    data: [
                                        {
                                            id: 1,
                                            model: 'blista',
                                            plate: 'XYZD3112',
                                        },
                                        {
                                            id: 2,
                                            model: 'dominator',
                                            plate: 'YXZE1221',
                                        },
                                    ],
                                },
                            ]);
                        }}
                    >
                        Impound
                    </Button>
                    <Button
                        onClick={() => {
                            debugData([
                                {
                                    action: 'setStatsVisible',
                                    data: {
                                        name: 'Blista',
                                        class: 0,
                                        make: 'Dinka',
                                        type: 'automobile',
                                    },
                                },
                            ]);
                        }}
                    >
                        Map
                    </Button>
                </Stack>
            </Drawer>
        </>
    );
};

export default Dev;
