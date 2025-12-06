#!/bin/bash

# ======================================================
# Script: s-01-dispositivos-almacenamiento-root.sh
# Autor: Benítez Pérez Michelle Paulina
#        Hernandez Garcia Pilar Jaquelin
# Fecha: 05/12/2025

mkdir /tmp/dd-logs
cd $ORACLE_HOME/rdbms/admin
perl -I $ORACLE_HOME/rdbms/admin \
$ORACLE_HOME/rdbms/admin/catcdb.pl \
--logDirectory /tmp/dd-logs \
--logFilename dd.log \
--logErrorsFilename dderror.log 