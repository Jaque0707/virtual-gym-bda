--@Autor: Benítez Pérez Michelle Paulina
--        Hernández García Pilar Jaqueline
--@Fecha creación: 08/12/2025
--@Descripción: modo compartido


connect sys/systemP as sysdba

prompt Modificando los parametros necesarios

alter system set dispatchers='(dispatchers=2)(protocol=tcp)' scope = spfile;
alter system set shared_servers=4  scope = spfile;

shutdown immediate
startup

prompt Ver parametros modificados

show parameter dispatchers
show parameter shared_servers

alter system register;

prompt Verificar en la terminal 

! lsnrctl services