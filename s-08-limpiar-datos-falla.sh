#!/bin/bash

# Autor: Benítez Pérez Michelle Paulina
#        Hernández García Pilar Jaqueline
# Fecha: 05/12/2025

echo "Realizando limpieza en caso de ser necesario"
rm -f /unam/bda/disks/d11/app/oracle/oradata/FREE/*
rm -f /unam/bda/disks/d12/app/oracle/oradata/FREE/*
rm -f /unam/bda/disks/d13/app/oracle/oradata/FREE/*
rm -f /unam/bda/disks/d14/fra/*
rm -f /opt/oracle/oradata/FREE/*.dbf
rm -f /opt/oracle/oradata/FREE/pdbseed/*.dbf
