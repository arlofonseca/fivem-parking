// todo: admin panel should allow users with ace to overlook all owned vehicles / impounded vehicles for easier management
export type AdminData = {
    owner: string;
    plate: string;
    model: string;
    props: string;
    location: string;
    type: string;
};
