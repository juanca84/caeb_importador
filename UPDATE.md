# Actualización

Para actualizar a una versión reciente del sistema realizar los siguientes pasos:

Actualización del repositorio:

```console
cd /var/www/html/evaluacion
sudo -u roruser -H git pull origin master
```
Actualización de gemas:

```console
sudo -u roruser -H bundle install --deployment --without development test
```

Ejecución de migraciones y semillas:

```console
sudo -u roruser -H bundle exec rake db:migrate RAILS_ENV=production
sudo -u roruser -H bundle exec rake db:seed RAILS_ENV=production
```

Compilación de archivos CSS y JS:

```console
sudo -u roruser -H bundle exec rake assets:clobber RAILS_ENV=production
sudo -u roruser -H bundle exec rake assets:precompile RAILS_ENV=production
```

Reiniciar el servidor mediante `passenger`

```console
sudo -u roruser -H touch tmp/restart.txt
```

o

```console
sudo service apache2 restart
```
