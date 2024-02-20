/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: "hsl(var(--background))",
        secondary: "hsl(var(--secondary))",
        bordercolor: "hsl(var(--border))",
        red: '#c0392b',
        blue: '#2980b9',
        orange: '#ffc078',
      },
    },
  },
  plugins: [],
};
