import { isEnvBrowser } from './misc';

/**
 * Asynchronously sends a POST request to a specified NUI event endpoint.
 *
 * @param eventName - The name of the NUI event.
 * @param data - The data to be sent with the POST request. Defaults to undefined.
 * @param mockData - Mock data to be returned when running in a browser environment. Defaults to undefined.
 * @returns A Promise that resolves to the formatted response data from the NUI event.
 */
export async function fetchNui<T = unknown>(eventName: string, data?: unknown, mockData?: T): Promise<false | T> {
  const options = {
    method: 'post',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: JSON.stringify(data),
  };

  if (isEnvBrowser()) {
    return mockData ?? false
  }

  const resourceName: any = (window as any).GetParentResourceName
    ? (window as any).GetParentResourceName()
    : 'nui-frame-app';
  const resp: Response = await fetch(`https://${resourceName}/${eventName}`, options);
  const respFormatted: any = await resp.json();

  return respFormatted;
}
