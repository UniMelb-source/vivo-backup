#!/bin/bash

CRON_DIR=/etc/cron.d
USER_HOME=/var/lib/rdr-unimelb
USER_NAME=rdr-unimelb
USER_GROUP=rdr-unimelb
USER_SHELL=/bin/false

INSTALL_DIR=${USER_HOME}/bin
BACKUP_DIR=/var/lib/rdr-unimelb/backup

echo "Adding user to system..."
groupadd ${USER_GROUP}
useradd -m -d ${USER_HOME} -g ${USER_GROUP} -s ${USER_SHELL} ${USER_NAME}

echo "Copying binaries to install location..."
mkdir -p ${INSTALL_DIR}
cp -v backup-directories ${INSTALL_DIR}
cp -v backup-files ${INSTALL_DIR}
cp -v backup.sh ${INSTALL_DIR}
chown -R ${USER_NAME}:${USER_GROUP} ${INSTALL_DIR}

echo "Installing crontab..."
cp scripts/crontab ${CRON_DIR}/rdr-unimelb-backup
sed -i -e "s#%%USER_NAME%%#${USER_NAME}#g" -e "s#%%INSTALL_DIR%%#${INSTALL_DIR}#g" ${CRON_DIR}/rdr-unimelb-backup
