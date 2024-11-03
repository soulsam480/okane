/** @type {import('tailwindcss').Config} */
export default {
  content: ["./priv/ui/**/*.{js,html}"],
  theme: {
    extend: {},
  },
  plugins: [require("daisyui")],
};
