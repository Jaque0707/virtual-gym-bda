#!/bin/bash

# ======================================================
# Script: s-01-dispositivos-almacenamiento-root.sh
# Autor: Benítez Pérez Michelle Paulina
#        Hernandez Garcia Pilar Jaquelin
# Fecha: 05/12/2025



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
control_files=(
    /unam/bda/disks/d11/app/oracle/oradata/FREE/control01.ctl,
    /unam/bda/disks/d12/app/oracle/oradata/FREE/control02.ctl,
    /unam/bda/disks/d13/app/oracle/oradata/FREE/control03.ctl
)
db_block_size=8192
db_domain=fi.unam
db_recovery_file_dest=/unam/bda/disks/d14/fra
db_recovery_file_dest_size=20G
undo_tablespace=UNDOTBS1
db_flashback_retention_target=1440
open_cursors=300
diagnostic_dest=/unam/bda/disks/d11
log_archive_max_processes=2
log_archive_format=arch_%t_%s_%r.arc
log_archive_dest_1='LOCATION=/unam/bda/archivelogs/FREE/disk_a MANDATORY'
log_archive_min_succeed_dest=1
log_archive_trace=12
" > $pfile

echo "Listo"
echo "Comprobando la existencia y contenido del PFILE"
echo ""
cat ${pfile}