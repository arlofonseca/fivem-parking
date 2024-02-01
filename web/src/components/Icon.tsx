// https://github.com/overextended/ox_vehicledealer/blob/main/web/src/components/IconGroup.tsx
import { Group, Text } from '@mantine/core';
import { IconBaseProps } from 'react-icons';

interface Props {
    label: string | number;
    Icon: React.ComponentType<IconBaseProps>;
    style?: React.CSSProperties;
    textColor?: string;
}

const Icon: React.FC<Props> = ({ label, Icon, style, textColor }: Props) => {
    return (
        <>
            <Group spacing={5} position="left" style={style}>
                <Icon fontSize={20} />
                <Text sx={{ lineHeight: '20px' }} color={textColor}>
                    {label}
                </Text>
            </Group>
        </>
    );
};

export default Icon;
