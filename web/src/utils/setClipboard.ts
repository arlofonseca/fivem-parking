export const setClipboard: (value: string) => void = (value: string): void => {
    const textarea: HTMLTextAreaElement = document.createElement('textarea');
    textarea.value = value;
    textarea.style.position = 'fixed';
    textarea.style.opacity = '0';
    document.body.appendChild(textarea);
    textarea.select();
    try {
        document.execCommand('copy');
    } catch (err) {
        console.error('Unable to copy to clipboard:', err);
    } finally {
        document.body.removeChild(textarea);
    }
};
