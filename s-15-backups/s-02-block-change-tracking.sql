--@Autor: Benítez Pérez Michelle Paulina
--        Hernández García Pilar Jaqueline
--@Fecha creación: 10/12/2025
--@Descripción: 

-- habilitar la funcionalidad de block change tracking para backups incrementales

connect sys/systemP as sysdba
alter database enable block change tracking using file '/unam/bda/pf/c0/d10/block-tracking/change_tracking.dbf';