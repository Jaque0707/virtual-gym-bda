-- Dueños del modulo: crea tablas, indices, secuencias vitas etc 
- ======================================================
-- Script: s-0x-usuarios.sql
-- Autor: 
-- Fecha: 08/Dec/2025
-- Descripción: Creación de usuarios
-- ======================================================

-- Adminsitradores

CREATE USER sys_admin IDENTIFIED BY system3;
GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE VIEW, CREATE PROCEDURE, CREATE TRIGGER TO sys_admin;
GRANT SYSDBA TO sys_admin;

-- Asignar cuotas sobre todos los tablespaces relevantes
ALTER USER sys_admin QUOTA UNLIMITED ON cliente_c1_data_ts; 
ALTER USER sys_admin QUOTA UNLIMITED ON operacion_c1_data_ts; 
ALTER USER sys_admin QUOTA UNLIMITED ON sensibles_c2_lob_ts; 
ALTER USER sys_admin QUOTA UNLIMITED ON operacion_c2_lob_ts;  

CREATE USER sys_operator IDENTIFIED BY system3;
GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE VIEW TO sys_operator;
GRANT SYSOPER TO sys_operator;

-- Asignar cuotas sobre los tablespaces relevantes
ALTER USER sys_operator QUOTA UNLIMITED ON cliente_c1_data_ts;
ALTER USER sys_operator QUOTA UNLIMITED ON operacion_c1_data_ts_01;

CREATE USER sys_backup IDENTIFIED BY system2;
GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE VIEW TO sys_backup;
GRANT SYSBACKUP TO sys_backup;

ALTER USER sys_admin QUOTA UNLIMITED ON cliente_c1_data_ts; 
ALTER USER sys_admin QUOTA UNLIMITED ON operacion_c1_data_ts; 
ALTER USER sys_admin QUOTA UNLIMITED ON sensibles_c2_lob_ts; 
ALTER USER sys_admin QUOTA UNLIMITED ON operacion_c2_lob_ts;  


CREATE USER sys_dg IDENTIFIED BY  system3;
GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE VIEW TO sys_dg;
GRANT SYSDG TO sys_dg;

ALTER USER sys_dg QUOTA UNLIMITED ON sensibles_c2_lob_ts; 


CREATE USER sys_km IDENTIFIED BY system2;
GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE VIEW TO sys_km;
GRANT SYSKM TO sys_km;

ALTER USER sys_km QUOTA UNLIMITED ON sensibles_c2_lob_ts; 


------Usuarios de aplicacion
CREATE USER admin_cliente IDENTIFIED BY system3;
GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE VIEW, CREATE PROCEDURE, CREATE TRIGGER TO sys_admin;
GRANT SYSDBA TO sys_admin;

ALTER USER sys_admin QUOTA UNLIMITED ON cliente_c1_data_ts; 
ALTER USER sys_admin QUOTA UNLIMITED ON operacion_c2_lob_ts;  

CREATE USER admin_operacion
  IDENTIFIED BY admin_operacion
  DEFAULT TABLESPACE operacion_c1_data_ts
  QUOTA UNLIMITED ON operacion_c1_data_ts
  QUOTA UNLIMITED ON operacion_c2_lob_ts
  QUOTA UNLIMITED ON sensibles_c2_lob_ts;

GRANT CREATE SESSION TO admin_operacion;
GRANT CREATE TABLE TO admin_operacion;
GRANT CREATE SEQUENCE TO admin_operacion;
GRANT CREATE VIEW TO admin_operacion;
GRANT CREATE PROCEDURE TO admin_operacion;
GRANT CREATE TRIGGER TO admin_operacion;
GRANT CREATE TYPE TO admin_operacion;