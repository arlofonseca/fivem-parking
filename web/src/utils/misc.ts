export const isEnvBrowser: () => boolean = (): boolean => !(window as any).invokeNative;
export const noop: () => void = (): void => {};
