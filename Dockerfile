FROM docker.io/library/alpine:latest@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11

# Instalar dependencias del sistema
RUN apk add --no-cache openssh-server bash curl nodejs npm

# Configurar SSH de forma segura
RUN ssh-keygen -A && \
    echo 'root:Seguro123' | chpasswd && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

WORKDIR /app

# Instalar dependencia de Node.js
RUN npm install ws

# Copiar el script del proxy
COPY proxy.js .

# Indicar el puerto externo que abrirá el contenedor
EXPOSE 8080

# ¡EL PASO CRUCIAL QUE FALTABA!: Arranca SSH de fondo y Node.js al frente
CMD ["sh", "-c", "/usr/sbin/sshd && node proxy.js"]
