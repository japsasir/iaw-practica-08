#!/bin/bash
###-------------------------------------------------------###
### Script para montar un servidor con Wordpress y MySQL  ###
###-------------------------------------------------------###
## Declaración de variables
# Definimos la contraseña de root como variable
DB_ROOT_PASSWD=root
DB_USU_PASSWD=usuario
# ------------------------------------------------------------------------------ Instalación y configuración de Apache, MySQL y PHP------------------------------------------------------------------------------ 

# Habilitamos el modo de shell para mostrar los comandos que se ejecutan
set -x
# Actualizamos y actualizamos la lista de paquetes
apt update  
apt upgrade -y

## Configuración Apache ##
# Instalamos Apache
apt install apache2 -y

## Configuración MySQL ##
# Instalamos el sistema gestor de base de datos
apt install mysql-server -y
# Editamos el archivo de configuración de MySQL, modificando la línea (Loop/cualquiera) Es necesario que acepte conexiones de cualquier origen para que cumpla con el enunciado de la práctica.
sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf 
# Reiniciamos el servicio
sudo /etc/init.d/mysql restart


## Configuración de PHP ##
# Aquí va la configuración editada  (Debconf-set-selections)
apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y

## Configuración de WordPress ##
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










## Configuración de WordPress ##

## NO EN USO 
# Clonamos el repositorio
#cd /home/ubuntu
#rm -rf iaw-practica-lamp 
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
