import { Divider, Modal } from '@mantine/core';
import { useContext } from 'react';
import { AppContext, AppContextType } from '../../App';
import { locales } from '../../store/Locales';
import MenuButton from '../Button';

interface Props {
  opened: boolean;
  onClose: () => void;
  title?: string;
  onConfirm: () => void;
}

const ConfirmModal: React.FC<Props> = ({ opened, onClose, title, onConfirm }: Props) => {
  const { impoundOpen, impoundPrice, garagePrice } = useContext(AppContext) as AppContextType;

  return (
    <>
      <Modal
        centered
        opened={opened}
        onClose={onClose}
        title={title}
        classNames={{
          root: 'font-inter',
          body: 'bg-secondary',
          header: 'bg-secondary',
          title: 'font-inter font-bold',
        }}
      >
        <Divider className="mb-5" />
        <div className="flex flex-col gap-1 justify-center">
          <p className="text-sm">
            {locales.confirm.replace('{amount}', `$${impoundOpen ? impoundPrice : garagePrice}`)}
          </p>
          <div className="flex justify-end items-center gap-1 p-1">
            <MenuButton
              className="hover:-translate-y-[2px] hover:bg-transparent hover:border-blue text-blue transition-all"
              onClick={onConfirm}
            >
              {locales.retrieve}
            </MenuButton>
          </div>
        </div>
      </Modal>
    </>
  );
};

export default ConfirmModal;
