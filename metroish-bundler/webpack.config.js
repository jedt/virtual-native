const path = require('path');

module.exports = {
  module: {
    rules: [
      {
        test: /\.(?:js|mjs|cjs)$/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: [
              ['@babel/preset-react']
            ]
          }
        }
      }
    ]
  },
  mode: 'production',
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, './bin'),
    filename: 'main.js',
  },
};
