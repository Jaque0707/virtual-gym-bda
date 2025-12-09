--@Autor: Benítez Pérez Michelle Paulina
--        Hernández García Pilar Jaqueline
--@Fecha creación: 09/12/2025
--@Descripción: 


connect sys/systemP as sysdba

shutdown immediate
startup mount 

alter database archivelog;

alter database open;

prompt Revisar la configuración

archive log list