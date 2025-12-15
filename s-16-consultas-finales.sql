--@Autor: Benítez Pérez Michelle Paulina
--        Hernández García Pilar Jaqueline
--@Fecha creación: 09/12/2025
--@Descripción: 

-- ==========================================================
-- A. Datos generales de la instancia (v$instance)
-- ==========================================================
select instance_name, host_name, version, status, archiver, database_status 
  from v$instance;

-- ==========================================================
-- B. Datos generales de la CDB (v$database)
-- ==========================================================
select name, log_mode, open_mode, database_role, created, cdb 
  from v$database;

-- ==========================================================
-- C. Datos de las PDBs (v$pdbs)
-- Calculando el tamaño total en GB
-- ==========================================================
select con_id, name, open_mode, 
  trunc(total_size/1024/1024/1024, 2) as total_size_gb 
  from v$pdbs;

-- ==========================================================
-- D. Tablespaces en toda la CDB (cdb_tablespaces)
-- ==========================================================
select tablespace_name, status, contents, extent_management,
  segment_space_management, retention, bigfile, encrypted, con_id
  from cdb_tablespaces 
  order by con_id, tablespace_name;

-- ==========================================================
-- E. Datafiles en toda la CDB (cdb_data_files)
-- ==========================================================
select con_id, tablespace_name, file_id, 
  trunc(bytes/1024/1024, 2) as size_mb, autoextensible, online_status 
  from cdb_data_files 
  order by con_id, tablespace_name;

-- ==========================================================
-- F. Características de grupos de Redo Logs (v$log)
-- ==========================================================
select group#, sequence#, members, archived, status, con_id
  from v$log;

-- ==========================================================
-- G. Miembros de los grupos de Redo Logs (v$logfile)
-- ==========================================================
select group#, status, type, member, is_recovery_dest_file, con_id 
  from v$logfile 
  order by group#;

-- ==========================================================
-- H. Copias de archivos de control (v$controlfile)
-- ==========================================================
select con_id,status,name, is_recovery_dest_file 
  from v$controlfile;

-- ==========================================================
-- I. Archived Redo Logs generados (v$archived_log)
-- ==========================================================
select recid, name, dest_id, sequence#, name, completion_time, 
  is_recovery_dest_file, backup_count, con_id 
  from v$archived_log 
  order by sequence#;

-- ==========================================================
-- J. Detalle de uso de la FRA (v$recovery_area_usage)
-- ==========================================================
select file_type, percent_space_used, percent_space_reclaimable, 
  number_of_files, con_id 
  from v$recovery_area_usage;

-- ==========================================================
-- K. Detalle de Backup Pieces (v$backup_piece)
-- ==========================================================
select bp.recid,
  decode(bs.backup_type,'D', 'D-FULL BACKUP','I', 'I-INCREMENTAL','L', 'L-WITH ARC LOGS',
    bs.backup_type) as backup_type,
  bp.tag, bs.controlfile_included, bs.pieces as total_pieces, bp.piece#,
  bp.copy#, bp.device_type, bp.completion_time,trunc(bp.bytes/1024/1024, 2) as mbs,
  bp.handle
  from v$backup_piece bp
  join v$backup_set bs
    on bp.set_stamp = bs.set_stamp
    and bp.set_count = bs.set_count
  order by bp.recid;

-- ==========================================================
-- L. Resumen de Backups por tipo (v$backup_set)
-- ==========================================================
select decode(bs.backup_type,
    'D', 'D-FULL BACKUP','I', 'I-INCREMENTAL','L', 'L-WITH ARC LOGS',
  bs.backup_type) as backup_type,bs.incremental_level,count(*) as num_backups,
  trunc(sum(bp.bytes)/1024/1024/1024, 2) as total_gb
  from v$backup_piece bp
  join v$backup_set bs
    on bp.set_stamp = bs.set_stamp
    and bp.set_count = bs.set_count
  group by bs.backup_type, bs.incremental_level
  order by bs.backup_type, bs.incremental_level nulls first;

-- ==========================================================
-- M. Backups tipo Image Copy (v$datafile_copy)
-- ==========================================================
select tag, count(*) as num_archivos, 
  trunc(sum(blocks*block_size)/1024/1024, 2) as total_size_mb
  from v$datafile_copy 
  group by tag;

-- ==========================================================
-- N. Usuarios creados para el proyecto (cdb_users)
-- ==========================================================
select username, account_status, default_tablespace, temporary_tablespace,
  local_temp_tablespace, created, last_login, con_id
  from cdb_users
  where username like '%INFRA%'
    or username like '%OPERA%'
    or username in ('ADMIN_CLIENTE', 'ADMIN_EMPLEADO', 'ADMIN_OPERACION')
  order by con_id, username;

-- ==========================================================
-- O. Cuotas de almacenamiento (cdb_ts_quotas y cdb_users)
-- ==========================================================
select u.con_id, u.username, q.tablespace_name,
  trunc(sum(q.bytes)/1024/1024, 2) as charged_mb,
  case
    when max(q.max_bytes) = -1 then 'UNLIMITED'
    else to_char(round(max(q.max_bytes)/1024/1024, 2))
  end as max_mb
  from cdb_users u
  join cdb_ts_quotas q
    on u.username = q.username
    and u.con_id   = q.con_id
  where u.username like '%INFRA%'
    or u.username like '%OPERA%'
    or u.username in ('ADMIN_CLIENTE','ADMIN_EMPLEADO','ADMIN_OPERACION')
  group by u.con_id, u.username, q.tablespace_name
  order by u.con_id, u.username, q.tablespace_name;

-- ==========================================================
-- P. Segmentos del proyecto por tablespace (cdb_segments)
-- ==========================================================
select tablespace_name, owner,
  count(*) as total_segments,
  sum(extents) as total_extents,
  round(sum(bytes)/1024/1024, 2) as total_mb
from cdb_segments
where owner like '%INFRA%'
   or owner like '%OPERA%'
   or owner in ('ADMIN_CLIENTE', 'ADMIN_EMPLEADO', 'ADMIN_OPERACION')
group by tablespace_name, owner
order by tablespace_name, owner;

-- ==========================================================
-- Q. Total de espacio reservado para el proyecto
-- ==========================================================
select round(sum(bytes)/1024/1024, 2) as total_mb
  from cdb_segments
 where owner like '%INFRA%'
    or owner like '%OPERA%'
    or owner in ('ADMIN_CLIENTE', 'ADMIN_EMPLEADO', 'ADMIN_OPERACION');