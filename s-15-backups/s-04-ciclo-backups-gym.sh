#!/bin/bash
# ======================================================
# Autor: Benítez Pérez Michelle Paulina
#        Hernández García Pilar Jaqueline
# Fecha: 10/12/2025
# ======================================================
# Script para simular el ciclo de backups semanal del Caso Virtual Gym

USER_BD="infra_admin/infra_admin@pf_infraestr"

pausa() {
    echo
    read -p "Presiona ENTER para continuar con el siguiente día..." _
    echo
}

echo "=========================================="
echo " INICIANDO CICLO DE RESPALDOS SEMANAL"
echo "=========================================="

# ==========================================
# DOMINGO: Full Backup Incremental Nivel 0 + Carga Baja (200)
# ==========================================

echo "-- DOMINGO -----------------------------------------------------"

rman @rman-ciclo-respaldos/s-01-domingo.rman

sqlplus -s $USER_BD << EOF
    SET SERVEROUTPUT ON
    EXEC simula_carga_gym(2);
EOF

pausa

# ==========================================
## LUNES: Incremental Nivel 1 Diferencial + Carga Alta (600)
## ==========================================
echo "-- LUNES -------------------------------------------------------"

rman @rman-ciclo-respaldos/s-02-lunes.rman

sqlplus -s $USER_BD << EOF
    SET SERVEROUTPUT ON
    EXEC simula_carga_gym(6);
EOF

pausa

## ==========================================
## MARTES: Incremental 1 Cumulativo + Carga Moderada (400) + Punto de Consulta
## ==========================================
echo "-- MARTES -------------------------------------------------------"

rman @rman-ciclo-respaldos/s-03-martes.rman

sqlplus -s $USER_BD << EOF
    SET SERVEROUTPUT ON
    EXEC simula_carga_gym(4);
EOF

pause

## ==========================================
## MIÉRCOLES: Incremental 1 Diferencial + Carga Moderada (400)
## ==========================================
echo "-- MIERCOLES ----------------------------------------------------"

rman @rman-ciclo-respaldos/s-04-miercoles.rman

sqlplus -s $USER_BD << EOF
    SET SERVEROUTPUT ON
    EXEC simula_carga_gym(4);
EOF

pausa

## ==========================================
## JUEVES: Incremental 1 Diferencial + Carga Moderada (400)
## ==========================================
echo "-- JUEVES -------------------------------------------------------"

rman @rman-ciclo-respaldos/s-05-jueves.rman

sqlplus -s $USER_BD << EOF
    SET SERVEROUTPUT ON
    EXEC simula_carga_gym(4);
EOF

pausa

## ==========================================
## VIERNES: Incremental 1 Diferencial + Carga Moderada (400) + Punto de Consulta
## ==========================================
echo "-- VIERNES ------------------------------------------------------"

rman @rman-ciclo-respaldos/s-06-viernes.rman

sqlplus -s $USER_BD << EOF
    SET SERVEROUTPUT ON
    EXEC simula_carga_gym(4);
EOF

pausa

## ==========================================
## SÁBADO: Incremental 1 Diferencial + Carga Baja (300) # CAMBIAR
## ==========================================
echo "-- SABADO -------------------------------------------------------"

rman @rman-ciclo-respaldos/s-07-sabado.rman

sqlplus -s $USER_BD << EOF
    SET SERVEROUTPUT ON
    EXEC simula_carga_gym(3);
EOF

pausa

echo "=========================================="
echo " CICLO SEMANAL COMPLETADO"
echo "=========================================="



## ==========================================
## RESUMEN DEL CICLO SEMANAL DE BACKUPS
## ==========================================
## DOMINGO
##   * Backup: Incremental Nivel 0 (Base completa)
##   * Carga: Baja (2 cambios de estatus)
##   * Acción especial: DELETE OBSOLETE
## ==========================================
## LUNES
##   * Backup: Incremental Nivel 1 Diferencial
##   * Carga: Alta (6 cambios de estatus)
## ==========================================
## MARTES
##   * Backup: Incremental Nivel 1 CUMULATIVO
##            (absorbe la carga alta del lunes)
##   * Carga: Moderada (4 cambios de estatus)
##   * Verificación: RESTORE PREVIEW + LIST BACKUP
## ==========================================
## MIÉRCOLES
##   * Backup: Incremental Nivel 1 Diferencial
##   * Carga: Moderada (4 cambios de estatus)
## ==========================================
## JUEVES
##   * Backup: Incremental Nivel 1 Diferencial
##   * Carga: Moderada (4 cambios de estatus)
## ==========================================
## VIERNES
##   * Backup: Incremental Nivel 1 Diferencial
##   * Carga: Moderada (4 cambios de estatus)
##   * Verificación: RESTORE PREVIEW + REPORT OBSOLETE
## ==========================================
## SÁBADO
##   * Backup: Incremental Nivel 1 Diferencial
##   * Carga: Baja (3 cambios de estatus)
##   * Acción especial: DELETE OBSOLETE
## ==========================================