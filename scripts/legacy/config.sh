#!/bin/bash

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

TOKEN_FILE="${SCRIPTPATH}/config/.token.rb"
DB_CONFIG_FILE="${SCRIPTPATH}/db/.credentials.rb"

cd $SCRIPTPATH

# Setting up token for sessions

secret="$(padrino rake secret | tail -n1)"
echo "Writing cookies secret key ${secret} to $TOKEN_FILE "
echo "COOKIES_SECRET='${secret}'" > $TOKEN_FILE

# Setting up db config

read -p "Enter DB name [default is subscity]: " db_name
read -p "Enter DB user [default is root]: " db_user
read -s -p "Enter DB password: " db_pass
echo ""
read -p "Enter DB host [default is localhost]: " db_host
read -p "Enter admin email (for backups): " db_email

[ -z $db_name ] && db_name="subscity"
[ -z $db_user ] && db_user="root"
[ -z $db_host ] && db_host="localhost"

echo ""
echo "Entered and saved config:"
DB_CONF="DB_NAME=\"$db_name\"
DB_USER=\"$db_user\"
DB_PASS=\"$db_pass\"
DB_HOST=\"$db_host\"
DB_EMAIL=\"$db_email\""

echo "$DB_CONF"
echo ""
echo "Writing DB config to $DB_CONFIG_FILE"

echo "$DB_CONF" > $DB_CONFIG_FILE

# Updating cronjobs

cd ${SCRIPTPATH}/tasks
whenever --update-crontab

