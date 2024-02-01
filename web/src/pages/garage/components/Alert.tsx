import { Box, createStyles, MantineTheme, Stack, Text, Transition, UseStylesOptions } from '@mantine/core';
import { useState } from 'react';

const useStyles: (
    params: void,
    options?: UseStylesOptions<string> | undefined
) => {
    classes: {
        wrapper: string;
        box: string;
    };
    cx: (...args: any) => string;
    theme: MantineTheme;
} = createStyles((theme: MantineTheme) => ({
    wrapper: {
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'flex-end',
        height: '100%',
        width: '100%',
    },

    box: {
        height: 'fit-content',
        width: 300,
        backgroundColor: theme.colors.dark[7],
        padding: 10,
        borderTopLeftRadius: theme.radius.sm,
        borderBottomLeftRadius: theme.radius.sm,
    },
}));

const Alert: React.FC = () => {
    const { classes } = useStyles();
    const [visible] = useState(false);

    return (
        <Transition mounted={visible} transition="slide-left">
            {(style: React.CSSProperties) => (
                <Box style={style} className={classes.wrapper}>
                    <Box className={classes.box}>
                        <Stack>
                            <Text align="center" size={20} weight={700}>
                                Lorem ipsum
                            </Text>
                            <Text align="center" color="teal" size={20} weight={700}>
                                Lorem ipsum
                            </Text>
                        </Stack>
                    </Box>
                </Box>
            )}
        </Transition>
    );
};

export default Alert;
