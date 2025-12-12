#!/bin/bash
#@Autor(es):   Benítez Pérez Michelle Paulina
#              Pilar Jaqueline Hernández García
#@Fecha creación: 8/12/2025
#@Descripción: el script crea directorios para los datafiles de los tablespaces

cd /unam/bda/pf/c1
for i in d01 d02; do
  if [ ! -d "$i" ]; then
    mkdir -p $i
    chown -R oracle:oinstall $i
    chmod -R 750 $i
    echo "Directorios creados en /unam/bda/pf/c1"
  else
    echo "El directorio /unam/bda/pf/c1/$i ya existe. No se realiza ninguna acción."
  fi
done

cd /unam/bda/pf/c2
for i in d01 d02; do
  if [ ! -d "$i" ]; then
    mkdir -p $i
    chown -R oracle:oinstall $i
    chmod -R 750 $i
    echo "Directorios creados en /unam/bda/pf/c2"
  else
    echo "El directorio /unam/bda/pf/c2/$i ya existe. No se realiza ninguna acción."
  fi
done