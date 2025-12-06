#!/bin/bash

# ======================================================
# Script: s-01-dispositivos-almacenamiento-root.sh
# Autor: Benítez Pérez Michelle Paulina
#        Hernandez Garcia Pilar Jaquelin
# Fecha: 05/12/2025
# Descripción: Creación de loop devices para simular discos.
# ======================================================
mkdir -p /unam/bda/disk-images
cd /unam/bda/disk-images

dd if=/dev/zero of=disk1.img bs=100M count=10
dd if=/dev/zero of=disk2.img bs=100M count=10
dd if=/dev/zero of=disk3.img bs=100M count=10

# Verificar los archivos creados
du -sh disk*.img

# Asociar cada imagen con un loop device disponible
losetup -fP disk1.img
losetup -fP disk2.img
losetup -fP disk3.img

# Confirmar la asociación
losetup -a

# Formatear cada imagen 
mkfs.ext4 disk1.img
mkfs.ext4 disk2.img
mkfs.ext4 disk3.img

# Crear directorios de montaje
mkdir -p /unam/bda/disks/d11
mkdir -p /unam/bda/disks/d12
mkdir -p /unam/bda/disks/d13