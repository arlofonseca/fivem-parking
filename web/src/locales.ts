// https://github.com/overextended/ox_mdt/blob/master/web/src/locales.ts
import { printf } from 'fast-printf';
import locale from '../../locales/en.json';
import { isEnvBrowser } from './utils/misc';

const locales: Record<string, string | number> = {};

declare global {
    interface String {
        format(...args: any[]): string;
    }
}

String.prototype.format = function (...args: any[]): string {
    return printf(this as string, ...args);
};

export function setLocale(data: typeof locale) {
    for (const key in locales) locales[key] = key;
    for (const [key, value] of Object.entries(data)) {
        locales[key] = value;
    }
}

if (isEnvBrowser()) {
    for (const [key, value] of Object.entries(locale)) {
        locales[key] = value;
    }
}

export default locales as typeof locale;
