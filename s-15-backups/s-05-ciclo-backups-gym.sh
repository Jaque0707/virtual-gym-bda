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



# antes de iniciar el ciclo eliminar backups por espacio ...

echo "==> Eliminar Backups en RMAN "
rman @rman-ciclo-respaldos/s-00-borra-backups.rman


# ==========================================
# DOMINGO: Full Backup Incremental Nivel 0 + Carga Baja
# ==========================================

# respaldo a las 2:00 am
echo "==> Backup RMAN Nivel 0..."
rman @rman-ciclo-respaldos/s-01-domingo.rman
rman @rman-ciclo-respaldos/s-01-domingo-infra.rman
rman @rman-ciclo-respaldos/s-01-domingo-opera.rman

# llegan nuevos aparatos a los gimnasios, casi no cambia el status por carga baja
# pocas sesiones de menos duración 

echo "==> Simulando carga: Domingo"
sqlplus -s $USER_INFRA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_gym(p_num_aparatos => 10, p_porcentaje_cambios => 1);
EOF

sqlplus -s $USER_OPERA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_sesiones(p_num_sesiones => 5, p_duracion_min => 10, p_duracion_max => 30);
EOF

pausa

# ==========================================
## LUNES: Incremental Nivel 1 Diferencial + Carga Alta
## ==========================================

# respaldo a las 3:00 am
echo "==> Backup RMAN Incremental Nivel 1 Diferencial"
rman @rman-ciclo-respaldos/s-02-lunes.rman

# casi no llegan aparatos y cambia el estatus de varios por alta carga
# más sesiones de más duración 

echo "==> Simulando carga: Lunes"
sqlplus -s $USER_INFRA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_gym(p_num_aparatos => 3, p_porcentaje_cambios => 15);
EOF

sqlplus -s $USER_OPERA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_sesiones(p_num_sesiones => 15, p_duracion_min => 30, p_duracion_max => 120);
EOF

pausa

## ==========================================
## MARTES: Incremental 1 Cumulativo + Carga Moderada + Punto de Consulta
## ==========================================

# respaldo a las 3:00 am
echo
echo "==> Backup RMAN Incremental Nivel 1 Cumulativo"
rman @rman-ciclo-respaldos/s-03-martes.rman

# casi no llegan aparatos y cambia el estatus de varios por carga moderada
# cantidad moderada de sesiones duración de hasta 100 minutos

echo "==> Simulando carga: Martes"
sqlplus -s $USER_INFRA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_gym(p_num_aparatos => 3, p_porcentaje_cambios => 10);
EOF

sqlplus -s $USER_OPERA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_sesiones(p_num_sesiones => 10, p_duracion_min => 30, p_duracion_max => 100);
EOF

pausa

## ==========================================
## MIÉRCOLES: Incremental 1 Diferencial + Carga Moderada-Alta
## ==========================================

# respaldo a las 3:00 am
echo "==> Backup RMAN Incremental Nivel 1 Diferencial"
rman @rman-ciclo-respaldos/s-04-miercoles.rman

# casi no llegan aparatos y cambia el estatus de varios por carga moderada-alta
# cantidad moderada-alta de sesiones duración de hasta 100 minutos

echo "==> Simulando carga: Miércoles"
sqlplus -s $USER_INFRA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_gym(p_num_aparatos => 3, p_porcentaje_cambios => 12);
EOF

sqlplus -s $USER_OPERA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_sesiones(p_num_sesiones => 12, p_duracion_min => 30, p_duracion_max => 100);
EOF

pausa

## ==========================================
## JUEVES: Incremental 1 Diferencial + Carga Moderada
## ==========================================

# respaldo a las 3:00 am
echo "==> Backup RMAN Incremental Nivel 1 Diferencial"
rman @rman-ciclo-respaldos/s-05-jueves.rman

# casi no llegan aparatos y cambia el estatus de varios por carga moderada
# cantidad moderada de sesiones duración de hasta 100 minutos

echo "==> Simulando carga: Jueves"
sqlplus -s $USER_INFRA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_gym(p_num_aparatos => 3, p_porcentaje_cambios => 10);
EOF

sqlplus -s $USER_OPERA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_sesiones(p_num_sesiones => 10, p_duracion_min => 30, p_duracion_max => 100);
EOF

pausa

## ==========================================
## VIERNES: Incremental 1 Diferencial + Carga Moderada + Punto de Consulta
## ==========================================

echo
read -p "Base de datos en mount. Para hacer backups en modo CONSISTENTE. Presiona ENTER para continuar ... " _
echo

# respaldo a las 3:00 am
echo "==> Backup RMAN Incremental Nivel 1 Diferencial"
rman @rman-ciclo-respaldos/s-06-viernes.rman

echo
read -p "Base de datos en open. Para cargar los datos. Presiona ENTER para continuar ... " _
echo

# casi no llegan aparatos y cambia el estatus de varios por carga moderada
# cantidad moderada de sesiones duración de hasta 100 minutos

echo "==> Simulando carga: Viernes"
sqlplus -s $USER_INFRA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_gym(p_num_aparatos => 3, p_porcentaje_cambios => 10);
EOF

sqlplus -s $USER_OPERA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_sesiones(p_num_sesiones => 10, p_duracion_min => 30, p_duracion_max => 100);
EOF

pausa

## ==========================================
## SÁBADO: Incremental 1 Diferencial + Carga Alta
## ==========================================
# respaldo a las 3:00 am
echo "==> Backup RMAN Incremental Nivel 1 Diferencial"
rman @rman-ciclo-respaldos/s-07-sabado.rman

echo "==> Simulando carga: Sábado"
sqlplus -s $USER_INFRA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_gym(p_num_aparatos => 8, p_porcentaje_cambios => 15);
EOF

sqlplus -s $USER_OPERA << EOF
SET SERVEROUTPUT ON SIZE UNLIMITED
EXEC simula_carga_sesiones(p_num_sesiones => 15, p_duracion_min => 30, p_duracion_max => 120);
EOF

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
## ==========================================
