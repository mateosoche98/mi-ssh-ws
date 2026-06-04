const WebSocket = require('ws');
const net = require('net');

// Servidor WS escuchando externamente en el puerto 8080
const wss = new WebSocket.Server({ port: 8080 }, () => {
    console.log("Puente WebSocket-SSH activo en el puerto 8080");
});

wss.on('connection', (ws) => {
    console.log("Nueva conexión WS recibida. Conectando al SSH interno (puerto 22)...");

    // Crear la conexión TCP interna hacia el SSH local
    const tcpSocket = net.connect(22, '127.0.0.1', () => {
        console.log("Túnel establecido con el SSH local de Alpine.");
    });

    // Enviar lo que viene del WebSocket directo al SSH
    ws.on('message', (data) => {
        tcpSocket.write(data);
    });

    // Enviar la respuesta del SSH de vuelta al cliente WebSocket
    tcpSocket.on('data', (data) => {
        ws.send(data, { binary: true });
    });

    // Controlar cierres y errores para evitar fugas de memoria
    ws.on('close', () => tcpSocket.end());
    tcpSocket.on('close', () => ws.close());
    ws.on('error', () => tcpSocket.end());
    tcpSocket.on('error', () => ws.close());
});
