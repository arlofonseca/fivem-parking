/** @type {import('tailwindcss').Config} */
export default {
    content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
    theme: {
        extend: {
            colors: {
                red: '#f25056',
                neon: '#2fffd2',
            },
        },
    },
    plugins: [],
};
