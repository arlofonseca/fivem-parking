import { Button, NumberInput, Select, Stack } from '@mantine/core';
import { useRef, useState } from 'react';
import { TbCar, TbTag } from 'react-icons/tb';

interface Props {
    setLocationSlots: React.Dispatch<React.SetStateAction<null[]>>;
    index: number;
}

const Location: React.FC<Props> = ({ setLocationSlots, index }: Props) => {
    const ref: React.MutableRefObject<HTMLInputElement | null> = useRef<HTMLInputElement | null>(null);
    const [vehicles] = useState<{ label: string; value: string }[]>([]);

    return (
        <Stack>
            <Select data={vehicles} icon={<TbCar size={20} />} />
            <NumberInput
                label="Lorem ipsum"
                ref={ref}
                description="Lorem ipsum"
                hideControls
                icon={<TbTag size={20} />}
            />
            <Button uppercase fullWidth variant="light" onClick={(): void => {}}>
                Confirm
            </Button>
        </Stack>
    );
};

export default Location;
