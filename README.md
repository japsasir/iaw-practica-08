# iaw-practica-08
Práctica ocho de la asignatura IAW de 2º de Asir.

> IES Celia Viñas (Almería) - Curso 2020/2021
Módulo: IAW - Implantación de Aplicaciones Web
Ciclo: CFGS Administración de Sistemas Informáticos en Red

**Introducción**
------------


En esta práctica tendremos que realizar la instalación de un sitio WordPress haciendo uso de los servicios de Amazon Web Services (AWS)
![](https://assets.digitalocean.com/articles/architecture/production/lamp/dns_application.png)

**Fases de la práctica**
------------
1.1 Fases de la práctica

Tendrá que resolver la práctica en diferentes fases, documentando en cada fase todos los pasos que ha ido realizando. El repositorio final tiene que contener un directorio para cada una de las fases donde se incluyan los scripts y archivos de configuración utilizados para su resolución.


  	práctica-wordpress-lamp
  ├── fase00
  ├── fase01
  └── fase02

Las fases que tendrá que resolver son las siguientes:

    Fase 0. Instalación de Wordpress en un nivel (Un único servidor con todo lo necesario).
    Fase 1. Instalación de Wordpress en dos niveles (Servidor web, Servidor MySQL).
    Fase 2. Instalación de Wordpress en tres niveles (Balanceador, 2 Servidores webs, Servidor MySQL)



**Archivos en el repositorio**
------------
1. README.md  Documentación
2. wordpress_lamp.sh  Script para instalar Wordpress sobre una pila LAMP

**Fase 0**
------------

- Instalamos la pila LAMP: Apache, MySQL y PHP.
- En segundo lugar, instalaremos Wordpress.
- Finalmente configuraremos Wordpress.

## Configuración de WordPress

### 1. Base de datos para Wordpress

1. Creamos la base de datos para Wordpress
```sql
mysql -u root <<< "CREATE DATABASE $DB_NAME;"
```
2. Usuario Wordpress:
```sql
mysql -u root <<< "CREATE USER $DB_USER@localhost IDENTIFIED BY '$DB_PASSWORD';"
```
1. Privilegios de usuario Wordpress:
```sql
mysql -u root <<< "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@localhost;"
```


### 2. Instalación sobre un directorio que no es el raíz

Si  tenemos los archivos de WordPress en el directorio /var/www/html/wordpress en lugar de tenerlos en el directorio /var/www/html tendremos que configurar los valores WP_SITEURL y WP_HOME. 

Esto podemos hacerlo desde el panel de administración > Ajustes > Generales. Debemos configurar correctamente los valores WP_SITEURL y WP_HOME de la siguiente manera:


```bash
Dirección de WordPress (WP_SITEURL): http://NUESTRA_IP/wordpress
Dirección del sitio (WP_HOME): http://NUESTRA_IP
```


- WP_SITEURL: Es la URL que incluye el directorio donde está instalado WordPress.

- WP_HOME: Es la URL que queremos que usen los usuarios para acceder a WordPress.

Esto hará que al conectarnos a la IP de la máquina, nos cargue la página principal del Wordpress.

### 3. Configuración de WordPress en un directorio que no es el raíz

Para configurar Wordpress haremos varias cosas:

 Copiar el archivo /var/www/html/wordpress/index.php a /var/www/html/ y posteriormente modificar la siguiente línea de código:
~~~
require( dirname( __FILE__ ) . '/wp-blog-header.php' );
~~~

Por esta línea de código:

~~~
require( dirname( __FILE__ ) . '/wordpress/wp-blog-header.php' );
~~~
 Podemos hacer la sustitución mediante SED:
~~~
sed -i "s#/wp-blog-header.php#/wordpress/wp-blog-header.php#" /var/www/html/index.php
~~~

- Crera un archivo .htaccess en el directorio /var/www/html/ con el siguiente contenido:

~~~
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
~~~

Una vez hecho esto ya podremos acceder a WordPress desde la IP pública de la máquina.

### 4. Configuración de las Security Keys

Podemos mejorar la seguridad de WordPress configurando las security keys que aparecen en el archivo wp-config.php.La idea es crear contraseñas más difíciles de romper por fuerza bruta, empleando 4 claves y cuatro 'salt'


- Borramos el bloque que nos viene por defecto en el archivo de configuración mediante sed:


```bash
sed -i "/AUTH_KEY/d" /var/www/html/wordpress/wp-config.php
sed -i "/SECURE_AUTH_KEY/d" /var/www/html/wordpress/wp-config.php
sed -i "/LOGGED_IN_KEY/d" /var/www/html/wordpress/wp-config.php
sed -i "/NONCE_KEY/d" /var/www/html/wordpress/wp-config.php
sed -i "/AUTH_SALT/d" /var/www/html/wordpress/wp-config.php
sed -i "/SECURE_AUTH_SALT/d" /var/www/html/wordpress/wp-config.php
sed -i "/LOGGED_IN_SALT/d" /var/www/html/wordpress/wp-config.php
sed -i "/NONCE_SALT/d" /var/www/html/wordpress/wp-config.php
```


- Definimos la variable SECURITY_KEYS haciendo una llamada a la API de Wordpress:

```bash
SECURITY_KEYS=$(curl https://api.wordpress.org/secret-key/1.1/salt/)
```


- Reemplazamos "/" por "_" para que no nos falle el comando sed. Recordemos que emplear '/' en configuraciones suele llevarnos a error.

```bash
SECURITY_KEYS=$(echo $SECURITY_KEYS | tr / _)

```

- Creamos e insertamos un nuevo bloque de SECURITY KEYS, también con nuestra herramienta sed:

```bash
sed -i "/@-/a $SECURITY_KEYS" /var/www/html/wordpress/wp-config.php
```


- Habilitamos el módulo rewrite:

```bash
a2enmod rewrite
```

Este módulo permite crear direcciones URL alternativas a las dinámicas generadas por la programación de nuestro sitio web, de tal modo que sean más legibles y fáciles de recordar. E

- Antes de reiniciar el servidor web, le damos permisos para /var/www/html:

```bash
chown -R www-data:www-data /var/www/html
```

Reiniciamos el servicio apache2. Tras esto, deberíamos poder acceder a la página principal de nuestra web de Wordpress únicamente mediante la IP pública de nuestra máquina.

**Notas de cara a la entrevista**
------------
La variable IP_PUBLICA se usará para definir
`WP_SITEURL  WP_HOME`
![](https://i.imgur.com/EaSNxVa.png)

Credenciales de base de datos para la instalación de Wordpress

![](https://i.imgur.com/45Yvpez.png)

Los archivos subidos a la biblioteca de medios se almacenarán en 
`/var/www/html/wordpress/wp-content/uploads`
![](https://i.imgur.com/nHd53wN.png)

*Imagen de ejemplo.*

![](https://i.imgur.com/DSo3VBD.png)

*Archivos creados. Diferentes resoluciones para diferentes formatos.*

**Referencias**
------------
- Guía original para la práctica.
https://josejuansanchez.org/iaw/practica-08/
- Implantación Wordpress
https://www.digitalocean.com/community/tutorials/building-for-production-web-applications-deploying
https://codex.wordpress.org/es:Instalando_Wordpress
- Usando Wordpress
https://codex.wordpress.org/Getting_Started_with_WordPress
**Agradecimientos**
------------
- Markdown editor.
https://markdown-editor.github.io/
