#!/bin/bash

# Imports

# Variables
SCRIPT_PATH=""  # OS and Architecture dependant
SCRIPT_HOME=""  # OS and Architecture agnostic
MINIO_URL=https://dl.min.io/server/minio/release/linux-arm64/archive/minio_20241107005220.0.0_arm64.deb
MINIO_MCLI_URL=https://dl.min.io/client/mc/release/linux-arm64/archive/mcli_20241105112945.0.0_arm64.deb
MINIO_FILE=minio_20241107005220.0.0_arm64.deb
MINIO_MCLI_FILE=mcli_20241105112945.0.0_arm64.deb

# Aux functions

# debug
#   desc: Display a debug message if LOGLEVEL is DEBUG
#   params:
#     $1 - Debug message
#   return (status code/stdout):
debug() {
  if [[ "$LOGLEVEL" == "DEBUG" ]]; then
    echo $1
  fi
}

create_data_folder(){
  debug "minio.create_data_folder DEBUG [`date +"%Y-%m-%d %T"`] Creating the folder where the files will live"
  mkdir -p /data/s3
  chmod -R 775 /data/s3
  chown minio-user:minio-user /data/s3
  debug "minio.create_data_folder DEBUG [`date +"%Y-%m-%d %T"`] Folder where files will create created"
}
remove_data_folder(){
  debug "minio.remove_data_folder DEBUG [`date +"%Y-%m-%d %T"`] Removing the folder where the files live"
  rm -rf /data/s3
  debug "minio.remove_data_folder DEBUG [`date +"%Y-%m-%d %T"`] Folder where the files live removed"
}

install_minio(){
  debug "minio.install_minio DEBUG [`date +"%Y-%m-%d %T"`] Installing minio server and client"
  # 1. Download the server and client to /tmp
  wget -P /tmp/ $MINIO_URL
  wget -P /tmp/ $MINIO_MCLI_URL
  # 2. Install both packages
  dpkg -i /tmp/$MINIO_FILE
  dpkg -i /tmp/$MINIO_MCLI_FILE
  # 3. Remove the packages
  rm /tmp/$MINIO_FILE /tmp/$MINIO_MCLI_FILE
  # 4. Copy the default configuration
  cp $SCRIPT_HOME/minio /etc/default/minio
  debug "minio.install_minio DEBUG [`date +"%Y-%m-%d %T"`] Minio server and client installed"
}
uninstall_minio(){
  debug "minio.uninstall_minio DEBUG [`date +"%Y-%m-%d %T"`] Uninstalling minio server and client"
  # 1. Remove packages
  dpkg -P minio mcli
  # 2. Remove the default configuration
  rm /etc/default/minio
  debug "minio.uninstall_minio DEBUG [`date +"%Y-%m-%d %T"`] Minio server and client uninstalled"
}

initialize_minio(){
  debug "minio.initialize_minio DEBUG [`date +"%Y-%m-%d %T"`] Initializing MinIO creating an alias, secret/access keys and raw-data bucket"
  service minio start
  # 1. Create an alias to manipulate the local instance
  mcli alias set myminio http://localhost:9000 osbdet osbdet123$
  mcli admin info myminio
  # 2. Create a user (access key) and a password (secret key) to use from NiFi and Spark
  mcli admin user add myminio s3access _s3access123$
  mcli admin policy attach myminio readwrite --user=s3access
  # 3. Create a default bucket to upload stuff called raw-data
  mcli mb --with-lock myminio/raw-data
  service minio stop
  debug "minio.initialize_minio DEBUG [`date +"%Y-%m-%d %T"`] MinIO initialized"
}

create_minio-user(){
  debug "minio.create_minio-user DEBUG [`date +"%Y-%m-%d %T"`] Create a system user and group"
  # 1. Create the system user and group
  useradd -r minio-user -s /bin/false
  debug "minio.create_minio-use DEBUG [`date +"%Y-%m-%d %T"`] System user and group created"
}
remove_minio-user(){
  debug "minio.remove_serviceinstall DEBUG [`date +"%Y-%m-%d %T"`] Remove the system user and group"
  service minio stop
  userdel -r minio-user
  debug "minio.remove_minio-user DEBUG [`date +"%Y-%m-%d %T"`] System user and group removed"
}

# Primary functions
#
module_install(){
  debug "minio.module_install DEBUG [`date +"%Y-%m-%d %T"`] Starting module installation" >> $OSBDET_LOGFILE
  # The installation of this module consists on:
  #   1. Create minio system user and group
  #   2. Create the folder that will hold the files
  #   3. Install MinIO server and client
  #   4. Initialize MinIO creating an alias, access/secret keys and raw-data bucket
  printf "  Installing module 'minio' ... "
  create_minio-user >>$OSBDET_LOGFILE 2>&1
  create_data_folder >>$OSBDET_LOGFILE 2>&1
  install_minio >>$OSBDET_LOGFILE 2>&1
  initialize_minio >>$OSBDET_LOGFILE 2>&1
  printf "[Done]\n"
  debug "minio.module_install DEBUG [`date +"%Y-%m-%d %T"`] Module installation done" >> $OSBDET_LOGFILE
}

module_status() {
  if [ -d "/data/s3" ]
  then
    echo "Module is installed [OK]"
    exit 0
  else
    echo "Module is not installed [KO]"
    exit 1
  fi
}

module_uninstall(){
  debug "minio.module_uninstall DEBUG [`date +"%Y-%m-%d %T"`] Starting module uninstallation" >> $OSBDET_LOGFILE
  # The uninstallation of this module consists on:
  #   1. MinIO server and client uninstallation
  #   2. Data folder deletion
  #   3. Delete system user and group
  printf "  Uninstalling module 'minio' ... "
  uninstall_minio >>$OSBDET_LOGFILE 2>&1
  remove_data_folder >>$OSBDET_LOGFILE 2>&1
  remove_minio-user >>$OSBDET_LOGFILE 2>&1
  printf "[Done]\n"
  debug "minio.module_uninstall DEBUG [`date +"%Y-%m-%d %T"`] Module uninstallation done" >> $OSBDET_LOGFILE
}

usage() {
  echo Starting \'minio\' module
  echo Usage: script.sh [OPTION]
  echo
  echo Available options for this module:
  echo "  install             module installation"
  echo "  status              module installation status check"
  echo "  uninstall           module uninstallation"
}

main(){
  # 1. Set logfile to /dev/null if it doesn't exist
  if [ -z "$OSBDET_LOGFILE" ] ; then
    export OSBDET_LOGFILE=/dev/null
  fi
  # 2. Main function
  debug "minio DEBUG [`date +"%Y-%m-%d %T"`] Starting activity with the minio module" >> $OSBDET_LOGFILE
  if [ $# -eq 1 ]
  then
    if [ "$1" == "install" ]
    then
      module_install
    elif [ "$1" == "status" ]
    then
      module_status
    elif [ "$1" == "uninstall" ]
    then
      module_uninstall
    else
      usage
      exit -1
    fi
  else
    usage
    exit -1
  fi
  debug "minio DEBUG [`date +"%Y-%m-%d %T"`] Activity with the minio module is done" >> $OSBDET_LOGFILE
}

if ! [ -z "$*" ]
then
  SCRIPT_PATH=$(dirname $(realpath $0))
  SCRIPT_HOME=$SCRIPT_PATH/../..
  OSBDET_HOME=$SCRIPT_HOME/../..
  main $*
fi
