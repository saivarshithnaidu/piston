const http = require('http');
const httpProxy = require('http-proxy');
const proxy = httpProxy.createProxyServer({});

const PORT = process.env.PORT || 2000;
const TARGET = 'http://127.0.0.1:3000'; // Piston API will run here
const SECRET = process.env.EXECUTION_SECRET;

if (!SECRET) {
    console.error('FATAL: EXECUTION_SECRET environment variable is not set!');
    process.exit(1);
}

const server = http.createServer((req, res) => {
    // Check Authorization header
    const authHeader = req.headers['authorization'];
    
    if (!authHeader || authHeader !== `Bearer ${SECRET}`) {
        console.warn(`Unauthorized access attempt from ${req.socket.remoteAddress}`);
        res.writeHead(401, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Unauthorized: Invalid Execution Secret' }));
        return;
    }

    // Forward valid requests to Piston
    proxy.web(req, res, { target: TARGET }, (err) => {
        res.writeHead(502);
        res.end('Piston Engine Not Ready');
    });
});

console.log(`Security Shield active on port ${PORT}`);
console.log(`Protecting Piston engine at ${TARGET}`);
server.listen(PORT);
