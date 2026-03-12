const http = require('http');

const PORT = process.env.PORT || 2000;
const TARGET_HOST = '127.0.0.1';
const TARGET_PORT = 3000;
const SECRET = process.env.EXECUTION_SECRET;

if (!SECRET) {
    console.error('FATAL: EXECUTION_SECRET environment variable is not set!');
    process.exit(1);
}

const server = http.createServer((req, res) => {
    // Security Check: Verify Bearer Token
    const authHeader = req.headers['authorization'];
    if (!authHeader || authHeader !== `Bearer ${SECRET}`) {
        console.warn(`Unauthorized access attempt from ${req.socket.remoteAddress}`);
        res.writeHead(401, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Unauthorized: Invalid Execution Secret' }));
        return;
    }

    // Proxy the request to Piston
    const proxyReq = http.request({
        host: TARGET_HOST,
        port: TARGET_PORT,
        path: req.url,
        method: req.method,
        headers: req.headers
    }, (proxyRes) => {
        res.writeHead(proxyRes.statusCode, proxyRes.headers);
        proxyRes.pipe(res, { end: true });
    });

    proxyReq.on('error', (err) => {
        console.error('Proxy error:', err);
        res.writeHead(502);
        res.end('Piston Engine Not Ready');
    });

    req.pipe(proxyReq, { end: true });
});

console.log(`Neural Security Shield active on port ${PORT}`);
console.log(`Routing traffic to Piston at ${TARGET_HOST}:${TARGET_PORT}`);
server.listen(PORT);
