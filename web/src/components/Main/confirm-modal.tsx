import { Divider, Modal } from '@mantine/core';
import Button from './button';
import { useState } from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';

interface Props {
    opened: boolean;
    onClose: () => void;
    title?: string;
    onConfirm: () => void;
}

const ConfirmModal: React.FC<Props> = ({ opened, onClose, title, onConfirm }) => {
    const [price, setPrice] = useState(500);

    useNuiEvent('nui:state:price', setPrice);

    return (
        <>
            <Modal
                centered
                opened={opened}
                onClose={onClose}
                title={title}
                classNames={{
                    root: 'font-inter',
                    body: 'bg-[#1a1b1e]',
                    header: 'bg-[#1a1b1e]',
                    title: 'font-inter font-bold',
                }}
            >
                <Divider className="mb-5" />
                <div className="flex flex-col gap-1 justify-center">
                    <p className="text-sm">
                        Are you sure you want to take this vehicle out of the impound for <strong>${price}</strong>?
                    </p>
                    <div className="flex justify-end items-center gap-1 p-1">
                        <Button className="hover:-translate-y-[2px] transition-all" onClick={onConfirm}>
                            Continue
                        </Button>
                    </div>
                </div>
            </Modal>
        </>
    );
};

export default ConfirmModal;
