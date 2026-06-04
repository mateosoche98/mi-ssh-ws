FROM docker.io/library/alpine:latest@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11

# Instalar SSH y Node.js
RUN apk add --no-cache openssh-server bash curl nodejs npm

# Configurar SSH de forma segura (Cambiamos la contraseña a algo menos obvio para el ejemplo, ej: 'Seguro123')
RUN ssh-keygen -A && \
    echo 'root:Seguro123' | chpasswd && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

WORKDIR /app

# Instalar dependencias de Node
RUN npm install ws

# Copiar el script del proxy
COPY proxy.js .

# Exponer el puerto del WebSocket (ejemplo: 8080) y el de SSH (opcional, 22)
EXPOSE 8080 22

# Script de inicio para arrancar AMBOS servicios (SSH y Node.js)
CMD ["sh", "-c", "/usr/sbin/sshd && node proxy.js"]
