import { Divider, Modal } from '@mantine/core';

interface Props {
  opened: boolean;
  onClose: () => void;
  title?: string;
  description?: JSX.Element;
  children?: React.ReactNode;
}

const InfoModal: React.FC<Props> = ({ opened, onClose, title, children }: Props) => {
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
          <div className="text-sm break-words text-sp tracking-wide leading-loose flex flex-col gap-1">
            <p>
              <span
                onClick={(): void => {
                  window.open('https://github.com/BerkieBb', '_blank');
                }}
                className="text-blue underline hover:cursor-pointer"
              >
                @BerkieBb
              </span>{' '}
              - Originally creating this amazing resource.
            </p>
            <p>
              <span
                className="text-blue underline hover:cursor-pointer"
                onClick={(): void => {
                  window.open('https://github.com/bebomusa', '_blank');
                }}
              >
                @bebomusa
              </span>{' '}
              - Diligently maintaining this project.
            </p>
            <p>
              <span
                className="text-blue underline hover:cursor-pointer"
                onClick={(): void => {
                  window.open('https://github.com/vipexv', '_blank');
                }}
              >
                @vipexv
              </span>{' '}
              - Crafting this beautiful user interface (NUI).
            </p>
            <Divider my={5} />
            <p className="leading-normal tracking-normal">
              Each individual's contribution has played a crucial role in the development and functionality of this
              system, making it a collaborative effort that we truly value and acknowledge.
            </p>
            <p
              className="ml-auto hover:text-blue hover:cursor-pointer"
              onClick={(): void => {
                window.open('https://github.com/bebomusa/bgarage/issues/new', '_blank');
              }}
            >
              🐛
            </p>
          </div>
        </div>
      </Modal>
    </>
  );
};

export default InfoModal;
