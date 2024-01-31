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
    IconPointFilled,
    IconSettings,
} from '@tabler/icons-react';
import { useEffect, useState } from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import { Locale } from '../store/locale';
import { useVisibility } from '../store/visibilityStore';
import { fetchNui } from '../utils/fetchNui';

const useStyles: (params: void, options?: UseStylesOptions<string> | undefined) => {
    classes: {
        control: string;
        link: string;
        linkIcon: string;
        linkActive: string;
        chevron: string;
    };
    cx: (...args: any) => string;
    theme: MantineTheme;
}
 = createStyles((theme: MantineTheme) => ({
    control: {
        fontWeight: 500,
        display: 'block',
        width: '100%',
        padding: `${theme.spacing.xs} ${theme.spacing.xs}`,
        color: theme.colorScheme === 'dark' ? theme.colors.dark[0] : theme.black,
        fontSize: theme.fontSizes.sm,

        '&:hover': {
            borderRadius: theme.radius.sm,
            background: 'linear-gradient(90deg, rgba(51,124,255,0.5) 0%, rgba(187,187,187,0) 100%)',
            color: theme.colorScheme === 'dark' ? theme.white : theme.black,
        },
    },

    link: {
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
            background: 'linear-gradient(90deg, rgba(51,124,255,0.5) 0%, rgba(187,187,187,0) 100%)',
            color: theme.colorScheme === 'dark' ? theme.white : theme.black,

            [`& .${getStylesRef('icon')}`]: {
                color: theme.colorScheme === 'dark' ? theme.white : theme.black,
            },
        },
    },

    linkIcon: {
        ref: getStylesRef('icon'),
        color: theme.colorScheme === 'dark' ? theme.colors.dark[2] : theme.colors.gray[6],
        marginRight: theme.spacing.sm,
    },

    linkActive: {
        '&, &:hover': {
            borderRadius: theme.radius.sm,
            background: 'linear-gradient(90deg, rgba(51,124,255,0.5) 0%, rgba(187,187,187,0) 100%)',
            [`& .${getStylesRef('icon')}`]: {
                color: 'white',
            },
        },
    },

    chevron: {
        transition: 'transform 200ms ease',
    },
}));

const pages = [
    { link: 'garage', label: 'Garage', icon: IconCar },
    { link: 'impound', label: 'Impound', icon: IconCar },
    {
        links: [{ link: 'activity', label: 'Recent Activity', icon: IconBriefcase }],
        label: 'Other',
        icon: IconPointFilled,
    },
];

const NavMenu = () => {
    const { classes, cx, theme } = useStyles();
    const [ currentLink, setActiveLink ] = useState('');
    const [ opened, setOpened ] = useState(false);
    const ChevronIcon = theme.dir === 'ltr' ? IconChevronRight : IconChevronLeft;
    const setVisible = useVisibility((state) => state.setVisible);
    const location = useLocation();
    const links = pages.map((item) => (
        <>
            {item.links === undefined ? (
                <NavLink
                    key={item.link}
                    to={`/${item.link}`}
                    onClick={() => {
                        setActiveLink(item.link);
                    }}
                    className={cx(classes.link, {
                        [classes.linkActive]: currentLink === item.link,
                    })}
                >
                    <item.icon className={classes.linkIcon} stroke={1.5} />
                    <span>{item.label}</span>
                </NavLink>
            ) : (
                <>
                    <UnstyledButton onClick={() => setOpened((o) => !o)} className={classes.control}>
                        <Group position="apart" spacing={0}>
                            <Box sx={{ display: 'flex', alignItems: 'center' }}>
                                <item.icon className={classes.linkIcon} stroke={1.5} />
                                <span>{item.label}</span>
                            </Box>
                            {item.links && (
                                <ChevronIcon
                                    className={classes.chevron}
                                    size="1rem"
                                    stroke={1.5}
                                    style={{
                                        transform: opened ? `rotate(${theme.dir === 'rtl' ? -90 : 90}deg)` : 'none',
                                    }}
                                />
                            )}
                        </Group>
                    </UnstyledButton>
                    {item.links ? (
                        <Collapse in={opened}>
                            {item.links.map((link) => (
                                <NavLink
                                    key={link.label}
                                    to={`/${link.link}`}
                                    onClick={() => {
                                        setActiveLink(link.link);
                                    }}
                                    className={cx(classes.link, {
                                        [classes.linkActive]: currentLink === link.link,
                                    })}
                                    style={{
                                        marginLeft: rem(20),
                                        paddingLeft: rem(20),
                                        padding: `${theme.spacing.xs} ${theme.spacing.md}`,
                                        borderLeft: `${rem(1)} solid ${
                                            theme.colorScheme === 'dark' ? theme.colors.dark[4] : theme.colors.gray[3]
                                        }`,
                                    }}
                                >
                                    <link.icon className={classes.linkIcon} stroke={1.5} />
                                    <span>{link.label}</span>
                                </NavLink>
                            ))}
                        </Collapse>
                    ) : null}
                </>
            )}
        </>
    ));

    useEffect(() => {
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
                        Pages
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
                                    <Text size="sm" weight={500}></Text>
                                    <Text color="dimmed" size="xs"></Text>
                                </Box>

                                <IconDotsVertical size={rem(18)} />
                            </Group>
                        </UnstyledButton>
                    </Menu.Target>

                    <Menu.Dropdown>
                        <Menu.Item icon={<IconSettings size={14} />}>
                            <NavLink to={`/configuration`} style={{ textDecoration: 'none', color: '#C1C2C5' }}>
                                <span>Settings</span>
                            </NavLink>
                        </Menu.Item>
                        <Menu.Item
                            icon={<IconDoorExit size={14} />}
                            onClick={() => {
                                setVisible(false);
                                fetchNui('exit');
                            }}
                        >
                            {Locale.ui_logout}
                        </Menu.Item>
                    </Menu.Dropdown>
                </Menu>
            </Box>
        </Navbar>
    );
};

export default NavMenu;
