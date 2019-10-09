#!/bin/sh

# Script para realizar la instalacion base de orfeo
#Contacto@carlosmora.biz

REPOSITORIO="https://github.com/pipemeza/orfeo05.git"    #Repositorio Correlibre
LOCAL="/var/www/html"
DBNAME="orfeo05"
DBUSER="orfeo_user"
DBPASSWORD="0rf30**$$"
INSTALLDIR="$LOCAL/orfeo5/instalacion"
PHPDIR="/etc/php/5.4/apache2"
POSTGRESQLDIR="/etc/postgresql/9.6/main"


sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -

apt-get update && apt-get upgrade -y

echo  "Por favor lea con mucha atencion el siguiente mensaje: \n"

cat advertencia.txt && sleep 10



add-apt-repository ppa:ondrej/php; apt-get update; apt-get install php5.4-pgsql postgresql-9.6 apache2 libgda-5.0-postgres   postgresql-common-9.6  postgresql-client-common-9.6 libpg-perl postgresql-9.6 postgresql-client-9.6 php5.4 libapache2-mod-php5.4 php5.4-curl php5.4-gd php5.4-mbstring php5.4-mcrypt php5.4-mysql php5.4-xml php5.4-xmlrpc php5.4-pgsql php5.4-xsl  php5.4-imap php5.4-sqlite3 php5.4-ldap php5.4-zip zip git -y

cd $LOCAL

echo  "Comienza la descarga del repositorio $REPOSITORIO"
git clone $REPOSITORIO
sleep 2
chown www-data:www-data $LOCAL -Rv
cp index.html index.html.preOrfeo

cat $INSTALLDIR/index.html > $LOCAL/index.html


echo  "A continuacion se va a crear la base de datos"
sleep 3
cd /tmp
sudo -u postgres psql -c "CREATE USER $DBUSER;"
sudo -u postgres psql -c "alter user $DBUSER with password '$DBPASSWORD';"
sudo -u postgres psql -c "CREATE DATABASE $DBNAME WITH OWNER $DBUSER;"

echo  "Cargando la base de datos inicial"
sleep 3

sudo -u postgres psql $DBNAME -c "\i $INSTALLDIR/orfeoclear.sql;"
sudo -u postgres psql $DBNAME -c "update usuario set usua_nuevo=0 where usua_login='ADMON';"

cp $PHPDIR/php.ini $PHPDIR/php.ini.preOrfeo
cat $INSTALLDIR/phpBase.ini > $PHPDIR/php.ini; /etc/init.d/apache2 restart

cp $POSTGRESQLDIR/pg_hba.conf	$POSTGRESQLDIR/pg_hba.conf.preOrfeo
cat $INSTALLDIR/pg_hba.conf > $POSTGRESQLDIR/pg_hba.conf; /etc/init.d/postgresql restart
cd && clear
echo  "Instalacion de orfeo Finalizada."
echo
SERVIDOR=$(ifconfig  | grep inet| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}' |head -n 1)
echo "Ingrese a su servidor en la direccion: http://$SERVIDOR"
