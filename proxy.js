const WebSocket = require('ws');
const net = require('net');

// Escuchar en el puerto 8080 para conexiones WebSocket entrantes
const wss = new WebSocket.Server({ port: 8080 }, () => {
    console.log("Servidor WebSocket Proxy escuchando en el puerto 8080");
});

wss.on('connection', (ws) => {
    console.log("Cliente conectado vía WebSocket. Abriendo túnel hacia SSH (puerto 22)...");

    # Conectar al servidor SSH local dentro del contenedor
    const tcpSocket = net.connect(22, '127.0.0.1', () => {
        console.log("Conectado exitosamente al SSH interno.");
    });

    # Pasar datos de WebSocket a SSH
    ws.on('message', (data) => {
        tcpSocket.write(data);
    });

    # Pasar datos de SSH a WebSocket
    tcpSocket.on('data', (data) => {
        ws.send(data, { binary: true });
    });

    # Manejo de cierres y errores
    ws.on('close', () => tcpSocket.end());
    tcpSocket.on('close', () => ws.close());
    ws.on('error', () => tcpSocket.end());
    tcpSocket.on('error', () => ws.close());
});
