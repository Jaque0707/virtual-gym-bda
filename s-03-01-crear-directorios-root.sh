#!/bin/bash
# ======================================================
# Script: s-03-01-crear-directorios-root.sh
# Autor: Benítez Pérez Michelle Paulina
#        Hernández García Pilar Jaqueline
# Fecha: 07/12/2025
# Descripción: Creación de directorios para Datafiles, Redo Logs, Archivelogs, FRA.
# ======================================================

set -e

OWNER="oracle"
GROUP="oinstall"

# ==========================================================================================
# directorios anteriores
# ==========================================================================================
#cd /opt/oracle
#
#echo "Creando directorios para CDB..."
#if [ ! -d "oradata/FREE" ]; then
#  mkdir -p oradata/FREE
#  chown -R "$OWNER:$GROUP" oradata
#  chmod -R 750 oradata
#else
#  echo "El directorio /opt/oracle/oradata/FREE ya existe. No se realiza ninguna acción."
#fi
#
#cd /opt/oracle/oradata/FREE
#
#echo "Creando directorios para PDB..."
#if [ ! -d "pdbseed" ]; then
#  mkdir -p pdbseed
#  chown "$OWNER:$GROUP" pdbseed
#  chmod 750 pdbseed
#else
#  echo "El directorio /opt/oracle/oradata/FREE/pdbseed ya existe. No se realiza ninguna acción."
#fi

# ===========================================================================================

echo "Creando directorios para Control files y Redo Logs..."
cd /unam/bda/pf/c0
for i in d11 d12 d13; do
  if [ ! -d "$i/app/oracle/oradata/FREE" ]; then
    mkdir -p $i/app/oracle/oradata/FREE
    chown -R "$OWNER:$GROUP" $i/app/oracle/oradata
    chmod -R 750 $i/app/oracle/oradata
  else
    echo "El directorio /unam/bda/pf/c0/$i/app/oracle/oradata/FREE ya existe. No se realiza ninguna acción."
  fi
done



echo "Creando directorio para FRA..."
if [ ! -d "/unam/bda/pf/c3/d14/fra" ]; then
  mkdir -p /unam/bda/pf/c3/d14/fra
  chown -R "$OWNER:$GROUP" /unam/bda/pf/c3/d14/fra
  chmod -R 750 /unam/bda/pf/c3/d14
else
  echo "El directorio /unam/bda/pf/c3/d14/fra ya existe. No se realiza ninguna acción."
fi



echo "Creando directorios para Archivelogs..."
BASE_DIR="/unam/bda/pf/c3/archivelogs/FREE"
DIR_A="${BASE_DIR}/disk_a"

if [ ! -d "$DIR_A" ]; then
  mkdir -p "$DIR_A"
  chown -R "$OWNER:$GROUP" /unam/bda/pf/c3/archivelogs
  chmod -R 750 /unam/bda/pf/c3/archivelogs
else
  echo "El directorio $DIR_A ya existe. No se realiza ninguna acción."
fi



echo "Creando directorios para diagnostic_dest..."
if [ ! -d "/unam/bda/pf/c3/d15/diagnostic" ]; then
  mkdir -p /unam/bda/pf/c3/d15/diagnostic
  chown -R "$OWNER:$GROUP" /unam/bda/pf/c3/d15/diagnostic
  chmod -R 750 /unam/bda/pf/c3/d15/diagnostic
else
  echo "El directorio /unam/bda/pf/c3/d15/diagnostic ya existe. No se realiza ninguna acción."
fi


# directorios para datafiles de datos, indices, tablespaces de los modulos - capas de almacenamiento

cd /unam/bda/pf

echo "Creando directorios para datafiles en c1"
if [ -d "c1" ]; then 
  echo "El directorio ya existe"
else
  mkdir -p c1
  chown -R root:root c1
  chmod -R 755 c1
  echo "Directorio creado"
fi;

cd /unam/bda/pf

echo "Creando directorios para datafiles en c2"
if [ -d "c2" ]; then 
  echo "El directorio ya existe"
else
  mkdir -p c2
  chown -R root:root c2
  chmod -R 755 c2
  echo "Directorio creado"
fi;


# directorio para archivo de rastreo rman 
cd /unam/bda/pf/c0

echo "Creando directorio para archivo de rastreo rman"
if [ -d "d10/block-tracking" ]; then 
  echo "El directorio ya existe"
else
  mkdir -p d10/block-tracking
  chown -R oracle:oinstall d10/block-tracking
  chmod -R 755 d10/block-tracking
  echo "Directorio creado"
fi;

# ===================================================================================
# directorios actuales: considerando capas de almacenamiento 
# ===================================================================================

# datafiles con capas de almacenamiento
# /unam/bda/pf/c0/d05/FREE
# /unam/bda/pf/c2/d05/FREE

cd /unam/bda/pf/c0

echo "Creando directorio para Datafiles"
if [ ! -d "d05/FREE" ]; then
  mkdir -p d05/FREE
  chown -R "$OWNER:$GROUP" d05/FREE
  chmod -R 750 d05/FREE
else
  echo "El directorio d05/FREE ya existe. No se realiza ninguna acción."
fi

cd /unam/bda/pf/c0/d05/FREE

echo "Creando directorio para Datafiles"
if [ ! -d "pdbseed" ]; then
  mkdir -p pdbseed
  chown -R "$OWNER:$GROUP" pdbseed
  chmod -R 750 pdbseed
else
  echo "El directorio pdbseed ya existe. No se realiza ninguna acción."
fi

cd /unam/bda/pf/c2

echo "Creando directorio para Datafiles"
if [ ! -d "d05/FREE" ]; then
  mkdir -p d05/FREE
  chown -R "$OWNER:$GROUP" d05/FREE
  chmod -R 750 d05/FREE
else
  echo "El directorio d05/FREE ya existe. No se realiza ninguna acción."
fi

cd /unam/bda/pf/c2/d05/FREE

echo "Creando directorio para Datafiles"
if [ ! -d "pdbseed" ]; then
  mkdir -p pdbseed
  chown -R "$OWNER:$GROUP" pdbseed
  chmod -R 750 pdbseed
else
  echo "El directorio pdbseed ya existe. No se realiza ninguna acción."
fi