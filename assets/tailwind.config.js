module.exports = {
  mode: "jit",
  purge: ["./js/**/*.js", "../lib/*_web/**/*.*ex"],
  theme: {
    extend: {},
  },
  darkMode: 'media',
  variants: {
    extend: {},
  },
  plugins: [
    require('daisyui'),
  ],
};

