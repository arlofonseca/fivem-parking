import { Divider, Modal } from '@mantine/core';
import { useContext } from 'react';
import { AppContext, AppContextType } from '../App';
import Button from './Button';

interface Props {
  opened: boolean;
  onClose: () => void;
  title?: string;
  description?: string;
}

const InfoModal: React.FC<Props> = ({ opened, onClose, title, description }: Props) => {
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
          <p className="text-sm">{description}</p>
        </div>
      </Modal>
    </>
  );
};

export default InfoModal;
