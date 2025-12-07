#!/bin/bash
#@Autor(es): Benítez Pérez Michelle Paulina
#            Hernández García Pilar Jaqueline
#@Fecha creación: 07/12/2025
#@Descripción: Crea un contenedor de Docker para el proyecto

sudo docker run -i -t \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-v ${UNAM_HOME}:${UNAM_HOME} \
--name c-phg-proy-final \
--hostname h-phg-proy-final.fi.unam \
--network bda_network --ip 172.22.0.33 \
--expose 1521 \
--shm-size=2gb \
-e DISPLAY=$DISPLAY ol-phg:1.0 bash
