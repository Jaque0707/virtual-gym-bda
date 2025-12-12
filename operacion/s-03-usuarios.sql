-- Dueños del modulo: crea tablas, indices, secuencias vitas etc 
- ======================================================
-- Script: s-0x-usuarios.sql
-- Autor: 
-- Fecha: 08/Dec/2025
-- Descripción: Creación de usuarios
-- ======================================================
connect sys/systemP@pf_operacion as sysdba

-- Usuario de Administración Total del Sistema
create user sys_admin identified by operacion;
grant create session, create table, create sequence, create view, create procedure, create trigger to sys_admin;
grant sysdba to sys_admin;

-- Asignar cuotas sobre todos los tablespaces relevantes
alter user sys_admin quota unlimited on clientes_c1_data_ts; 
alter user sys_admin quota unlimited on clientes_c2_lob_ts; 
alter user sys_admin quota unlimited on empleado_c1_data_ts;
alter user sys_admin quota unlimited on empleado_c2_lob_ts; 
alter user sys_admin quota unlimited on operacion_c1_data_ts; 

-- Usuario de Operación del Sistema (ej. startup/shutdown)
create user sys_operator identified by operacion;
grant create session, create table, create sequence, create view to sys_operator;
grant sysoper to sys_operator;

-- Asignar cuotas (si fuera necesario para tareas de bajo nivel, aunque SYSOPER rara vez requiere cuotas)
alter user sys_operator quota unlimited on clientes_c1_data_ts;
alter user sys_operator quota unlimited on operacion_c1_data_ts;

-- Usuario de Backup y Recuperación
create user sys_backup identified by operacion;
grant create session, create table, create sequence, create view to sys_backup;
grant sysbackup to sys_backup;

-- Usuario de Data Guard
create user sys_dg identified by operacion;
grant create session, create table, create sequence, create view to sys_dg;
grant sysdg to sys_dg;

-- Usuario de Key Management (ej. TDE)
create user sys_km identified by operacion;
grant create session, create table, create sequence, create view to sys_km;
grant syskm to sys_km;

-----------------------------
-- ADMINSITRACION DE CLIENTES 
-----------------------------
create user admin_cliente identified by admin_cliente default tablespace clientes_c1_data_ts;

grant create session, create table, create sequence, create view, create procedure, create trigger, create type to admin_cliente;

alter user admin_cliente quota unlimited on clientes_c1_data_ts;
alter user admin_cliente quota unlimited on clientes_c2_lob_ts;

------------------------------
-- ADMINSITRACION DE EMPLEADOS 
------------------------------
create user admin_empleado identified by admin_empleado default tablespace empleado_c1_data_ts;

grant create session, create table, create sequence, create view, create procedure, create trigger, create type to admin_empleado;

alter user admin_empleado quota unlimited on empleado_c1_data_ts;
alter user admin_empleado quota unlimited on empleado_c2_lob_ts;

------------------------------
-- ADMINSITRACION DE OPERACION 
------------------------------
create user admin_operacion identified by admin_operacion_pass default tablespace operacion_c1_data_ts;

grant create session, create table, create sequence, create view, create procedure, create trigger, create type to admin_operacion;

alter user admin_operacion quota unlimited on operacion_c1_data_ts;