# Instalación

## Requisitos

* Sistema Operativo: Debian Jessie
* Usuario: roruser
* Servidor: www.dominio.gob.bo

## Paquetes y dependencias

La instalación de paquetes en el servidor remoto

```console
sudo apt-get install -y curl checkinstall bzip2 gawk g++ gcc make \
libc6-dev patch libreadline6-dev zlib1g-dev libssl-dev libyaml-dev \
libsqlite3-dev sqlite3 autoconf libgmp-dev libgdbm-dev libncurses5-dev \
automake libtool bison pkg-config libffi-dev wget
```

Instalar [Git](http://git-scm.com/)

```console
sudo apt-get install -y git git-core
```

Instalar Vim como editor por defecto (opcional):

```console
sudo apt-get install -y vim
sudo update-alternatives --set editor /usr/bin/vim.basic
```

## Ruby

Eliminar la versión actual de ruby en el sistema:

```console
sudo apt-get remove ruby1.8
```

Descargar Ruby y compilarlo:

```console
mkdir /tmp/ruby && cd /tmp/ruby
curl --remote-name --progress https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.0.tar.gz
echo '152fd0bd15a90b4a18213448f485d4b53e9f7662e1508190aa5b702446b29e3d  ruby-2.4.0.tar.gz' | shasum -c - && tar xzf ruby-2.4.0.tar.gz
cd ruby-2.4.0
./configure --disable-install-rdoc
make
sudo make install
```

Instalar la gema Bundler:

```console
sudo gem install bundler --no-ri --no-rdoc
```

## Usuario de Sistema Operativo

Crear el usuario `roruser`:

```
sudo adduser --disabled-login --gecos 'Evaluación Institucional' roruser
```

## Base de Datos

Instalación de PostgreSQL:

```console
sudo apt-get install -y postgresql postgresql-client libpq-dev postgresql-contrib
```

Crear un usuario para la base de datos:

```console
sudo -u postgres psql -d template1 -c "CREATE USER roruser CREATEDB;"
```

Crear la base de datos para Evaluación Institucional con todos los privilegios:

```console
sudo -u postgres psql -d template1 -c "CREATE DATABASE evaluacion_production OWNER roruser;"
```

Prueba de conexión a la nueva base de datos con el nuevo usuario:

```console
sudo -u roruser -H psql -d evaluacion_production
```

Salir de la sesión de base de datos:

```console
evaluacion_production> \q
```

## Evaluación Institucional

Instalar Evaluación Institucional en el directorio home del usuario "roruser":

```console
cd /home/roruser
```

Clonar el código fuente:

```console
sudo -u roruser -H git clone https://gitlab.geo.gob.bo/agetic/evaluacion-institucional.git -b master evaluacion
```

Configurar el sistema:

```console
# Ingresar al folder de instalación
cd /home/roruser/evaluacion

# Copiar el archivo de configuración de la base de datos de ejemplo
sudo -u roruser -H cp config/database.yml.sample config/database.yml

# Copiar el archivo secrets de ejemplo
sudo -u roruser -H cp config/secrets.yml.sample config/secrets.yml
sudo -u roruser -H chmod 0600 config/secrets.yml
```

Instalar las gemas:

```console
sudo -u roruser -H bundle install --deployment --without development test
```

Editar `config/database.yml`:

```console
sudo -u roruser -H editor config/database.yml
```

si se necesita hacer una configuración más específica cambiar lo siguiente:

```yaml
production:
  adapter: postgresql
  encoding: unicode
  pool: 5
  database: evaluacion_production

  # The specified database role being used to connect to postgres.
  # To create additional roles in postgres see `$ createuser --help`.
  # When left blank, postgres will use the default role. This is
  # the same name as the operating system user that initialized the database.
  username: roruser

  # The password associated with the postgres role (username).
  password: roruser

  # Connect on a TCP socket. Omitted by default since the client uses a
  # domain socket that doesn't need configuration. Windows does not have
  # domain sockets, so uncomment these lines.
  #host: localhost

  # The TCP port the server listens on. Defaults to 5432.
  # If your server runs on a different port number, change accordingly.
  #port: 5432

  # Schema search path. The server defaults to $user,public
  #schema_search_path: myapp,sharedapp,public

  # Minimum log levels, in increasing order:
  #   debug5, debug4, debug3, debug2, debug1,
  #   log, notice, warning, error, fatal, and panic
  # Defaults to warning.
  #min_messages: notice
```

Hacer que `config/database.yml` solo sea accesible por el usuario roruser:

```console
sudo -u roruser -H chmod o-rwx config/database.yml
```

Generar la clave secreta:

```console
sudo -u roruser -H bundle exec rake secret
```

copiar la clave secreta y editar `config/secrets.yml`:

```console
sudo -u roruser -H editor config/secrets.yml
```
Al editar `secrets.yml` tiene el siguiente contenido

```yml
production:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
  rails_relative_url_root: <%= ENV["RAILS_RELATIVE_URL_ROOT"] %>
  exception_notification:
    email_prefix: "[Evaluación Institucional] "
    sender_address: "notificador <noreply@dominio.gob.bo>"
    exception_recipients: "desarrolladores@dominio.gob.bo"
  smtp_settings:
    address: 'smtp.dominio.gob.bo'
    port: 587
    domain: 'dominio.gob.bo'
    user_name: 'roruser'
    password: 'mi-super-password'
    authentication: 'plain'
    enable_starttls_auto: true
  ldap:
    -
      host: localhost
      port: 389
      attribute: uid
      base: ou=usuarios,dc=dominio,dc=gob,dc=bo
      ssl: false
```

donde:

* `secret_key_base` se **DEBE** reemplazar con la clave secreta generada
* `rails_relative_url_root` es la ubicación del subdirectorio de deploy tal como: `www.dominio.gob.bo/evaluacion`
  dejar una cadena vacía en el caso que el deploy sea en la raíz del dominio.
* `sender_address` es el email desde donde se harán las notificaciones por email
* `exception_recipients` ahí va los destinos de los emails puede ser uno o
  varios emails separados por comas: `des1@dominio.gob.bo, des2@dominio.gob.bo`
* `smtp_settings` la configuración del servidor de email desde el cual se
  enviará los emails de notificación de excepciones
* `ldap` la configuración para el Servidor LDAP

Compilamos los archivos CSS y JS:

```console
sudo -u roruser -H bundle exec rake assets:clobber RAILS_ENV=production
sudo -u roruser -H bundle exec rake assets:precompile RAILS_ENV=production
```

Crear la estructura de tablas e inicializar con la configuración por defecto

```console
sudo -u roruser -H bundle exec rake db:migrate RAILS_ENV=production
sudo -u roruser -H bundle exec rake db:seed RAILS_ENV=production
```

## Apache

Instalar `apache2` en el servidor:

```console
sudo apt-get install -y apache2 libcurl4-openssl-dev apache2-mpm-worker \
apache2-threaded-dev libapr1-dev libaprutil1-dev
```

Instalar `passenger` en el servidor:

```console
sudo gem install passenger --version 5.1.1 --no-ri --no-rdoc
```

Nota: se puede realizar la instalación de Passenger sin especificar la versión
solamente tener cuidado de copiar la ruta exacta para los archivos `passenger.conf`
y `passenger.load`.

Instalar el módulo de `passenger` para `apache2`:

```console
sudo passenger-install-apache2-module
```

Nota:

En la parte que `passenger-install-apache2-module` pide seleccionar los lenguajes
de programación para los cuales se instalará el módulo, seleccionar Ruby solamente.

Después de instalar el módulo de `passenger`, crear los archivos de configuración:

```console
sudo editor /etc/apache2/mods-available/passenger.conf
```

```apache
<IfModule mod_passenger.c>
  PassengerRoot /usr/local/lib/ruby/gems/2.4.0/gems/passenger-5.1.1
  PassengerDefaultRuby /usr/local/bin/ruby
</IfModule>
```

```console
sudo editor /etc/apache2/mods-available/passenger.load
```

```apache
LoadModule passenger_module /usr/local/lib/ruby/gems/2.4.0/gems/passenger-5.1.1/buildout/apache2/mod_passenger.so
```

Nota: El contenido de éstos dos archivos depende de la versión de Ruby y de la
versión de la gema Passenger.

Habilitar el módulo `passenger`:

```console
sudo a2enmod passenger
```

Habilitar el módulo `mod_rewrite` para Apache

```console
sudo a2enmod rewrite
```

Mover Evaluación Institucional a `/var/www/html`:

```console
sudo mv /home/roruser/evaluacion /var/www/html/
```

Configuración de Apache para el sistema Evaluación Institucional

```console
sudo editor /etc/apache2/sites-available/www.dominio.gob.bo.conf
```

Adicionar el siguiente contenido si se va instalar la aplicación en la raiz del dominio

```apache
<VirtualHost *:80>
  ServerName www.dominio.gob.bo
  DocumentRoot /var/www/html/evaluacion/public
  RailsEnv production
  <Directory /var/www/html/evaluacion/public>
    Allow from all
    Options -MultiViews
    # Uncomment this if you're on Apache > 2.4:
    Require all granted
  </Directory>
</VirtualHost>
```

Contenido para deploy de la aplicación en un subdirectorio `/evaluacion`

```apache
<VirtualHost *:80>
  ServerName www.dominio.gob.bo
  DocumentRoot /var/www/html

  Alias /evaluacion /var/www/html/evaluacion/public
  <Location /evaluacion>
      PassengerBaseURI /evaluacion
      PassengerAppRoot /var/www/html/evaluacion
  </Location>
  <Directory /var/www/html/evaluacion/public>
      RailsEnv production
      Allow from all
      Options -MultiViews
      # Uncomment this if you're on Apache >= 2.4:
      Require all granted
  </Directory>
</VirtualHost>
```

Habilitar el nuevo sitio y reiniciar Apache

```console
sudo a2ensite www.dominio.gob.bo
sudo service apache2 restart
```

Nota: Puede ser necesario deshabilitar el dominio por defecto con el comando
`sudo a2dissite 000-default`

Visitamos el sitio http://www.dominio.gob.bo o http://www.dominio.gob.bo/evaluacion depende
de la configuración que se haya elegido para el deploy.
