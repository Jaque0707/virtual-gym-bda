--@Autor: Benítez Pérez Michelle Paulina
--        Hernández García Pilar Jaqueline
--@Fecha creación: 08/12/2025
--@Descripción: creación de la cdb del proyecto

-- autenticar como usuario sys
connect sys/Med1aStream* as sysdba

-- para buscar un spfile en ORACLE_HOME/bds y encontrar los parametros
startup nomount 

whenever sqlerror exit rollback

create database free
  user sys identified by systemP
  user system identified by systemP
  logfile group 1 size 50m blocksize 512,
  group 2 size 50m blocksize 512,
  group 3 size 50m blocksize 512
  maxloghistory 1
  maxlogfiles 16
  maxlogmembers 3
  maxdatafiles 1024
  character set AL32UTF8
  national character set AL16UTF16
  extent management local
    datafile '/opt/oracle/oradata/FREE/system01.dbf'
      size 500m autoextend on next 10m maxsize unlimited
  sysaux datafile '/opt/oracle/oradata/FREE/sysaux01.dbf'
    size 300m autoextend on next 10m maxsize unlimited
  default tablespace users 
    datafile '/opt/oracle/oradata/FREE/users01.dbf'
    size 50m autoextend on next 10m maxsize unlimited
  default temporary tablespace tempts1
    tempfile '/opt/oracle/oradata/FREE/temp01.dbf'
    size 20m autoextend on next 1m maxsize unlimited
  undo tablespace undotbs1
    datafile '/opt/oracle/oradata/FREE/undotbs01.dbf'
    size 100m autoextend on next 5m maxsize unlimited
  enable pluggable database
    seed
      file_name_convert = ('/opt/oracle/oradata/FREE','/opt/oracle/oradata/FREE/pdbseed')
  
    system datafiles size 250m autoextend on next 10m maxsize unlimited
    sysaux datafiles size 200m autoextend on next 10m maxsize unlimited
  local undo on
;

-- homologando valores de passwords 
alter user sys identified by systemP;
alter user system identified by systemP;