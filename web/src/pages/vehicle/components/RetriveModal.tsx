import { Button, Group, Modal, Text } from '@mantine/core';
import { useLocales } from '../../../providers/LocaleProvider';
import { fetchNui } from '../../../utils/fetchNui';
import { useAppDispatch } from '../../../state';
import { VehicleData } from '../../../state/models/vehicles';
import { formatNumber } from '../../../utils/formatNumber';

interface Props {
    opened: boolean;
    setOpened: (opened: boolean) => void;
    vehicle: VehicleData;
}

const RetrieveModal: React.FC<Props> = ({ opened, setOpened, vehicle }) => {
    const { locale } = useLocales();
    const dispatch = useAppDispatch();

    return (
        <Modal title="Purchase vehicle" opened={opened} onClose={() => setOpened(false)}>
            <Text>{'Confirm'.replace('%s', `${vehicle.make} ${vehicle.name}`).replace('%d', formatNumber(1))}</Text>

            <Group position="right" mt={10}>
                <Button uppercase variant="default" onClick={() => setOpened(false)}>
                    {'Cancel'}
                </Button>
                <Button
                    uppercase
                    color="green"
                    variant="light"
                    onClick={() => {
                        setOpened(false);
                        dispatch.visibility.setBrowserVisible(false);
                        dispatch.visibility.setVehicleVisible(false);
                        fetchNui('retrieveVehicle', vehicle);
                    }}
                >
                    {'Confirm'}
                </Button>
            </Group>
        </Modal>
    );
};

export default RetrieveModal;
