#!/bin/bash
#usuario: root 
#Nivel: S.O host 
# ======================================================
# Script: s-01-dispositivos-almacenamiento-root.sh
# Autor: Benítez Pérez Michelle Paulina
#        Hernández García Pilar Jaqueline
# Fecha: 05/12/2025
# Descripción: Creación de loop devices para simular discos.
# ======================================================
mkdir -p /unam/bda/disk-images
cd /unam/bda/disk-images

# Crea en la carpeta un archivo binarios de 1G que representa los loop devices
dd if=/dev/zero of=disk11.img bs=100M count=10
dd if=/dev/zero of=disk12.img bs=100M count=10
dd if=/dev/zero of=disk13.img bs=100M count=10

# Comprueba la creación de los archivos
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

# Para montar los loopdevices por cada uno realizar: 
# sudo mount -o loop /dev/loop* ${UNAM_HOME}/bda/pf/c0/d1*
# Redirigirse a /etc/fstab y agregar 
# /unam/bda/disk-images/disk1*.img  /unam/bda/pf/c0/d1* auto loop 0 0
# Probar y montar:
# sudo mount -a 
# Reiniciar
# Comprobar que funciona:
# df -h | grep "${UNAM_HOME}/bda/*"e