#!/bin/bash
# ======================================================
# Script: s-03-01-crear-directorios-root.sh
# Autor: Benítez Pérez Michelle Paulina
#        Hernández García Pilar Jaqueline
# Fecha: 08/12/2025
# Descripción: Copiar el archivo de control que esta en FRA a las otras dos rutas
# ======================================================

# Ejecutar con oracle en el contenedor

cp /unam/bda/disks/d14/fra/FREE/controlfile/o1_mf_nmfmw641_.ctl \
/unam/bda/pf/c0/d11/app/oracle/oradata/FREE/control01.ctl

cp /unam/bda/disks/d14/fra/FREE/controlfile/o1_mf_nmfmw641_.ctl \
/unam/bda/pf/c0/d12/app/oracle/oradata/FREE/control02.ctl

echo "Copia lista"