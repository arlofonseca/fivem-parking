/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        red: '#c0392b',
        blue: '#2980b9',
        orange: '#ffc078'
      },
    },
  },
  plugins: [],
};
