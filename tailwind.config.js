import daisyui from 'daisyui';

/** @type {import('tailwindcss').Config} */
export default {
  content: ["./priv/ui/**/*.{js,html}"],
  theme: {
    extend: {},
  },
  plugins: [daisyui],
};
