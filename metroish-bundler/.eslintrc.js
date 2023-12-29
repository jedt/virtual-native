module.exports = {
    root: true,
    parser: 'hermes-eslint',
    plugins: [
    ],
    "env": {
        "browser": true,
        "es2021": true
    },
    "extends": [
        "eslint:recommended",
    ],
    "parserOptions": {
        "ecmaVersion": "latest",
        "sourceType": "module"
    },
    "rules": {
        // 'react/no-unstable-nested-components': 0,
        // 'prettier/prettier': 0,
        // 'no-unused-vars': 0,
        // 'eqeqeq': 0,
        // 'quotes': 0,
        // 'space-infix-ops': 0,
        // 'comma-dangle': 0,
        // 'react-native/no-inline-styles': 0,
        // 'react/self-closing-comp': 0,
        'no-undef': 'error',
    }
}
