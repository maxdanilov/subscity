#!/bin/sh

SCRIPT=`realpath $0`
SCRIPT_PATH=`dirname $SCRIPT`
BACKUP_PATH="${SCRIPT_PATH}/db/backups"
BACKUP_FILE="subscity.sql"
BACKUP_FILE_COMPRESSED="${BACKUP_FILE}.$(date +'%Y%m%d.%H%M').gz"

if [ -z $SC_DB_NAME ] || [ -z $SC_DB_USER ] || [ -z $SC_DB_PASS ] || [ -z $SC_DB_EMAIL ] || [ -z $SC_DB_HOST ]; then
	echo "Error in config values:"
	echo "SC_DB_HOST=${SC_DB_HOST}"
	echo "SC_DB_USER=${SC_DB_USER}"
	echo "SC_DB_PASS=${SC_DB_PASS}"
	echo "SC_DB_NAME=${SC_DB_NAME}"
	echo "SC_DB_EMAIL=${SC_DB_EMAIL}"
	exit 1
fi

dump() {
	echo "Backing up DB ${SC_DB_NAME} to ${BACKUP_PATH}/${BACKUP_FILE}"
	mkdir -p ${BACKUP_PATH}
	mysqldump -h ${SC_DB_HOST} -u ${SC_DB_USER} -p${SC_DB_PASS} --databases ${SC_DB_NAME} > ${BACKUP_PATH}/${BACKUP_FILE}
	gzip -c ${BACKUP_PATH}/${BACKUP_FILE} > ${BACKUP_PATH}/${BACKUP_FILE_COMPRESSED}
}

send() {
	echo "Mailing"
	echo "$(hostname) backup" | mutt -s "backup ${BACKUP_FILE_COMPRESSED}" -a ${BACKUP_PATH}/${BACKUP_FILE_COMPRESSED} -- ${SC_DB_EMAIL}
	rm ${BACKUP_PATH}/${BACKUP_FILE_COMPRESSED}
	rm ${BACKUP_PATH}/${BACKUP_FILE}
}

dump
send
