#!/bin/bash

###-------------------------------------------------------###
### Script para montar un servidor con Wordpress y MySQL  ###
###-------------------------------------------------------###

## Variables

# Contraseña aleatoria para el parámetro blowfish_secret
BLOWFISH=`tr -dc A-Za-z0-9 < /dev/urandom | head -c 64`
# Directorio de usuario
HTTPASSWD_DIR=/home/ubuntu
HTTPASSWD_USER=usuario
HTTPASSWD_PASSWD=usuario
# MySQL
DB_ROOT_PASSWD=root
DB_NAME=wordpress_db
DB_USER=wordpress_user
DB_PASSWORD=wordpress_password

# ------------------------------------------------------------------------------ Instalación y configuración de Apache, MySQL y PHP------------------------------------------------------------------------------ 

# Habilitamos el modo de shell para mostrar los comandos que se ejecutan
set -x
# Actualizamos y actualizamos la lista de paquetes
apt update  
## apt upgrade -y   #Comentado por agilizar la entrega

# Instalamos Apache
apt install apache2 -y

# Instalamos el sistema gestor de base de datos
apt install mysql-server -y

# Instalamos los módulos PHP necesarios para Apache
apt install php libapache2-mod-php php-mysql -y

# Reiniciamos el servicio Apache 
systemctl restart apache2

# Copiamos el archivo info.php adjunto al directorio html. No es necesario extraer el archivo de info gracias a la variable.
cp $HTTPASSWD_DIR/iaw_practica08/info.php /var/www/html/info.php

# Configuramos las opciones de instalación de phpMyAdmin #!!examinar
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $BLOWFISH" |debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $BLOWFISH" | debconf-set-selections

# Instalamos phpMyAdmin #
apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y

# ------------------------------------------------------------------------------ Instalación y configuración de Wordpress------------------------------------------------------------------------------ 
## Fase 1: Descarga y extracción ##
# Directorio raíz de nuestro apache
cd /var/www/html
# Descargamos Wordpress 
wget http://wordpress.org/latest.tar.gz
# Eliminamos instalaciones anteriores por seguridad
rm -rf /var/www/html/wordpress
# Descomprimimos el archivo que acabamos de descargar 
tar -xzvf latest.tar.gz
# Limpiamos el archivo comprimido residual.
rm latest.tar.gz

## Fase 2: Crear base de datos y un usuario##

# Por seguridad, hacemos un borrado preventivo de la base de datos wordpress_db
mysql -u root <<< "DROP DATABASE IF EXISTS $DB_NAME;"
# Creamos la base de datos wordpress_db
mysql -u root <<< "CREATE DATABASE $DB_NAME;"
# Nos aseguramos que no existe el usuario automatizado
mysql -u root <<< "DROP USER IF EXISTS $DB_USER@localhost;"
# Creamos el usuario 'wordpress_user' para Wordpress
mysql -u root <<< "CREATE USER $DB_USER@localhost IDENTIFIED BY '$DB_PASSWORD';"
# Concedemos privilegios al usuario que acabamos de crear
mysql -u root <<< "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@localhost;"
# Aplicamos cambios con un comando flush. Esto evita tener que reiniciar mysql.
mysql -u root <<< "FLUSH PRIVILEGES;"

## Fase 3:Configurar el archivo wp-config.php##

# En primer lugar, borramos el index.html de Apache para evitar conflictos con nuestro php.
rm /var/www/html/index.html

# Definimos variables dentro del archivo config de Wordpress.
# Base de datos
sed -i "s/database_name_here/$DB_NAME/" /var/www/html/wordpress/wp-config.php
# Usuario
sed -i "s/username_here/$DB_USER/" /var/www/html/wordpress/wp-config.php
# Contraseña
sed -i "s/password_here/$DB_PASSWORD/" /var/www/html/wordpress/wp-config.php

## Fase 4: Coloca los archivos##


## Fase 5: Ejecuta la instalación##



#https://codex.wordpress.org/es:Instalando_Wordpress