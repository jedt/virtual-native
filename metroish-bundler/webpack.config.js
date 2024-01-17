// Generated using webpack-cli https://github.com/webpack/webpack-cli
const webpack = require("webpack");
const path = require("path");
const WebpackPlugin = require("./src/webpack-plugin");

const isProduction = process.env.NODE_ENV == "production";

const config = {
    entry: "./src/app.ts",
    output: {
        path: path.resolve(__dirname, "dist"),
    },
    plugins: [
        // Add your plugins here
        // Learn more about plugins from https://webpack.js.org/configuration/plugins/
        new WebpackPlugin(),
        new webpack.SourceMapDevToolPlugin({}),
    ],
    module: {
        rules: [
            {
                test: /\.(ts|tsx)$/i,
                loader: "ts-loader",
                exclude: ["/node_modules/"],
            },
            {
                test: /\.(eot|svg|ttf|woff|woff2|png|jpg|gif)$/i,
                type: "asset",
            },

            // Add your rules for custom modules here
            // Learn more about loaders from https://webpack.js.org/loaders/
        ],
    },
    resolve: {
        extensions: [".tsx", ".ts", ".jsx", ".js", "..."],
    },
};

module.exports = () => {
    if (isProduction) {
        config.mode = "production";
    } else {
        config.mode = "development";
    }
    return config;
};
