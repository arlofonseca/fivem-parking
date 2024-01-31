import { MantineTheme, Text, UseStylesOptions, createStyles } from '@mantine/core';
import dayjs from 'dayjs';
import relativeTime from 'dayjs/plugin/relativeTime';

dayjs.extend(relativeTime);

const useStyles: (
    params: void,
    options?: UseStylesOptions<string> | undefined
) => {
    classes: {
        user: string;
        item: string;
        icon: string;
        name: string;
    };
    cx: (...args: any) => string;
    theme: MantineTheme;
} = createStyles((theme: MantineTheme) => ({
    user: {
        display: 'block',
        width: '100%',
        color: theme.colorScheme === 'dark' ? theme.colors.dark[0] : theme.black,
    },

    item: {
        marginTop: 5,
        padding: 10,
        borderRadius: 5,
        backgroundColor: '#1d1e20',
        border: `0.1px solid rgb(42, 42, 42, 1)`,

        '&:hover': {
            backgroundColor: '#17181b',
        },
    },

    icon: {
        color: theme.colorScheme === 'dark' ? theme.colors.dark[3] : theme.colors.gray[5],
    },

    name: {
        fontFamily: `Greycliff CF, ${theme.fontFamily}`,
    },
}));

const ParkingTable: () => JSX.Element = () => {
    const { classes } = useStyles();

    // Todo
    return (
        <div className={classes.item}>
            <Text>Hello from ParkingTable!</Text>
        </div>
    );
};

export default ParkingTable;
