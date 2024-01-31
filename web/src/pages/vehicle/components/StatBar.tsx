import { Stack, Progress, Text } from '@mantine/core';

interface Props {
    label: string;
    value: number;
}

const StatBar: React.FC<Props> = ({ label, value: data }) => {
    return (
        <>
            <Stack sx={{ width: '100%' }} spacing={1}>
                <Text>{label}</Text>
                <Progress value={data} />
            </Stack>
        </>
    );
};

export default StatBar;
