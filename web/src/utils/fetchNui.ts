import { isEnvBrowser } from './misc';

export async function fetchNui<T = unknown>(eventName: string, data?: unknown, mockData?: T): Promise<T> {
    const options = {
        method: 'post',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data),
    };

    if (isEnvBrowser() && mockData) return mockData;

    const resourceName: any = (window as any).GetParentResourceName
        ? (window as any).GetParentResourceName()
        : 'nui-frame-app';
    const resp: Response = await fetch(`https://${resourceName}/${eventName}`, options);
    const respFormatted: any = await resp.json();

    return respFormatted;
}
