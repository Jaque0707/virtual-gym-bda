--@Autor: Benítez Pérez Michelle Paulina
--        Hernández García Pilar Jaqueline
--@Fecha creación: 08/12/2025
--@Descripción: configuración de las rutas restantes de los control files


-- verificar con show parameter control_files

connect sys/systemP as sysdba

startup nomount

prompt Verificar que '/unam/bda/disks/d14/fra/FREE/controlfile/o1_mf_nmfmw641_.ctl' sea igual a la salida de

show parameter control_files

prompt Modificando parámetro control_files

alter system set
control_files='/unam/bda/disks/d14/fra/FREE/controlfile/o1_mf_nmfmw641_.ctl',
'/unam/bda/pf/c0/d11/app/oracle/oradata/FREE/control01.ctl',
'/unam/bda/pf/c0/d12/app/oracle/oradata/FREE/control02.ctl' 
scope =spfile;

shutdown abort

startup nomount
alter database mount
alter database open

prompt Revisar 3 rutas en parámetro control_files

select * from v$controlfile;
