#!/bin/bash

DB_USERNAME=vivo
DB_PASSWORD=vivo
DB_DATABASE=vivo

TIMESTAMP=$(date +%FT%s)
TMP_DIR=$(mktemp -d)

DEST_DIR=/var/lib/rdr-unimelb/backup

MAX_TO_KEEP=7

if [ ! -d ${DEST_DIR} ]
then
	mkdir -p ${DEST_DIR}
fi

function create_backup {
	echo "Backing up ${TIMESTAMP}"
	echo "Backing up database"
	mysqldump --user ${DB_USERNAME} --password=${DB_PASSWORD} ${DB_DATABASE} > ${DEST_DIR}/${TIMESTAMP}.sql
	bzip2 ${DEST_DIR}/${TIMESTAMP}.sql

	echo "Backing up filesystem"

	for DIRECTORY in $(cat backup-directories)
	do
		DEST_TMP=${TMP_DIR}/${DIRECTORY}
		mkdir -p ${DEST_TMP}
		DEST_TMP_PARENT=$(dirname ${DEST_TMP})
		cp -ar ${DIRECTORY}/ ${DEST_TMP_PARENT} 
	done

	for FILE in $(cat backup-files)
	do
		FILE_PARENT=$(dirname ${FILE})
		DEST_TMP=${TMP_DIR}/${FILE_PARENT}
		mkdir -p ${DEST_TMP}
		cp -a ${FILE} ${DEST_TMP}
	done

	tar -C ${TMP_DIR} -cf ${DEST_DIR}/${TIMESTAMP}.tar .
	bzip2 ${DEST_DIR}/${TIMESTAMP}.tar
	rm -rf ${TMP_DIR}
}

function rotate_backups {

	echo "Rotating backups"
	pushd ${DEST_DIR}
	FS_BACKUPS=$(ls -t *.tar.bz2 | head -n ${MAX_TO_KEEP})
	for FS_BACKUP in $(ls -t *.tar.bz2)
	do
		KEEP=0
		for KEEP_FS_BACKUP in ${FS_BACKUPS}
		do
			if [ "${FS_BACKUP}" == "${KEEP_FS_BACKUP}" ]
			then
				KEEP=1
				break
			fi	
		done
		if [ ${KEEP} -eq 0 ]
		then
			echo "Deleting old filesystem backup ${FS_BACKUP}"
			rm ${FS_BACKUP}
		fi
	done
	
	SQL_BACKUPS=$(ls -t *.sql.bz2 | head -n ${MAX_TO_KEEP})
	for SQL_BACKUP in $(ls -t *.sql.bz2)
	do
		KEEP=0
		for KEEP_SQL_BACKUP in ${SQL_BACKUPS}
		do
			if [ "${SQL_BACKUP}" == "${KEEP_SQL_BACKUP}" ]
			then
				KEEP=1
				break
			fi	
		done
		if [ ${KEEP} -eq 0 ]
		then
			echo "Deleting old database backup ${SQL_BACKUP}"
			rm ${SQL_BACKUP}
		fi
	done
}

create_backup

rotate_backups
