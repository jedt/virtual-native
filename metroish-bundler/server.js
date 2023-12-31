const events = require("events");
const console = require("console");
const path = require("path");
const fs = require("fs");
const webpack = require("webpack");
const WebpackPlugin = require("./src/webpack-plugin");
const http = require("http");
const WebSocket = require("ws");

// Create an HTTP server
const server = http.createServer((req, res) => {
    if (req.url === "/download") {
        // Handle file download
        const filePath = "./dist/main.js";
        const stat = fs.statSync(filePath);

        res.writeHead(200, {
            "Content-Type": "text/plain",
            "Content-Length": stat.size,
            "Content-Disposition": "attachment; filename=main.js",
        });

        const readStream = fs.createReadStream(filePath);
        readStream.pipe(res);
    } else {
        // Handle other requests
        res.writeHead(200, { "Content-Type": "text/plain" });
        res.end("HTTP server running");
    }
});

// Initialize a WebSocket server instance
const wss = new WebSocket.Server({ noServer: true });

wss.on("connection", function connection(ws) {
    ws.on("message", function incoming(message) {
        console.log("received: %s", message);
    });

    ws.send("WebSocket server connected");
});

// Handle upgrade of the request
server.on("upgrade", function upgrade(request, socket, head) {
    if (request.url === "/websocket") {
        wss.handleUpgrade(request, socket, head, function done(ws) {
            wss.emit("connection", ws, request);
        });
    } else if (request.url === "/webpack") {
        wss.handleUpgrade(request, socket, head, function done(ws) {
            wss.emit("webpack_connection", ws, request);
        });
    } else {
        socket.destroy();
    }
});

// Start the server
server.listen(8080, () => {
    console.log("HTTP server listening on port 8080");
    function startWebpack() {
        const compiler = webpack({
            entry: "./src/app.ts",
            output: {
                path: path.resolve(__dirname, "dist"),
            },
            plugins: [
                // Add your plugins here
                // Learn more about plugins from https://webpack.js.org/configuration/plugins/
                new WebpackPlugin(),
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
        });
        compiler.watch(
            {
                aggregateTimeout: 300,
                poll: undefined,
            },
            (err) => {
                if (err) {
                    console.error(err);
                }

                // Access the compilation object directly
            },
        );
    }

    startWebpack();
});

//
// const wss = new WebSocket.Server({ port: 8080 });
const emitter = new events.EventEmitter();

emitter.on("publish", (data) => {
    if (data) {
        wss.clients.forEach((client) => {
            console.log("sending fetch notification to client");
            if (client.readyState === WebSocket.OPEN) {
                client.send("fetch");
            }
        });
    }
});
//
// wss.on("listening", () => {
//     console.log("WebSocket server listening on ws://localhost:8080");
//     function startWebpack() {
//         const compiler = webpack({
//             entry: "./src/app.ts",
//             output: {
//                 path: path.resolve(__dirname, "dist"),
//             },
//             plugins: [
//                 // Add your plugins here
//                 // Learn more about plugins from https://webpack.js.org/configuration/plugins/
//             ],
//             module: {
//                 rules: [
//                     {
//                         test: /\.(ts|tsx)$/i,
//                         loader: "ts-loader",
//                         exclude: ["/node_modules/"],
//                     },
//                     {
//                         test: /\.(eot|svg|ttf|woff|woff2|png|jpg|gif)$/i,
//                         type: "asset",
//                     },
//
//                     // Add your rules for custom modules here
//                     // Learn more about loaders from https://webpack.js.org/loaders/
//                 ],
//             },
//             resolve: {
//                 extensions: [".tsx", ".ts", ".jsx", ".js", "..."],
//             },
//         });
//         compiler.watch(
//             {
//                 aggregateTimeout: 300,
//                 poll: undefined,
//             },
//             (err) => {
//                 if (err) {
//                     console.error(err);
//                 }
//
//                 // Access the compilation object directly
//             },
//         );
//     }
//
//     startWebpack();
// });
//
wss.on("webpack_connection", (ws, req) => {
    const ip = req.socket.remoteAddress;
    console.log(`connection event ${ip}`);
    ws.on("message", (data) => {
        const parsedFromData = (data, isBinary) => {
            try {
                if (isBinary) {
                    return JSON.parse(data.toString());
                } else {
                    return JSON.parse(data);
                }
            } catch (e) {
                console.log(e);
            }
        };
        const parsed = parsedFromData(data, typeof data !== "string");
        const message = parsed.message;

        if (message === "emit-compilation") {
            //from webpack to the swift client
            if (parsed && parsed.content) {
                const compilationMsg = parsed.content;
                console.log(compilationMsg);
                emitter.emit("publish", compilationMsg);
            }
        }
    });

    ws.on("close", () => {
        console.log("Client disconnected");
    });
});
