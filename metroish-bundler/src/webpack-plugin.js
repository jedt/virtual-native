const WebSocket = require("ws");
function WebpackWebSocketPlugin(options = {}) {
    return {
        apply(compiler) {
            compiler.hooks.beforeCompile.tap("WebpackWebSocketPlugin", () => {
                // This function will be executed before the compilation starts
                console.log("WebpackWebSocketPlugin: beforeCompile");
            });
            compiler.hooks.emit.tapAsync(
                "WebpackWebSocketPlugin",
                (compilation, callback) => {
                    const ws = new WebSocket("ws://127.0.0.1:8080/webpack");
                    ws.on("open", () => {
                        ws.send(
                            JSON.stringify({
                                message: "emit-compilation",
                                content: "fetch",
                            }),
                        );
                    });

                    setTimeout(() => {
                        callback();
                    });
                },
            );
        },
    };
}

module.exports = WebpackWebSocketPlugin;
