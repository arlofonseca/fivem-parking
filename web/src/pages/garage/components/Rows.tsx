import { ActionIcon, Tooltip } from '@mantine/core';
import { openConfirmModal, openModal } from '@mantine/modals';
import { TbEdit, TbTrash } from 'react-icons/tb';

interface Props {
    vehicle: boolean;
    model: string;
}

const Rows: React.FC<Props> = ({ vehicle, model }: Props) => {
    return (
        <tr style={{ textAlign: 'center' }}>
            <td>
                <Tooltip label="Edit" withArrow position="top" offset={10}>
                    <ActionIcon color="blue" variant="light" onClick={(): void => openModal({})}>
                        <TbEdit fontSize={20} />
                    </ActionIcon>
                </Tooltip>
            </td>
            <td>
                <Tooltip label="Lorem ipsum" withArrow position="top" offset={10}>
                    <ActionIcon color="red" variant="light" onClick={(): void => openConfirmModal({})}>
                        <TbTrash fontSize={20} />
                    </ActionIcon>
                </Tooltip>
            </td>
        </tr>
    );
};

export default Rows;
