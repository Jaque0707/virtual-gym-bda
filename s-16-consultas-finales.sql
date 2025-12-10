--@Autor: Benítez Pérez Michelle Paulina
--        Hernández García Pilar Jaqueline
--@Fecha creación: 09/12/2025
--@Descripción: 


-- Configuración de formato para mejor visualización
SET LINESIZE 200
SET PAGESIZE 100
COL con_id FORMAT 999
COL pdbs_name FORMAT A20
COL file_name FORMAT A50
COL tablespace_name FORMAT A30
COL member FORMAT A50
COL name FORMAT A50
COL username FORMAT A20
COL owner FORMAT A20

-- ==========================================================
-- A. Datos generales de la instancia (v$instance)
-- ==========================================================
PROMPT === A. Datos de la Instancia ===
SELECT instance_name, host_name, version, status, archiver, database_status 
FROM v$instance;

-- ==========================================================
-- B. Datos generales de la CDB (v$database)
-- ==========================================================
PROMPT === B. Datos de la CDB ===
SELECT name, log_mode, open_mode, database_role, created, cdb 
FROM v$database;

-- ==========================================================
-- C. Datos de las PDBs (v$pdbs)
-- Calculando el tamaño total en GB
-- ==========================================================
PROMPT === C. Datos de las PDBs ===
SELECT con_id, name as pdbs_name, open_mode, restricted, 
       ROUND(total_size/1024/1024/1024, 2) as total_size_gb 
FROM v$pdbs;

-- ==========================================================
-- D. Tablespaces en toda la CDB (cdb_tablespaces)
-- ==========================================================
PROMPT === D. Tablespaces de la CDB ===
SELECT con_id, tablespace_name, block_size, status, contents, logging, 
       extent_management, allocation_type 
FROM cdb_tablespaces 
ORDER BY con_id, tablespace_name;

-- ==========================================================
-- E. Datafiles en toda la CDB (cdb_data_files)
-- ==========================================================
PROMPT === E. Datafiles de la CDB ===
SELECT con_id, file_name, tablespace_name, 
       ROUND(bytes/1024/1024, 2) as size_mb, autoextensible, maxbytes 
FROM cdb_data_files 
ORDER BY con_id, tablespace_name;

-- ==========================================================
-- F. Características de grupos de Redo Logs (v$log)
-- ==========================================================
PROMPT === F. Grupos de Redo Logs ===
SELECT group#, thread#, sequence#, bytes/1024/1024 as size_mb, 
       members, archived, status 
FROM v$log;

-- ==========================================================
-- G. Miembros de los grupos de Redo Logs (v$logfile)
-- ==========================================================
PROMPT === G. Miembros de Redo Logs ===
SELECT group#, status, type, member, is_recovery_dest_file 
FROM v$logfile 
ORDER BY group#;

-- ==========================================================
-- H. Copias de archivos de control (v$controlfile)
-- ==========================================================
PROMPT === H. Archivos de Control ===
SELECT name, is_recovery_dest_file 
FROM v$controlfile;

-- ==========================================================
-- I. Archived Redo Logs generados (v$archived_log)
-- ==========================================================
PROMPT === I. Archived Redo Logs (Últimos 10) ===
SELECT sequence#, name, dest_id, archived, applied, status, completion_time 
FROM v$archived_log 
ORDER BY sequence# DESC 
FETCH FIRST 10 ROWS ONLY;

-- ==========================================================
-- J. Detalle de uso de la FRA (v$recovery_area_usage)
-- ==========================================================
PROMPT === J. Uso de la Fast Recovery Area (FRA) ===
SELECT file_type, percent_space_used, percent_space_reclaimable, number_of_files 
FROM v$recovery_area_usage;

-- ==========================================================
-- K. Detalle de Backup Pieces (v$backup_piece)
-- ==========================================================
PROMPT === K. Backup Pieces Generados ===
SELECT bp.recid, bp.tag, bp.handle, bp.media, bp.con_id, 
       ROUND(bp.bytes/1024/1024, 2) size_mb
FROM v$backup_piece bp
ORDER BY bp.start_time;

-- ==========================================================
-- L. Resumen de Backups por tipo (v$backup_set)
-- ==========================================================
PROMPT === L. Resumen de Backups por Tipo ===
SELECT backup_type, count(*) as total_backups, 
       ROUND(SUM(elapsed_seconds), 2) as total_seconds
FROM v$backup_set 
GROUP BY backup_type;

-- ==========================================================
-- M. Backups tipo Image Copy (v$datafile_copy)
-- ==========================================================
PROMPT === M. Backups Image Copy ===
SELECT tag, count(*) as num_archivos, 
       ROUND(SUM(blocks*block_size)/1024/1024, 2) as total_size_mb
FROM v$datafile_copy 
GROUP BY tag;

-- ==========================================================
-- N. Usuarios creados para el proyecto (cdb_users)
-- NOTA: Ajusta el WHERE para filtrar tus usuarios específicos
-- ==========================================================
PROMPT === N. Usuarios del Proyecto ===
SELECT con_id, username, created, common, default_tablespace, temporary_tablespace 
FROM cdb_users 
WHERE username LIKE '%AUTOS%' OR username LIKE '%JRC%' -- <Ajusta este filtro
ORDER BY con_id;

-- ==========================================================
-- O. Cuotas de almacenamiento (cdb_ts_quotas y cdb_users)
-- ==========================================================
PROMPT === O. Cuotas de Usuarios ===
SELECT q.con_id, q.username, q.tablespace_name, 
       ROUND(q.bytes/1024/1024, 2) as charged_mb, 
       CASE WHEN q.max_bytes = -1 THEN 'UNLIMITED' 
            ELSE TO_CHAR(ROUND(q.max_bytes/1024/1024, 2)) 
       END as max_mb
FROM cdb_ts_quotas q
WHERE q.username LIKE '%AUTOS%' OR q.username LIKE '%JRC%' -- <Ajusta este filtro
ORDER BY q.con_id, q.username;

-- ==========================================================
-- P. Segmentos del proyecto por tablespace (cdb_segments)
-- ==========================================================
PROMPT === P. Segmentos del Proyecto ===
SELECT con_id, owner, count(*) as total_segments, sum(extents) as total_extents, 
       ROUND(sum(bytes)/1024/1024, 2) as total_mb 
FROM cdb_segments 
WHERE owner LIKE '%AUTOS%' OR owner LIKE '%JRC%' -- <Ajusta este filtro
GROUP BY con_id, owner;

-- ==========================================================
-- Q. Total de espacio reservado para el proyecto
-- ==========================================================
PROMPT === Q. Total Espacio Reservado (MB) ===
SELECT ROUND(SUM(bytes)/1024/1024, 2) as total_project_mb 
FROM cdb_segments 
WHERE owner LIKE '%AUTOS%' OR owner LIKE '%JRC%'; -- <Ajusta este filtro