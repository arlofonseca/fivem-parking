// https://github.com/overextended/ox_mdt/blob/master/web/src/layers/dev/Dev.tsx
import { ActionIcon, Button, Drawer, Select, Stack, Tooltip } from '@mantine/core';
import { IconTools } from '@tabler/icons-react';
import React from 'react';
import { useVisibility } from '../utils/visibility';
import { debugData } from '../utils/debugData';

export interface VehicleManagement {
    owner: string;
    plate: string;
    model: string;
    props: string;
    location: string;
    type: string;
}

const setBackground: (bg: string) => void = (bg: string): void => {
    const root: HTMLElement | null = document.getElementById('root');

    // https://i.imgur.com/iPTAdYV.png - Night
    // https://i.imgur.com/3pzRj9n.png - Day
    root!.style.backgroundImage = `url(${bg})`;
    root!.style.backgroundSize = 'cover';
    root!.style.backgroundRepeat = 'no-repeat';
    root!.style.backgroundPosition = 'center';
};

const Dev: React.FC = () => {
    const [opened, setOpened] = React.useState(false);
    const setVisible: {
        visible: boolean;
        setVisible: (value: boolean) => void;
    } = useVisibility();

    return (
        <>
            <Tooltip label="Developer Settings" position="bottom">
                <ActionIcon
                    onClick={(): void => setOpened(true)}
                    radius="xl"
                    variant="filled"
                    color="orange"
                    sx={{ position: 'absolute', bottom: 0, right: 0, width: 50, height: 50 }}
                    size="xl"
                    mr={50}
                    mb={50}
                >
                    <IconTools />
                </ActionIcon>
            </Tooltip>

            <Drawer
                position="left"
                onClose={(): void => setOpened(false)}
                opened={opened}
                title="Developer Settings"
                padding="xl"
                size="xs"
            >
                <Stack>
                    <Select
                        onChange={(val: string | null): void => setBackground(val as string)}
                        defaultValue="https://i.imgur.com/3pzRj9n.png"
                        data={[
                            { label: 'Day', value: 'https://i.imgur.com/3pzRj9n.png' },
                            { label: 'Night', value: 'https://i.imgur.com/iPTAdYV.png' },
                        ]}
                        label="Background"
                    />
                    <Button
                        onClick={(): boolean =>
                            useVisibility(
                                (prev: { visible: boolean; setVisible: (value: boolean) => void }): false => !prev
                            )
                        }
                    >
                        Toggle Vehicle Management Panel
                    </Button>
                    <Button
                        onClick={(): void =>
                            debugData<VehicleManagement>([
                                {
                                    action: 'management',
                                    data: {
                                        owner: '',
                                        plate: '',
                                        model: '',
                                        props: '',
                                        location: '',
                                        type: '',
                                    },
                                },
                            ])
                        }
                    >
                        Toggle Options
                    </Button>
                </Stack>
            </Drawer>
        </>
    );
};

export default Dev;
