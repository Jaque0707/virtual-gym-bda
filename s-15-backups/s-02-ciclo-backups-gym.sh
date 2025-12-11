#!/bin/bash
# ======================================================
# Autor: Benítez Pérez Michelle Paulina
#        Hernández García Pilar Jaqueline
# Fecha: 10/12/2025
# ======================================================
# Script para simular el ciclo de backups semanal del Caso Virtual Gym

# Usuario común para generar carga
USER_BD_M1="pf_operacion_admin/pf_operacion_admin@pf_operacion" 
USER_BD_M2="infra_admin/infra_admin@pf_infraestr" 
# Usuario SYS para RMAN
SYS_RMAN="target /" 

echo "=========================================="
echo " INICIANDO CICLO DE RESPALDOS SEMANAL"
echo "=========================================="

# ==========================================
# DOMINGO: Full Backup Incremental Nivel 0 + Carga Baja (200)
# ==========================================
echo "--> DOMINGO: Generando Backup Incremental Nivel 0 (Base)"
rman $SYS_RMAN << EOF
RUN {
    # Nivel 0 sirve de base para los incrementales posteriores
    # Se incluyen los archive logs para asegurar consistencia
    BACKUP AS BACKUPSET INCREMENTAL LEVEL 0 DATABASE 
    PLUS ARCHIVELOG TAG 'DOMINGO_LVL0';
    
    # Limpieza de obsoletos según política de retención: 7 días
    DELETE NOPROMPT OBSOLETE;
}
EOF

#echo "--> DOMINGO: Simulando Carga Baja (200 registros)" # CAMBIAR
#sqlplus -s $USER_BD << EOF
#    -- Se invoca el procedimiento de carga 
#    EXEC simula_carga_auto(200); 
#    COMMIT;
#EOF

# ==========================================
# LUNES: Incremental Nivel 1 Diferencial + Carga Alta (600)
# ==========================================
echo "--> LUNES: Generando Backup Incremental Nivel 1 Diferencial"
rman $SYS_RMAN << EOF
RUN {
    # Por defecto, el nivel 1 es diferencial (cambios desde el último nivel 1 o 0)
    BACKUP AS BACKUPSET INCREMENTAL LEVEL 1 DATABASE 
    PLUS ARCHIVELOG TAG 'LUNES_DIFF';
}
EOF

#echo "--> LUNES: Simulando Carga Alta (600 registros)" # CAMBIAR
#sqlplus -s $USER_BD << EOF
#    EXEC simula_carga_auto(600);
#    COMMIT;
#EOF

# ==========================================
# MARTES: Incremental 1 Cumulativo + Carga Moderada (400) + Punto de Consulta
# ==========================================
echo "--> MARTES: Generando Backup Incremental Nivel 1 CUMULATIVO"
rman $SYS_RMAN << EOF
RUN {
    # Cumulativo: Respalda todo desde el último Nivel 0 (Domingo)
    # Absorbe la carga alta del lunes para agilizar una recuperación futura.
    BACKUP AS BACKUPSET INCREMENTAL LEVEL 1 CUMULATIVE DATABASE 
    PLUS ARCHIVELOG TAG 'MARTES_CUMUL';
}
EOF

echo "--> MARTES: Punto de Consulta / Verificación" 
rman $SYS_RMAN << EOF
    # Visualizar qué backups se requerirían para restaurar la BD hoy
    RESTORE DATABASE PREVIEW;
    LIST BACKUP SUMMARY;
EOF

#echo "--> MARTES: Simulando Carga Moderada (400 registros)" # CAMBIAR
#sqlplus -s $USER_BD << EOF
#    EXEC simula_carga_auto(400);
#    COMMIT;
#EOF

