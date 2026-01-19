#!/bin/sh

# Script modernizado para la instalación base de Orfeo
# Adaptado para PHP 8.3 y PostgreSQL 16

REPOSITORIO="https://github.com/CalicheDev/orfeo-6.2"
LOCAL="/var/www/html"
DBNAME="orfeo05"
DBUSER="orfeo_user"
DBPASSWORD="orfeo2026" # ¡Cambia esto!
PHP_VER="8.3"
PG_VER="16"

INSTALLDIR="$LOCAL/orfeo-6.2/instalacion"
PHPDIR="/etc/php/$PHP_VER/apache2"
POSTGRESQLDIR="/etc/postgresql/$PG_VER/main"

# 1. Preparación de Repositorios
echo "Configurando repositorios modernos..."
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:ondrej/php -y # Para versiones de PHP actualizadas
sudo apt-get update

# 2. Instalación de dependencias actualizadas
echo "Instalando Apache, PHP $PHP_VER y PostgreSQL $PG_VER..."
apt-get install -y \
    apache2 \
    postgresql-$PG_VER \
    postgresql-client-$PG_VER \
    php$PHP_VER \
    libapache2-mod-php$PHP_VER \
    php$PHP_VER-pgsql \
    php$PHP_VER-curl \
    php$PHP_VER-gd \
    php$PHP_VER-mbstring \
    php$PHP_VER-xml \
    php$PHP_VER-xmlrpc \
    php$PHP_VER-imap \
    php$PHP_VER-sqlite3 \
    php$PHP_VER-ldap \
    php$PHP_VER-zip \
    zip git curl

# 3. Descarga de Orfeo
cd $LOCAL
echo "Clonando repositorio..."
if [ ! -d "orfeo-6.2" ]; then
    git clone $REPOSITORIO
fi

chown -R www-data:www-data $LOCAL/orfeo-6.2
chmod -R 755 $LOCAL/orfeo-6.2

# 4. Configuración de Base de Datos
echo "Configurando PostgreSQL..."
sudo -u postgres psql -c "DO \$$ BEGIN IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = '$DBUSER') THEN CREATE USER $DBUSER WITH PASSWORD '$DBPASSWORD'; END IF; END \$$;"
sudo -u postgres psql -c "CREATE DATABASE $DBNAME WITH OWNER $DBUSER;" 2>/dev/null || echo "La base de datos ya existe."

echo "Cargando esquema inicial..."
# Nota: Asegúrate que orfeoclear.sql sea compatible con PG 16
sudo -u postgres psql $DBNAME -c "\i $INSTALLDIR/orfeoclear.sql;"
sudo -u postgres psql $DBNAME -c "UPDATE usuario SET usua_nuevo=0 WHERE usua_login='ADMON';"

# 5. Ajustes de Configuración de Servicios
echo "Ajustando PHP y Apache..."
[ -f $PHPDIR/php.ini ] && cp $PHPDIR/php.ini $PHPDIR/php.ini.bak
# En versiones modernas, es mejor usar sed para cambiar valores específicos en lugar de sobrescribir todo
sed -i 's/memory_limit = .*/memory_limit = 512M/' $PHPDIR/php.ini
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 20M/' $PHPDIR/php.ini
systemctl restart apache2

echo "Ajustando permisos de PostgreSQL..."
echo "host    all             all             127.0.0.1/32            md5" >> $POSTGRESQLDIR/pg_hba.conf
systemctl restart postgresql

# 6. Finalización
clear
echo "===================================================="
echo "Instalación de entorno Orfeo Finalizada."
SERVIDOR=$(hostname -I | awk '{print $1}')
echo "Acceso web: http://$SERVIDOR/orfeo-6.2"
echo "===================================================="
