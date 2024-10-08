export default {
  env: {
    browser: true,
    es6: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2018,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", { "allowTemplateLiterals": true }],
  },
  overrides: [
    {
      files: ["index.js"],
      env: {
        node: true,
      },
      rules: {
        "no-undef": "off", // Ensures 'module' is not flagged
      },
    },
  ],
};
