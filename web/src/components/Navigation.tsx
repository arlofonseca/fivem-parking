import {
    Box,
    Collapse,
    Divider,
    Group,
    MantineTheme,
    Menu,
    Navbar,
    ScrollArea,
    Text,
    UnstyledButton,
    UseStylesOptions,
    createStyles,
    getStylesRef,
    rem,
} from '@mantine/core';
import {
    IconBriefcase,
    IconCar,
    IconChevronLeft,
    IconChevronRight,
    IconDoorExit,
    IconDotsVertical,
    IconFence,
    IconMap,
    IconAlertTriangle,
    IconPointFilled,
    IconSettings,
    TablerIconsProps,
} from '@tabler/icons-react';
import { useEffect, useState } from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import { fetchNui } from '../utils/fetchNui';
import { useVisibility } from '../utils/visibility';

const useStyles: (
    params: void,
    options?: UseStylesOptions<string> | undefined
) => {
    classes: {
        main: string;
        id: string;
        icon: string;
        active: string;
    };
    cx: (...args: any) => string;
    theme: MantineTheme;
} = createStyles((theme: MantineTheme) => ({
    main: {
        fontWeight: 500,
        display: 'block',
        width: '100%',
        padding: `${theme.spacing.xs} ${theme.spacing.xs}`,
        color: theme.colorScheme === 'dark' ? theme.colors.dark[0] : theme.black,
        fontSize: theme.fontSizes.sm,

        '&:hover': {
            borderRadius: theme.radius.sm,
            background: 'linear-gradient(90deg, rgba(48,67,119,0.5) 0%, rgba(187,187,187,0) 100%)',
            color: theme.colorScheme === 'dark' ? theme.white : theme.black,
        },
    },

    id: {
        ...theme.fn.focusStyles(),
        display: 'flex',
        alignItems: 'center',
        textDecoration: 'none',
        fontSize: theme.fontSizes.xs,
        color: theme.colors.gray[2],
        padding: `${theme.spacing.xs} ${theme.spacing.xs}`,
        fontWeight: 500,

        '&:hover': {
            borderRadius: theme.radius.sm,
            background: 'linear-gradient(90deg, rgba(48,67,119,0.5) 0%, rgba(187,187,187,0) 100%)',
            color: theme.colorScheme === 'dark' ? theme.white : theme.black,

            [`& .${getStylesRef('icon')}`]: {
                color: theme.colorScheme === 'dark' ? theme.white : theme.black,
            },
        },
    },

    icon: {
        ref: getStylesRef('icon'),
        color: theme.colorScheme === 'dark' ? theme.colors.dark[2] : theme.colors.gray[6],
        marginRight: theme.spacing.sm,
    },

    active: {
        '&, &:hover': {
            borderRadius: theme.radius.sm,
            background: 'linear-gradient(90deg, rgba(48,67,119,0.5) 0%, rgba(187,187,187,0) 100%)',
            [`& .${getStylesRef('icon')}`]: {
                color: 'white',
            },
        },
    },
}));

const pages: (
    | {
          id: string;
          label: string;
          icon: (props: TablerIconsProps) => JSX.Element;
          links?: undefined;
      }
    | {
          links: { id: string; label: string; icon: (props: TablerIconsProps) => JSX.Element }[];
          label: string;
          icon: (props: TablerIconsProps) => JSX.Element;
          id?: undefined;
      }
)[] = [
    {
        id: 'garage',
        label: 'Garage',
        icon: IconCar,
    },
    {
        id: 'impound',
        label: 'Impound',
        icon: IconFence,
    },
    // {
    // id: 'map',
    // label: 'Map',
    // icon: IconMap
    // },
    {
        id: 'parking',
        label: 'Parking Spots',
        icon: IconMap,
    },
    {
        id: 'admin',
        label: 'Admin Panel',
        icon: IconAlertTriangle,
    },
    {
        links: [{ id: 'status', label: 'Vehicle Status', icon: IconBriefcase }],
        label: 'Other',
        icon: IconPointFilled,
    },
];

