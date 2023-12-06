import WebSocket from 'ws';
import webpack from 'webpack';
import webpackConfig from './webpack.config'; // Import your Webpack config
import events from 'events';

// Function to start Webpack compilation

// Setup WebSocket Server
const wss = new WebSocket.Server({ port: 8080 });

//npm watch-webpack
function startWebpack() {
    const compiler = webpack(webpackConfig);
    compiler.watch({
        aggregateTimeout: 300,
        poll: undefined
    }, (err) => {
        if (err) {
            console.error(err);
        }

        // Access the compilation object directly
    });
}

const emitter = new events.EventEmitter();
emitter.on('publish', (data) => {
    if (data) {
        wss.clients.forEach((client) => {
            console.log('sending to client', client.readyState);
            if (client.readyState === WebSocket.OPEN) {
                client.send(data);
            }
        });
    }
});

wss.on('listening', () => {
    console.log('WebSocket server listening on ws://localhost:8080');
    startWebpack();
});

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
}

wss.on('connection', (ws) => {
    ws.on('message', (data) => {
        const parsed = parsedFromData(data, typeof data !== 'string');
        const message = parsed.message;

        if (message === 'emit-compilation') {
            //from webpack to the swift client
            if (parsed && parsed.content) {
                const compilation = parsed.content;
                emitter.emit('publish', compilation);
            }
        }
    });

    ws.on('close', () => {
        console.log('Client disconnected');
    });
});
