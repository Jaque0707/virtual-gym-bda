#!/bin/bash
# ======================================================
# Autor: Benítez Pérez Michelle Paulina
#        Hernández García Pilar Jaqueline
# Fecha: 14/12/2025
# ======================================================
# Script para simular el ciclo de backups semanal del Caso Virtual Gym
#   - Módulo Infraestructura: aparatos y cambios de status
#   - Módulo Operación: sesiones de clientes y bitácora de calorías

USER_INFRA="infra_admin/infra_admin@pf_infraestr"
USER_OPERA="opera_admin/opera_admin@pf_operacion"

pausa() {
    echo
    read -p "Presiona ENTER para continuar con el siguiente día..." _
    echo
}

# ==========================================
# DOMINGO: Full Backup Incremental Nivel 0 + Carga Baja
# ==========================================

echo "==> Simulando carga: Domingo"
sqlplus -s $USER_INFRA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_gym(p_num_aparatos => 5, p_porcentaje_cambios => 5);
EOF

sqlplus -s $USER_OPERA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_sesiones(p_num_sesiones => 5, p_duracion_min => 30, p_duracion_max => 120);
EOF

echo "==> Backup RMAN Nivel 0..."
rman @rman-ciclo-respaldos/s-01-domingo.rman

pausa

# ==========================================
## LUNES: Incremental Nivel 1 Diferencial + Carga Alta
## ==========================================

echo "==> Simulando carga: Lunes"
sqlplus -s $USER_INFRA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_gym(p_num_aparatos => 15, p_porcentaje_cambios => 15);
EOF

sqlplus -s $USER_OPERA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_sesiones(p_num_sesiones => 8, p_duracion_min => 30, p_duracion_max => 120);
EOF

echo "==> Backup RMAN Incremental Nivel 1 Diferencial"
rman @rman-ciclo-respaldos/s-02-lunes.rman

pausa

## ==========================================
## MARTES: Incremental 1 Cumulativo + Carga Moderada + Punto de Consulta
## ==========================================

echo "==> Simulando carga: Martes"
sqlplus -s $USER_INFRA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_gym(p_num_aparatos => 10, p_porcentaje_cambios => 10);
EOF

sqlplus -s $USER_OPERA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_sesiones(p_num_sesiones => 7, p_duracion_min => 30, p_duracion_max => 120);
EOF

echo
echo "==> Backup RMAN Incremental Nivel 1 Cumulativo"
rman @rman-ciclo-respaldos/s-03-martes.rman

pausa

## ==========================================
## MIÉRCOLES: Incremental 1 Diferencial + Carga Moderada-Alta
## ==========================================

echo "==> Simulando carga: Miércoles"
sqlplus -s $USER_INFRA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_gym(p_num_aparatos => 10, p_porcentaje_cambios => 12);
EOF

sqlplus -s $USER_OPERA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_sesiones(p_num_sesiones => 8, p_duracion_min => 30, p_duracion_max => 120);
EOF

echo "==> Backup RMAN Incremental Nivel 1 Diferencial"
rman @rman-ciclo-respaldos/s-04-miercoles.rman

pausa

## ==========================================
## JUEVES: Incremental 1 Diferencial + Carga Moderada
## ==========================================

echo "==> Simulando carga: Jueves"
sqlplus -s $USER_INFRA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_gym(p_num_aparatos => 10, p_porcentaje_cambios => 10);
EOF

sqlplus -s $USER_OPERA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_sesiones(p_num_sesiones => 6, p_duracion_min => 30, p_duracion_max => 120);
EOF

echo "==> Backup RMAN Incremental Nivel 1 Diferencial"
rman @rman-ciclo-respaldos/s-05-jueves.rman

pausa

## ==========================================
## VIERNES: Incremental 1 Diferencial + Carga Moderada + Punto de Consulta
## ==========================================

echo "==> Simulando carga: Viernes"
sqlplus -s $USER_INFRA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_gym(p_num_aparatos => 12, p_porcentaje_cambios => 10);
EOF

sqlplus -s $USER_OPERA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_sesiones(p_num_sesiones => 6, p_duracion_min => 30, p_duracion_max => 120);
EOF

echo "==> Backup RMAN Incremental Nivel 1 Diferencial"
rman @rman-ciclo-respaldos/s-06-viernes.rman

pausa

## ==========================================
## SÁBADO: Incremental 1 Diferencial + Carga Alta + DELETE OBSOLETE
## ==========================================

echo "==> Simulando carga: Sábado"
sqlplus -s $USER_INFRA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_gym(p_num_aparatos => 8, p_porcentaje_cambios => 8);
EOF

sqlplus -s $USER_OPERA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_sesiones(p_num_sesiones => 9, p_duracion_min => 30, p_duracion_max => 120);
EOF

echo "==> Backup RMAN Incremental Nivel 1 Diferencial"
rman @rman-ciclo-respaldos/s-07-sabado.rman

pausa

## ==========================================
## RESUMEN DEL CICLO SEMANAL UNIFICADO
## ==========================================
## DOMINGO
##   * Backup: Incremental Nivel 0 (Base completa)
##   * Infraestructura: 5 aparatos nuevos, 5% cambios status
##   * Operación: 50 sesiones
##   * Acción especial: DELETE OBSOLETE
## ==========================================
## LUNES
##   * Backup: Incremental Nivel 1 Diferencial
##   * Infraestructura: 15 aparatos nuevos, 15% cambios status
##   * Operación: 80 sesiones
##   * Razón: Inicio de semana, alta demanda
## ==========================================
## MARTES
##   * Backup: Incremental Nivel 1 CUMULATIVO
##            (absorbe la carga alta del lunes)
##   * Infraestructura: 10 aparatos nuevos, 10% cambios status
##   * Operación: 70 sesiones
##   * Verificación: RESTORE PREVIEW + LIST BACKUP
## ==========================================
## MIÉRCOLES
##   * Backup: Incremental Nivel 1 Diferencial
##   * Infraestructura: 10 aparatos nuevos, 12% cambios status
##   * Operación: 85 sesiones (pico de media semana)
## ==========================================
## JUEVES
##   * Backup: Incremental Nivel 1 Diferencial
##   * Infraestructura: 10 aparatos nuevos, 10% cambios status
##   * Operación: 65 sesiones
## ==========================================
## VIERNES
##   * Backup: Incremental Nivel 1 Diferencial
##   * Infraestructura: 12 aparatos nuevos, 10% cambios status
##   * Operación: 60 sesiones
##   * Verificación: RESTORE PREVIEW + REPORT OBSOLETE
## ==========================================
## SÁBADO
##   * Backup: Incremental Nivel 1 Diferencial
##   * Infraestructura: 8 aparatos nuevos, 8% cambios status
##   * Operación: 90 sesiones (pico de fin de semana)
##   * Acción especial: DELETE OBSOLETE
## ==========================================
