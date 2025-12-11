#!/bin/bash

#Nivel: S.O Contenedor
#Usuario: Oracle 

# ======================================================
# Script: pwdfile 
# Autor: Benítez Pérez Michelle Paulina
#        Hernández García Pilar Jaqueline
# Fecha: 05/12/2025
# ======================================================


archivoPwd="/opt/oracle/product/23ai/dbhomeFree/dbs/orapwfree"

echo "Borrando el archivo de passwords si existe"
rm -f ${archivoPwd}

echo "Verificando que el archivo haya sido realmente eliminado"

if [ -f "${archivoPwd}" ]; then
  echo "ERROR: El archivo de passwords NO fue borrado."
  exit 2
fi;

echo "Generando un archivo de passwords nuevo, proporcionar el password de SYS a Med1aStream*"

# Cambiar las comillas simples a dobles para que la variable se expanda correctamente
/opt/oracle/product/23ai/dbhomeFree/bin/orapwd FILE="/opt/oracle/product/23ai/dbhomeFree/dbs/orapwfree" \
FORMAT=12.2 \
SYS=password password=Med1aStream*

echo "validando la existencia del nuevo archivo"
if [ -f "${archivoPwd}" ]; then
  echo "OK. Archivo de password generado"
else
  echo "ERROR: El archivo de passwords no ha sido regenerado"
  exit 1
fi;
