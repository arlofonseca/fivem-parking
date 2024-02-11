// https://github.com/overextended/ox_banking/blob/main/web/src/utils/formatNumber.ts
export const formatNumber: (value: number) => string = (value: number): string => {
    return Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 }).format(value);
};
