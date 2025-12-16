--@Autor: Benítez Pérez Michelle Paulina
--        Hernández García Pilar Jaqueline
--@Fecha creación: 09/12/2025
--@Descripción: 

-- ==========================================================
-- A. Datos generales de la instancia (v$instance)
-- ==========================================================
SELECT instance_name, host_name, version, status, archiver, database_status 
  FROM v$instance;

-- ==========================================================
-- B. Datos generales de la CDB (v$database)
-- ==========================================================
SELECT name, log_mode, open_mode, database_role, created, cdb 
  FROM v$database;

-- ==========================================================
-- C. Datos de las PDBs (v$pdbs)
-- Calculando el tamaño total en GB
-- ==========================================================
SELECT con_id, name, open_mode, 
  trunc(total_size/1024/1024/1024, 2) as total_size_gb 
  FROM v$pdbs;

-- ==========================================================
-- D. Tablespaces en toda la CDB (cdb_tablespaces)
-- ==========================================================
SELECT tablespace_name, status, contents, extent_management,
  segment_space_management, retention, bigfile, encrypted, con_id
  FROM cdb_tablespaces 
  ORDER BY con_id, tablespace_name;

-- ==========================================================
-- E. Datafiles en toda la CDB (cdb_data_files)
-- ==========================================================
SELECT con_id, tablespace_name, file_id, 
  ROUND(bytes/1024/1024, 2) as size_mb, autoextensible, online_status 
  FROM cdb_data_files 
  ORDER BY con_id, tablespace_name;

-- ==========================================================
-- F. Características de grupos de Redo Logs (v$log)
-- ==========================================================
SELECT group#, sequence#, members, archived, status, con_id
  FROM v$log;

-- ==========================================================
-- G. Miembros de los grupos de Redo Logs (v$logfile)
-- ==========================================================
SELECT group#, status, type, member, is_recovery_dest_file, con_id 
  FROM v$logfile 
  ORDER BY group#;

-- ==========================================================
-- H. Copias de archivos de control (v$controlfile)
-- ==========================================================
SELECT con_id,status,name, is_recovery_dest_file 
  FROM v$controlfile;

-- ==========================================================
-- I. Archived Redo Logs generados (v$archived_log)
-- ==========================================================
SELECT recid, name, dest_id, sequence#, name, completion_time, 
  is_recovery_dest_file, backup_count, con_id 
  FROM v$archived_log 
  ORDER BY sequence#;

-- ==========================================================
-- J. Detalle de uso de la FRA (v$recovery_area_usage)
-- ==========================================================
SELECT file_type, percent_space_used, percent_space_reclaimable, 
  number_of_files, con_id 
  FROM v$recovery_area_usage;

-- ==========================================================
-- K. Detalle de Backup Pieces (v$backup_piece)
-- ==========================================================
SELECT bp.RECID,
  DECODE(bs.BACKUP_TYPE,'D', 'D-FULL BACKUP','I', 'I-INCREMENTAL','L', 'L-WITH ARC LOGS',
    bs.BACKUP_TYPE) AS BACKUP_TYPE,
  bp.TAG, bs.CONTROLFILE_INCLUDED, bs.PIECES AS TOTAL_PIECES, bp.PIECE#,
  bp.COPY#, bp.DEVICE_TYPE, bp.COMPLETION_TIME, ROUND(bp.BYTES/1024/1024, 2) AS MBS,
  bp.HANDLE
FROM 
  V$BACKUP_PIECE bp JOIN V$BACKUP_SET bs 
    ON bp.SET_STAMP = bs.SET_STAMP 
    AND bp.SET_COUNT = bs.SET_COUNT
ORDER BY bp.RECID;

-- ==========================================================
-- L. Resumen de Backups por tipo (v$backup_set)
-- ==========================================================
SELECT DECODE(bs.BACKUP_TYPE,
    'D', 'D-FULL BACKUP','I', 'I-INCREMENTAL','L', 'L-WITH ARC LOGS',
  bs.BACKUP_TYPE) AS BACKUP_TYPE,bs.INCREMENTAL_LEVEL,COUNT(*) AS NUM_BACKUPS,
  TRUNC(SUM(bp.BYTES)/1024/1024/1024, 2) AS TOTAL_GB
FROM 
  V$BACKUP_PIECE bp JOIN V$BACKUP_SET bs 
    ON bp.SET_STAMP = bs.SET_STAMP 
    AND bp.SET_COUNT = bs.SET_COUNT
GROUP BY bs.BACKUP_TYPE, bs.INCREMENTAL_LEVEL
ORDER BY bs.BACKUP_TYPE,bs.INCREMENTAL_LEVEL NULLS FIRST;

-- ==========================================================
-- M. Backups tipo Image Copy (v$datafile_copy)
-- ==========================================================
SELECT tag, count(*) as num_archivos, 
  ROUND(SUM(blocks*block_size)/1024/1024, 2) as total_size_mb
  FROM v$datafile_copy 
  GROUP BY tag;

-- ==========================================================
-- N. Usuarios creados para el proyecto (cdb_users)
-- ==========================================================
SELECT username, account_status, default_tablespace, temporary_tablespace, 
  local_temp_tablespace, created, last_login, con_id 
  FROM cdb_users 
  where username like '%INFRA%' or username like '%OPERA%'
  ORDER BY con_id;

-- REVISAR ULTIMAS CONSULTAS

-- ==========================================================
-- O. Cuotas de almacenamiento (cdb_ts_quotas y cdb_users)
-- ==========================================================
SELECT q.con_id, q.username, q.tablespace_name, 
       ROUND(q.bytes/1024/1024, 2) as charged_mb, 
       CASE WHEN q.max_bytes = -1 THEN 'UNLIMITED' 
            ELSE TO_CHAR(ROUND(q.max_bytes/1024/1024, 2)) 
       END as max_mb
FROM cdb_ts_quotas q
WHERE q.username LIKE '%INFRA%' OR q.username LIKE '%OPERA%' -- <Ajusta este filtro
ORDER BY q.con_id, q.username;

-- ==========================================================
-- P. Segmentos del proyecto por tablespace (cdb_segments)
-- ==========================================================
SELECT con_id, owner, count(*) as total_segments, sum(extents) as total_extents, 
       ROUND(sum(bytes)/1024/1024, 2) as total_mb 
FROM cdb_segments 
WHERE owner LIKE '%INFRA%' OR owner LIKE '%OPERA%' -- <Ajusta este filtro
GROUP BY con_id, owner;

-- ==========================================================
-- Q. Total de espacio reservado para el proyecto
-- ==========================================================
SELECT trunc(SUM(bytes)/1024/1024, 2) as total_mb 
  FROM cdb_segments 
  WHERE owner LIKE '%INFRA%' OR owner LIKE '%OPERA%'; 