#!/bin/bash

# ======================================================
# Script: s-01-dispositivos-almacenamiento-root.sh
# Autor: Benítez Pérez Michelle Paulina
#        Hernández García Pilar Jaqueline
# Fecha: 05/12/2025
# ======================================================


echo "Creando archivo de parametros"

export ORACLE_SID=free
pfile=$ORACLE_HOME/dbs/init${ORACLE_SID}.ora

if [ -f "${pfile}" ]; then
  read -p "El archivo ${pfile} ya existe, [Enter] para sobrescribir"
fi;

echo \
"db_name=free
memory_target=2G
processes=300
db_block_size=8192
db_domain=fi.unam
enable_pluggable_database=true
db_recovery_file_dest_size=40G
db_recovery_file_dest=/unam/bda/pf/c3/d14/fra
undo_tablespace=UNDOTBS1
db_flashback_retention_target=1440
open_cursors=300
diagnostic_dest=/unam/bda/pf/c3/d15/diagnostic
log_archive_max_processes=2
log_archive_format=arch_%t_%s_%r.arc
log_archive_dest_1='LOCATION=/unam/bda/pf/c3/archivelogs/FREE/disk_a MANDATORY'
log_archive_dest_2='LOCATION=USE_DB_RECOVERY_FILE_DEST'
log_archive_min_succeed_dest=1
" > $pfile

echo "Listo"
echo "Comprobando la existencia y contenido del PFILE"
echo ""
cat ${pfile}