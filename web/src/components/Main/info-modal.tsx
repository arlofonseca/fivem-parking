import { Divider, Modal } from '@mantine/core';

interface Props {
  opened: boolean;
  onClose: () => void;
  title?: string;
  description?: string;
}

const InfoModal: React.FC<Props> = ({ opened, onClose, title, description }: Props) => {
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
