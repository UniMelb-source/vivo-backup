#!/bin/bash

CRON_DIR=/etc/cron.d
USER_HOME=/var/lib/rdr-unimelb
USER_NAME=rdr-unimelb
USER_GROUP=rdr-unimelb
USER_SHELL=/bin/false

BIN_DIR=${USER_HOME}/bin
BACKUP_DIR=/var/lib/rdr-unimelb/backup

echo "Adding user to system..."
groupadd ${USER_GROUP}
useradd -m -d ${USER_HOME} -g ${USER_GROUP} -s ${USER_SHELL} ${USER_NAME}

echo "Copying binaries to install location..."
mkdir -p ${BIN_DIR}
cp -rv dist/* ${BIN_DIR}
chown -R ${USER_NAME}:${USER_GROUP} ${BIN_DIR}

echo "Installing crontab..."
cp scripts/crontab ${CRON_DIR}/rdr-unimelb-backup
sed -i -e "s#%%USER_NAME%%#${USER_NAME}#g" -e "s#%%BIN_DIR%%#${BIN_DIR}#g" ${CRON_DIR}/rdr-unimelb-backup

echo "Creating log directory..."
mkdir -p ${BACKUP_DIR}
chown -R ${USER_NAME}:${USER_GROUP} ${BACKUP_DIR}