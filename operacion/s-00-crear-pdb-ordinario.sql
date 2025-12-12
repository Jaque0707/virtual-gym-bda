-- ======================================================
-- Script: s-00-crear-pdb.sql
-- Autor: 
-- Fecha: 02/06/2025
-- Descripción: Creación de la pd operacion 
-- ======================================================

conn sys/systemP as sysdba

create pluggable database pf_operacion
admin user operacion_admin identified by admin
path_prefix = '/opt/oracle/oradata/FREE'
file_name_convert = ('/pdbseed/', '/pf_operacion/');


prompt Abrir la PDB pf_operacion
alter pluggable database pf_operacion open;

Prompt Guardar el estado de la PDB pf_operacion
alter pluggable database pf_operacion save state;
