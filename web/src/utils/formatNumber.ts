export const formatNumber: (number: number) => string = (number: number): string =>
    Intl.NumberFormat('en-us', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 }).format(number);
