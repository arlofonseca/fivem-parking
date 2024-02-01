import { Button, Group, Modal, Text } from '@mantine/core';
import { fetchNui } from '../../../utils/fetchNui';

interface Props {
    opened: boolean;
    setOpened: (opened: boolean) => void;
    vehicle: boolean;
}

const Status: React.FC<Props> = ({ opened, setOpened, vehicle }: Props) => {
    const test: (opened: boolean) => void = setOpened;

    return (
        <Modal title="Purchase vehicle" opened={opened} onClose={(): void => setOpened(false)}>
            <Text></Text>

            <Group position="right" mt={10}>
                <Button uppercase variant="default" onClick={(): void => setOpened(false)}></Button>
                <Button
                    uppercase
                    color="green"
                    variant="light"
                    onClick={(): void => {
                        setOpened(false);
                        fetchNui('vehicleStatus', vehicle);
                    }}
                >
                    Confirm
                </Button>
            </Group>
        </Modal>
    );
};

export default Status;
