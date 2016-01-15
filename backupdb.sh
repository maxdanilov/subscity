#!/bin/sh

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`
BACKUPPATH=${SCRIPTPATH}/db/backups
CREDENTIALS=${SCRIPTPATH}/db/.credentials.rb
BACKUPFILE="subscity.sql"
BACKUPFILECOMPRESSED="subscity.$(date +'%Y%m%d.%H%M').sql.gz"
parse_setting()
{
	cat $CREDENTIALS | grep $1 | cut -d "=" -f2 | tr -d "\""
}

if [ ! -f $CREDENTIALS ]; then
	echo "$CREDENTIALS not found"
	exit 1
fi

DB_NAME=$(parse_setting DB_NAME)
DB_USER=$(parse_setting DB_USER)
DB_PASS=$(parse_setting DB_PASS)
DB_EMAIL=$(parse_setting DB_EMAIL)

if [ -z $DB_NAME ] || [ -z $DB_USER ] || [ -z $DB_PASS ] || [ -z $DB_EMAIL ]; then
	echo "Error in config values:"
	echo "DB_NAME=${DB_NAME}"
	echo "DB_USER=${DB_USER}"
	echo "DB_PASS=${DB_PASS}"
	echo "DB_EMAIL=${DB_EMAIL}"
	exit 1
fi

mkdir -p $BACKUPPATH
echo "Backing up DB ${DB_NAME} to ${BACKUPPATH}/${BACKUPFILE}"
mysqldump -u $DB_USER -p$DB_PASS --databases $DB_NAME > ${BACKUPPATH}/${BACKUPFILE}
gzip -c ${BACKUPPATH}/${BACKUPFILE} > ${BACKUPPATH}/${BACKUPFILECOMPRESSED}

# mail
echo "backup" | mutt -s "subscity backup" -a ${BACKUPPATH}/${BACKUPFILECOMPRESSED} -- ${DB_EMAIL}
rm ${BACKUPPATH}/${BACKUPFILECOMPRESSED}
rm ${BACKUPPATH}/${BACKUPFILE}
