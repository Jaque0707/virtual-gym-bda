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
    datafile '/unam/bda/pf/c0/d05/FREE/system01.dbf'
      size 500m autoextend on next 10m maxsize unlimited
  sysaux datafile '/unam/bda/pf/c0/d05/FREE/sysaux01.dbf'
    size 300m autoextend on next 10m maxsize unlimited
  default tablespace users 
    datafile '/unam/bda/pf/c2/d05/FREE/users01.dbf'
    size 50m autoextend on next 10m maxsize unlimited
  default temporary tablespace tempts1
    tempfile '/unam/bda/pf/c0/d05/FREE/temp01.dbf'
    size 20m autoextend on next 1m maxsize unlimited
  undo tablespace undotbs1
    datafile '/unam/bda/pf/c2/d05/FREE/undotbs01.dbf'
    size 100m autoextend on next 5m maxsize unlimited
  enable pluggable database
    seed
      file_name_convert = (
        '/unam/bda/pf/c0/d05/FREE','/unam/bda/pf/c0/d05/FREE/pdbseed',
        '/unam/bda/pf/c2/d05/FREE', '/unam/bda/pf/c2/d05/FREE/pdbseed'
      )
    system datafiles size 250m autoextend on next 10m maxsize unlimited
    sysaux datafiles size 200m autoextend on next 10m maxsize unlimited
  local undo on
;

-- homologando valores de passwords 
alter user sys identified by systemP;
alter user system identified by systemP;