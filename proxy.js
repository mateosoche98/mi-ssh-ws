const http = require('http');
const net = require('net');
const WebSocket = require('ws');

// Crear un servidor HTTP nativo para capturar y limpiar las cabeceras del Payload
const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('SSH WebSocket Bridge Active');
});

const wss = new WebSocket.Server({ noServer: true });

// Interceptar la actualización de WebSocket ignorando el Host del payload
server.on('upgrade', (request, socket, head) => {
    wss.handleUpgrade(request, socket, head, (ws) => {
        wss.emit('connection', ws, request);
    });
});

wss.on('connection', (ws) => {
    const sshSocket = net.connect(22, '127.0.0.1', () => {
        // Conexión exitosa al SSH interno
    });

    ws.on('message', (msg) => {
        if (Buffer.isBuffer(msg)) {
            sshSocket.write(msg);
        } else {
            sshSocket.write(Buffer.from(msg));
        }
    });

    sshSocket.on('data', (data) => {
        ws.send(data);
    });

    ws.on('close', () => sshSocket.end());
    sshSocket.on('close', () => ws.close());
    sshSocket.on('error', () => ws.close());
    ws.on('error', () => sshSocket.end());
});

// Escuchar en el puerto requerido por Render
server.listen(80, () => {
    console.log('Servidor puente HTTP/WS activo en puerto 80');
});
