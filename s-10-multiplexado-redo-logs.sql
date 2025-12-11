--@Autor: Benítez Pérez Michelle Paulina
--        Hernández García Pilar Jaqueline
--@Fecha creación: 08/12/2025
--@Descripción: configuración de las rutas restantes de los redo logs

connect sys/systemP as sysdba
--miembros para el grupo 1
alter database add logfile member
'/unam/bda/pf/c0/d11/app/oracle/oradata/FREE/redo01a.log' to group 1;
alter database add logfile member
'/unam/bda/pf/c0/d12/app/oracle/oradata/FREE/redo01b.log' to group 1;

--miembros para el grupo 2
alter database add logfile member
'/unam/bda/pf/c0/d11/app/oracle/oradata/FREE/redo02a.log' to group 2;
alter database add logfile member
'/unam/bda/pf/c0/d12/app/oracle/oradata/FREE/redo02b.log' to group 2;

--miembros para el grupo 3
alter database add logfile member
'/unam/bda/pf/c0/d11/app/oracle/oradata/FREE/redo03a.log' to group 3;
alter database add logfile member
'/unam/bda/pf/c0/d12/app/oracle/oradata/FREE/redo03b.log' to group 3;
