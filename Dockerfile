FROM php:5.6-apache

# Configuração do apt e instalação de pacotes necessários
RUN rm /etc/apt/sources.list \
    && echo "deb http://archive.debian.org/debian/ jessie main" > /etc/apt/sources.list \
    && echo "deb-src http://archive.debian.org/debian/ jessie main" >> /etc/apt/sources.list \
    && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until \
    && echo 'Acquire::AllowInsecureRepositories "true";' > /etc/apt/apt.conf.d/99allow-insecure \
    && echo 'Acquire::AllowDowngradeToInsecureRepositories "true";' >> /etc/apt/apt.conf.d/99allow-insecure \
    && apt-get update \
    && apt-get install -y --allow-unauthenticated gnupg \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7638D0442B90D010 8B48AD6246925553 CBF8D6FD518E17E1 \
    && apt-get update \
    && apt-get install -y --allow-unauthenticated libfontconfig1 libxrender1 lynx

# Copia cacert.pem para o diretório de certificados
COPY cacert.pem /etc/ssl/certs/cacert.pem

# Substituir o arquivo de certificados
RUN rm /etc/ssl/certs/ca-certificates.crt \
    && cp /etc/ssl/certs/cacert.pem /etc/ssl/certs/ca-certificates.crt

# Adicionar configuração sysctl para aumentar o número máximo de arquivos
RUN echo "fs.file-max = 500000" >> /etc/sysctl.conf

# Configuração do Apache para limitar os workers e definir ServerName
RUN echo 'ServerName localhost\n\
    <IfModule mpm_prefork_module>\n\
    StartServers             5\n\
    MinSpareServers          5\n\
    MaxSpareServers         10\n\
    MaxRequestWorkers      150\n\
    MaxConnectionsPerChild   0\n\
    </IfModule>\n\
    <IfModule mod_status.c>\n\
    ExtendedStatus On\n\
    <Location /server-status>\n\
    SetHandler server-status\n\
    Require all granted\n\
    </Location>\n\
    </IfModule>\n\
    ' >> /etc/apache2/apache2.conf

# Substituir o valor de ULIMIT_MAX_FILES
RUN sed -i 's|ULIMIT_MAX_FILES="${APACHE_ULIMIT_MAX_FILES:-ulimit -n 8192}"|ULIMIT_MAX_FILES="${APACHE_ULIMIT_MAX_FILES:-ulimit -n 100000}"|' /usr/sbin/apachectl

# Ajustar a variável APACHE_LYNX no arquivo envvars
RUN echo 'export APACHE_LYNX=lynx' >> /etc/apache2/envvars