const Navigation: () => JSX.Element = () => {
    const { classes, cx, theme } = useStyles();
    const [currentLink, setActiveLink] = useState('');
    const [opened, setOpened] = useState(false);
    const Icon: (props: TablerIconsProps) => JSX.Element = theme.dir === 'ltr' ? IconChevronRight : IconChevronLeft;
    const setVisible: (value: boolean) => void = useVisibility(
        (state: { visible: boolean; setVisible: (value: boolean) => void }): ((value: boolean) => void) =>
            state.setVisible
    );
    const location = useLocation();
    const links: JSX.Element[] = pages.map(
        (
            item:
                | {
                      id: string;
                      label: string;
                      icon: (props: TablerIconsProps) => JSX.Element;
                      links?: undefined;
                  }
                | {
                      links: { id: string; label: string; icon: (props: TablerIconsProps) => JSX.Element }[];
                      label: string;
                      icon: (props: TablerIconsProps) => JSX.Element;
                      link?: undefined;
                  }
        ) => (
            <>
                {item.links === undefined ? (
                    <NavLink
                        key={item.id}
                        to={`/${item.id}`}
                        onClick={(): void => {
                            setActiveLink(item.id);
                        }}
                        className={cx(classes.id, {
                            [classes.active]: currentLink === item.id,
                        })}
                    >
                        <item.icon className={classes.icon} stroke={1.5} />
                        <span>{item.label}</span>
                    </NavLink>
                ) : (
                    <>
                        <UnstyledButton
                            onClick={(): void => setOpened((o: boolean): boolean => !o)}
                            className={classes.main}
                        >
                            <Group position="apart" spacing={0}>
                                <Box sx={{ display: 'flex', alignItems: 'center' }}>
                                    <item.icon className={classes.icon} stroke={1.5} />
                                    <span>{item.label}</span>
                                </Box>
                                {item.links && <Icon />}
                            </Group>
                        </UnstyledButton>
                        {item.links ? (
                            <Collapse in={opened}>
                                {item.links.map(
                                    (id: {
                                        id: string;
                                        label: string;
                                        icon: (props: TablerIconsProps) => JSX.Element;
                                    }) => (
                                        <NavLink
                                            key={id.label}
                                            to={`/${id.id}`}
                                            onClick={(): void => {
                                                setActiveLink(id.id);
                                            }}
                                            className={cx(classes.id, {
                                                [classes.active]: currentLink === id.id,
                                            })}
                                            style={{
                                                marginLeft: rem(20),
                                                paddingLeft: rem(20),
                                                padding: `${theme.spacing.xs} ${theme.spacing.md}`,
                                                borderLeft: `${rem(1)} solid ${
                                                    theme.colorScheme === 'dark'
                                                        ? theme.colors.dark[4]
                                                        : theme.colors.gray[3]
                                                }`,
                                            }}
                                        >
                                            <id.icon className={classes.icon} stroke={1.5} />
                                            <span>{id.label}</span>
                                        </NavLink>
                                    )
                                )}
                            </Collapse>
                        ) : null}
                    </>
                )}
            </>
        )
    );

    useEffect((): void => {
        setActiveLink(location.pathname.split('/')[1]);
    }, [location]);

    return (
        <Navbar
            height={'100%'}
            width={{ sm: 300 }}
            p="xs"
            style={{ backgroundColor: '#242527', borderTopLeftRadius: 5, borderBottomLeftRadius: 5 }}
        >
            <Navbar.Section grow>
                <Divider my="sm" />
                <ScrollArea h={650} scrollbarSize={2}>
                    <Text size="xs" weight={500} color="dimmed" style={{ margin: 8 }}>
                        Options
                    </Text>
                    {links}
                </ScrollArea>
            </Navbar.Section>
            <Box
                sx={{
                    paddingTop: 5,
                    borderTop: `${rem(1)} solid ${theme.colorScheme === 'dark' ? theme.colors.dark[4] : theme.colors.gray[2]}`,
                }}
            >
                <Menu shadow="md" width={200} withArrow position="top-end">
                    <Menu.Target>
                        <UnstyledButton
                            sx={{
                                display: 'block',
                                width: '100%',
                                padding: theme.spacing.xs,
                                borderRadius: theme.radius.sm,
                                color: theme.colorScheme === 'dark' ? theme.colors.dark[0] : theme.black,

                                '&:hover': {
                                    backgroundColor:
                                        theme.colorScheme === 'dark' ? theme.colors.dark[7] : theme.colors.gray[0],
                                },
                            }}
                        >
                            <Group>
                                <Box sx={{ flex: 1 }}>
                                    <Text size="sm" weight={750}></Text>
                                    <Text color="dimmed" size="xs"></Text>
                                    Vehicle Management
                                </Box>
                                <IconDotsVertical size={rem(20)} />
                            </Group>
                        </UnstyledButton>
                    </Menu.Target>

                    <Menu.Dropdown>
                        <Menu.Item icon={<IconSettings size={14} />}>
                            <NavLink to={`/configuration`} style={{ textDecoration: 'none', color: '#C1C2C5' }}>
                                Settings
                            </NavLink>
                        </Menu.Item>
                        <Menu.Item
                            icon={<IconDoorExit size={14} />}
                            onClick={(): void => {
                                setVisible(false);
                                fetchNui('exit');
                            }}
                        >
                            Leave
                            {}
                        </Menu.Item>
                    </Menu.Dropdown>
                </Menu>
            </Box>
        </Navbar>
    );
};

export default Navigation;
