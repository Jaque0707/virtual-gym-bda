--@Autor: Benítez Pérez Michelle Paulina
--        Hernández García Pilar Jaqueline
--@Fecha creación: 08/12/2025
--@Descripción: 

create pluggable database pf_infraestr
admin user infra_admin identified by infra_admin
path_prefix = '/opt/oracle/oradata/FREE'
file_name_convert = ('/pdbseed/', '/pf_infraestr/');

prompt abrir la PDB
alter pluggable database pf_infraestr open;
prompt guardar el estado de la PDB
alter pluggable database pf_infraestr save state;
