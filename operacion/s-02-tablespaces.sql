
--@Autor(es):   Benítez Pérez Michelle Paulina
--              Pilar Jaqueline Hernández García
--@Fecha creación: 8/12/2025
--@Descripción: el script crea los TS para el modulo operacion

connect sys/systemP@pf_operacion as sysdba

drop tablespace if exists cliente_c1_data_ts including contents and datafiles;
drop tablespace if exists cliente_c2_lob_ts including contents and datafiles;
drop tablespace if exists empleado_c1_data_ts including contents and datafiles;
drop tablespace if exists empleado_c2_lob_ts including contents and datafiles;
drop tablespace if exists operacion_c1_data_ts including contents and datafiles;

--TS CLIENTES 

create bigfile tablespace cliente_c1_data_ts datafile
    '/unam/bda/pf/c1/d01/clientes_c1_data_ts_01.dbf' size 100m
    autoextend on next 10m maxsize unlimited
    extent management local autoallocate
    segment space management auto;


create bigfile tablespace cliente_c2_lob_ts datafile
    '/unam/bda/pf/c2/d01/clientes_c2_lob_ts_01.dbf' size 200m
    autoextend on next 50m maxsize unlimited
    extent management local autoallocate
    segment space management auto;

--TS EMPLEADOS 

create bigfile tablespace empleado_c1_data_ts datafile
    '/unam/bda/pf/c1/d02/empleado_c1_data_ts_01.dbf' size 50m
    autoextend on next 5m maxsize unlimited
    extent management local autoallocate
    segment space management auto;


create bigfile tablespace empleado_c2_lob_ts datafile
    '/unam/bda/pf/c2/d02/empleado_c2_lob_ts_01.dbf' size 500m
    autoextend on next 20m maxsize unlimited
    extent management local autoallocate
    segment space management auto;

--TS OPERACION 
create bigfile tablespace operacion_c1_data_ts datafile
    '/unam/bda/pf/c1/d02/operacion_c1_data_ts_01.dbf' size 200m
    autoextend on next 20m maxsize unlimited
    extent management local autoallocate
    segment space management auto;