--@Autor: Benítez Pérez Michelle Paulina
--        Hernández García Pilar Jaqueline
--@Fecha creación: 09/12/2025
--@Descripción: pool de conexiones

connect sys/systemP as sysdba

exec dbms_connection_pool.start_pool();

exec dbms_connection_pool.alter_param ('','MAXSIZE','500');
exec dbms_connection_pool.alter_param ('','MINSIZE','50');

exec dbms_connection_pool.alter_param ('','INACTIVITY_TIMEOUT','900');
exec dbms_connection_pool.alter_param ('','MAX_THINK_TIME','900');