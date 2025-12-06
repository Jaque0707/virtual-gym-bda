#!/bin/bash
# ======================================================
# Script: s-03-01-crear-directorios-root.sh
# Autor: Benítez Pérez Michelle Paulina
#        Hernandez Garcia Pilar Jaquelin
# Fecha: 05/12/2025
# Descripción: Creación de directorios para Datafiles, Redo Logs, Archivelogs, FRA.
# ======================================================
set -e

OWNER="oracle"
GROUP="oinstall"

echo "Creando directorios para CDB..."
if [ ! -d "/opt/oracle/oradata/FREE" ]; then
  mkdir -p /opt/oracle/oradata/FREE
  chown -R "$OWNER:$GROUP" /opt/oracle/oradata
  chmod -R 750 /opt/oracle/oradata
else
  echo "El directorio /opt/oracle/oradata/FREE ya existe. No se realiza ninguna acción."
fi

echo "Creando directorios para PDB..."
if [ ! -d "/opt/oracle/oradata/FREE/pdbseed" ]; then
  mkdir -p /opt/oracle/oradata/FREE/pdbseed
  chown "$OWNER:$GROUP" /opt/oracle/oradata/FREE/pdbseed
  chmod 750 /opt/oracle/oradata/FREE/pdbseed
else
  echo "El directorio /opt/oracle/oradata/FREE/pdbseed ya existe. No se realiza ninguna acción."
fi

echo "Creando directorios para control files y Redo Logs..."
for i in d11 d12 d13; do
  if [ ! -d "/unam/bda/disks/$i/app/oracle/oradata/FREE" ]; then
    mkdir -p /unam/bda/disks/$i/app/oracle/oradata/FREE
    chown -R "$OWNER:$GROUP" /unam/bda/disks/$i/app/oracle/oradata
    chmod -R 750 /unam/bda/disks/$i/app/oracle/oradata
  else
    echo "El directorio /unam/bda/disks/$i/app/oracle/oradata/FREE ya existe. No se realiza ninguna acción."
  fi
done

echo "Creando directorio para FRA..."
if [ ! -d "/unam/bda/disks/d14/fra" ]; then
  mkdir -p /unam/bda/disks/d14/fra
  chown -R "$OWNER:$GROUP" /unam/bda/disks/d14
  chmod -R 750 /unam/bda/disks/d14
else
  echo "El directorio /unam/bda/disks/d14/fra ya existe. No se realiza ninguna acción."
fi

echo "Creando directorios para Archivelogs..."
BASE_DIR="/unam/bda/archivelogs/FREE"
DIR_A="${BASE_DIR}/disk_a"
DIR_B="${BASE_DIR}/disk_b"

if [ ! -d "$DIR_A" ]; then
  mkdir -p "$DIR_A"
  chown -R "$OWNER:$GROUP" /unam/bda/archivelogs
  chmod -R 750 /unam/bda/archivelogs
else
  echo "El directorio $DIR_A ya existe. No se realiza ninguna acción."
fi

if [ ! -d "$DIR_B" ]; then
  mkdir -p "$DIR_B"
  chown -R "$OWNER:$GROUP" /unam/bda/archivelogs
  chmod -R 750 /unam/bda/archivelogs
else
  echo "El directorio $DIR_B ya existe. No se realiza ninguna acción."
fi

echo "Estructura creada correctamente con propietario $OWNER:$GROUP y permisos seguros."
