const TerserPlugin = require("terser-webpack-plugin");
const WebpackWebSocketPlugin = require("./src/webpack-plugin");
const path = require("path");

module.exports = {
  module: {
    rules: [
      {
        test: /\.(?:js|jsx|mjs|cjs)$/,
        use: {
          loader: "babel-loader",
          options: {
            presets: [["@babel/preset-react"]],
          },
        },
      },
    ],
  },
  mode: "development",
  entry: "./src/index.js",
  output: {
    path: path.resolve(__dirname, "./bin"),
    filename: "main.js",
  },
  plugins: [new WebpackWebSocketPlugin()],
  optimization: {
    minimize: false,
    minimizer: [
      new TerserPlugin({
        terserOptions: {
          format: {
            comments: false, // This removes all comments
          },
        },
        extractComments: false, // This prevents extracting comments to separate files
      }),
    ],
  },
};
