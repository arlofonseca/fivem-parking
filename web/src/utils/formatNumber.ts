// https://github.com/overextended/ox_banking/blob/main/web/src/utils/formatNumber.ts
/**
 * Formats a given number as a currency in USD style.
 *
 * @param value - The numeric value to be formatted.
 * @returns A string representing the formatted currency value.
 */
export const formatNumber: (value: number) => string = (value: number): string => {
  return Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 }).format(value);
};
