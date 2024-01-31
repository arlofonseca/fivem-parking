import { MantineTheme, Text, UseStylesOptions, createStyles } from '@mantine/core';
import dayjs from 'dayjs';
import relativeTime from 'dayjs/plugin/relativeTime';

dayjs.extend(relativeTime);

const useStyles: (
    params: void,
    options?: UseStylesOptions<string> | undefined
) => {
    classes: {
        main: string;
    };
    cx: (...args: any) => string;
    theme: MantineTheme;
} = createStyles((theme: MantineTheme) => ({
    main: {
        display: 'block',
        width: '20%',
        height: '20%',
        color: theme.colorScheme === 'dark' ? theme.colors.dark[0] : theme.black,
        fontFamily: `Greycliff CF, ${theme.fontFamily}`,
        marginTop: 5,
        padding: 10,
        borderRadius: 5,
        backgroundColor: '#1d1e20',
        border: `0.1px solid rgb(42, 42, 42, 1)`,

        '&:hover': {
            backgroundColor: '#17181b',
        },
    },
}));

const ParkingTable: () => JSX.Element = () => {
    const { classes } = useStyles();

    // Todo
    return (
        <div className={classes.main}>
            <Text>Hello from ParkingTable!</Text>
        </div>
    );
};

export default ParkingTable;
