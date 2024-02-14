import { useState } from 'react';

export function useClipboard({ timeout = 2000 } = {}) {
  const [error, setError] = useState<Error | null>(null);
  const [copied, setCopied] = useState(false);
  const [copyTimeout, setCopyTimeout] = useState<number | null>(null);

  const handleCopyResult: (value: boolean) => void = (value: boolean): void => {
    window.clearTimeout(copyTimeout!);
    setCopyTimeout(window.setTimeout((): void => setCopied(false), timeout));
    setCopied(value);
  };

  const copy: (valueToCopy: any) => void = (valueToCopy: any): void => {
    if ('clipboard' in navigator) {
      navigator.clipboard
        .writeText(valueToCopy)
        .then((): void => handleCopyResult(true))
        .catch((err: any): void => setError(err));
    } else {
      setError(new Error('useClipboard: navigator.clipboard is not supported'));
    }
  };

  const reset: () => void = (): void => {
    setCopied(false);
    setError(null);
    window.clearTimeout(copyTimeout!);
  };

  return { copy, reset, error, copied };
}
