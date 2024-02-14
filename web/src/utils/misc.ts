// Will return whether the current environment is in a regular browser
// and not CEF
export const isEnvBrowser: () => boolean = (): boolean => !(window as any).invokeNative;

// Basic no operation function
export const noop: () => void = (): void => {};
