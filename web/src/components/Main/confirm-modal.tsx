import { Divider, Modal } from '@mantine/core';
import { useContext, useState } from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import Button from './Button';
import { AppContext, AppContextType } from '../App';

interface Props {
  opened: boolean;
  onClose: () => void;
  title?: string;
  onConfirm: () => void;
}

const ConfirmModal: React.FC<Props> = ({ opened, onClose, title, onConfirm }: Props) => {
  const { impoundPrice } = useContext(AppContext) as AppContextType;
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
            {' '}
            Please confirm the deduction of <strong>${impoundPrice}</strong> as payment for your vehicle.{' '}
          </p>
          <div className="flex justify-end items-center gap-1 p-1">
            <Button
              className="hover:-translate-y-[2px] hover:bg-transparent hover:border-blue text-blue transition-all"
              onClick={onConfirm}
            >
              {' '}
              Retrieve{' '}
            </Button>
          </div>
        </div>
      </Modal>
    </>
  );
};

export default ConfirmModal;
