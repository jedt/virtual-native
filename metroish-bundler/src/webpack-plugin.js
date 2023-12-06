const WebSocket = require('ws');
function WebpackWebSocketPlugin(options = {}) {
    return {
        apply(compiler) {
            compiler.hooks.beforeCompile.tap('WebpackWebSocketPlugin', () => {
                // This function will be executed before the compilation starts
                console.log('WebpackWebSocketPlugin: beforeCompile');
            });
            compiler.hooks.emit.tapAsync('WebpackWebSocketPlugin', (compilation, callback) => {
                const bundleFilename = 'main.js';
                const bundleContent = compilation.assets[bundleFilename].source();

                const ws = new WebSocket('ws://localhost:8080');
                ws.on('open', () => {
                    ws.send(JSON.stringify({
                        message: 'emit-compilation',
                        content: bundleContent,
                    }));
                });

                setTimeout(() => {
                    callback();
                });
            });
        }
    };
}

module.exports = WebpackWebSocketPlugin;
