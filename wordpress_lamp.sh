#!/bin/bash

###-------------------------------------------------------###
### Script para montar un servidor con Wordpress y MySQL  ###
###-------------------------------------------------------###

## Variables

# Contraseña aleatoria para el parámetro blowfish_secret
BLOWFISH=`tr -dc A-Za-z0-9 < /dev/urandom | head -c 64`
# DIR
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

# Instalamos php y la familia de módulos
apt install php libapache2-mod-php php-mysql -y

# Reiniciamos el servicio Apache 
systemctl restart apache2

# Copiamos el archivo info.php al directorio html 
cp $HTTPASSWD_DIR/iaw_practica08/info.php /var/www/html/info.php

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
## Configuración MySQL ##

# Editamos el archivo de configuración de MySQL, modificando la línea (Loop/cualquiera) Es necesario que acepte conexiones de cualquier origen para que cumpla con el enunciado de la práctica.
sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf 
#git clone https://github.com/josejuansanchez/iaw-practica-lamp

# Actualizamos la contraseña de root de MySQL
#mysql -u root  <<< "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$DB_ROOT_PASSWD';"
#mysql -u root -p$DB_ROOT_PASSWD <<< "FLUSH PRIVILEGES;"

# Creamos usuario para la aplicación web y asignamos privilegios
# mysql -u root -p$DB_ROOT_PASSWD <<< "CREATE USER 'lamp_user'@'%' IDENTIFIED BY '$DB_USU_PASSWD';"
# mysql -u root -p$DB_ROOT_PASSWD <<< "GRANT ALL PRIVILEGES ON 'lamp_db'.* TO 'lamp_user'@'%';"
# mysql -u root -p$DB_ROOT_PASSWD <<< "FLUSH PRIVILEGES;"

# Introducimos la base de tados
#mysql -u root -p$DB_ROOT_PASSWD < /home/ubuntu/iaw-practica-lamp/db/database.sql
# Reiniciamos el servicio
sudo /etc/init.d/mysql restart

## Fase 3:Configurar el archivo wp-config.php##
#Valores similares a los usados hasta ahora. Crear un archivo a mano para copiarlo. La linea de abajo es para usar el archivo por defecto como archivo de config.
# mv wp-config-sample.php wp-config.php

## Fase 4: Coloca los archivos##

## Fase 5: Ejecuta la instalación##



#https://codex.wordpress.org/es:Instalando_Wordpress