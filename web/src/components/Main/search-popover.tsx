import { Popover, TextInput } from '@mantine/core';
import { Search } from 'lucide-react';
import React from 'react';
import Button from './button';

interface Props {
  className?: string;
  onChange?: (e: React.ChangeEvent<HTMLInputElement>) => void;
}

const SearchPopover: React.FC<Props> = ({ className, onChange }: Props) => {
  return (
    <>
      <Popover
        classNames={{
          dropdown: '!bg-[#1a1b1e] !p-1 font-inter text-blue',
        }}
        width={200}
        transitionProps={{
          transition: 'scale-y',
        }}
        trapFocus
        position="bottom"
        withArrow
        shadow="md"
      >
        <Popover.Target>
          <div className="hover:cursor-pointer">
            <Button
              Icon={Search}
              className="mr-1 hover:bg-transparent hover:border-blue !px-2 !py-[7px] rounded-[2px]"
            ></Button>
          </div>
        </Popover.Target>
        <Popover.Dropdown>
          <TextInput
            classNames={{
              input: 'font-inter bg-[#25262b] border-none',
            }}
            onChange={onChange}
            placeholder="Search"
            size="xs"
          />
        </Popover.Dropdown>
      </Popover>
    </>
  );
};

export default SearchPopover;
