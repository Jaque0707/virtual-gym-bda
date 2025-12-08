#!/bin/bash

# ======================================================
# Script: s-01-dispositivos-almacenamiento-root.sh
# Autor: Benítez Pérez Michelle Paulina
#        Hernández García Pilar Jaqueline
# Fecha: 05/12/2025
# Descripción: Creación de loop devices para simular discos.
# ======================================================
mkdir -p /unam/bda/disk-images
cd /unam/bda/disk-images

dd if=/dev/zero of=disk11.img bs=100M count=10
dd if=/dev/zero of=disk12.img bs=100M count=10
dd if=/dev/zero of=disk13.img bs=100M count=10

# Verificar los archivos creados
du -sh disk*.img

# Asociar cada imagen con un loop device disponible
losetup -fP disk11.img
losetup -fP disk12.img
losetup -fP disk13.img

# Confirmar la asociación
losetup -a

# Formatear cada imagen 
mkfs.ext4 disk11.img
mkfs.ext4 disk12.img
mkfs.ext4 disk13.img

# Crear directorios de montaje
mkdir -p /unam/bda/pf/c0/d11
mkdir -p /unam/bda/pf/c0/d12
mkdir -p /unam/bda/pf/c0/d13