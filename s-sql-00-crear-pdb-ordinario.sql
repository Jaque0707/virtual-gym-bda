-- ======================================================
-- Script: s-00-crear-pdb.sql
-- Autor: 
-- Fecha: 02/06/2025
-- Descripción: Creación de Tablespaces para MediaStream
-- ======================================================

create pluggable database pf_usuarios
admin user user_admin identified by user_admin
path_prefix = '/opt/oracle/oradata/FREE'
file_name_convert = ('/pdbseed/', '/pf_usuarios/');


prompt Abrir la PDB pf_usuarios
alter pluggable database pf_usuarios open;

Prompt Guardar el estado de la PDB pf_usuarios
alter pluggable database pf_usuarios save state;
