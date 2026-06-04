FROM alpine:latest

# Instalar dependencias esenciales
RUN apk update && \
    apk add --no-cache openssh-server bash curl nodejs npm

# Configurar SSH convencional
RUN ssh-keygen -A && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo "Port 22" >> /etc/ssh/sshd_config

# Configurar directorio de trabajo y dependencias de Node
WORKDIR /app
RUN npm install ws

# Copiar el archivo proxy.js directamente desde tu repositorio
COPY proxy.js .

EXPOSE 80

# Inicializar servicios de forma limpia
CMD /usr/sbin/sshd && node proxy.js