# ==========================================
# MIÉRCOLES: Incremental 1 Diferencial + Carga Moderada (400)
# ==========================================
echo "--> MIERCOLES: Generando Backup Incremental Nivel 1 Diferencial"
rman $SYS_RMAN << EOF
RUN {
    # Respalda solo cambios desde el acumulativo del Martes
    BACKUP AS BACKUPSET INCREMENTAL LEVEL 1 DATABASE 
    PLUS ARCHIVELOG TAG 'MIERCOLES_DIFF';
}
EOF

#echo "--> MIERCOLES: Simulando Carga Moderada (400 registros)" # CAMBIAR
#sqlplus -s $USER_BD << EOF
#    EXEC simula_carga_auto(400);
#    COMMIT;
#EOF

# ==========================================
# JUEVES: Incremental 1 Diferencial + Carga Moderada (400)
# ==========================================
echo "--> JUEVES: Generando Backup Incremental Nivel 1 Diferencial"
rman $SYS_RMAN << EOF
RUN {
    BACKUP AS BACKUPSET INCREMENTAL LEVEL 1 DATABASE 
    PLUS ARCHIVELOG TAG 'JUEVES_DIFF';
}
EOF

##echo "--> JUEVES: Simulando Carga Moderada (400 registros)" # CAMBIAR
##sqlplus -s $USER_BD << EOF
##    EXEC simula_carga_auto(400);
##    COMMIT;
##EOF

# ==========================================
# VIERNES: Incremental 1 Diferencial + Carga Moderada (400) + Punto de Consulta
# ==========================================
echo "--> VIERNES: Generando Backup Incremental Nivel 1 Diferencial"
rman $SYS_RMAN << EOF
RUN {
    BACKUP AS BACKUPSET INCREMENTAL LEVEL 1 DATABASE 
    PLUS ARCHIVELOG TAG 'VIERNES_DIFF';
}
EOF

#echo "--> VIERNES: Punto de Consulta / Verificación "
#rman $SYS_RMAN << EOF
#    # Verificación del estado de recuperación antes del fin de semana
#    RESTORE DATABASE PREVIEW;
#    # Reporte de obsolescencia
#    REPORT OBSOLETE;
#EOF

#echo "--> VIERNES: Simulando Carga Moderada (400 registros)" # CAMBIAR
#sqlplus -s $USER_BD << EOF
#    EXEC simula_carga_auto(400);
#    COMMIT;
#EOF

# ==========================================
# SÁBADO: Incremental 1 Diferencial + Carga Baja (300) # CAMBIAR
# ==========================================
echo "--> SABADO: Generando Backup Incremental Nivel 1 Diferencial"
rman $SYS_RMAN << EOF
RUN {
    BACKUP AS BACKUPSET INCREMENTAL LEVEL 1 DATABASE 
    PLUS ARCHIVELOG TAG 'SABADO_DIFF';
    
    # Limpieza final de la semana
    DELETE NOPROMPT OBSOLETE;
}
EOF

#echo "--> SABADO: Simulando Carga Baja (300 registros)" # CAMBIAR 
#sqlplus -s $USER_BD << EOF
#    EXEC simula_carga_auto(300);
#    COMMIT;
#EOF

echo "=========================================="
echo " CICLO SEMANAL COMPLETADO"
echo "=========================================="



# ==========================================
# DOMINGO
#   * full backup
#   * incremental nivel 0 

# carga baja: 200 registros
# ==========================================
# LUNES
#   * incremental 1 diferencial 

# carga alta: 600 registros
# ==========================================
# MARTES
#   * incremental 1 cumulativo (por la carga alta del lunes)
#   * punto de consulta ********************<<

# carga moderada: 400 registros 
# ==========================================
# MIÉRCOLES
#   * incremental 1 diferencial 

# carga moderada: 400 registros
# ==========================================
# JUEVES
#   * incremental 1 diferencial

# carga moderada: 400 registros
# ==========================================
# VIERNES
#   * incremental 1 diferencial
#   * punto de consulta ********************<<

# carga moderada: 400 registros
# ==========================================
# SÁBADO   
#   * incremental 1 diferencial

# carga baja: 300 registros
# ==========================================