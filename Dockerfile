FROM docker.io/library/alpine:latest@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11

RUN apk add --no-cache openssh-server bash curl nodejs npm

RUN ssh-keygen -A && \
    echo 'root:Seguro123' | chpasswd && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

WORKDIR /app

RUN npm install ws

COPY proxy.js .

# 1. Informa a la red qué puerto utiliza tu proxy WebSocket
EXPOSE 8080

# 2. SEÑAL DE INICIO: Arranca el demonio SSH en segundo plano y luego corre Node.js
CMD ["sh", "-c", "/usr/sbin/sshd && node proxy.js"]
