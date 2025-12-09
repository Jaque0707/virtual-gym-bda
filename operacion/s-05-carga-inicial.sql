--@Autor: Jorge Rodriguez
--@Fecha creación: dd/mm/yyyy
--@Descripción: Archivo principal
--si ocurre un error, se hace rollback de los datos y
--se sale de SQL *Plus

whenever sqlerror exit rollback
connect admin_cliente/admin_cliente@pf_operacion
set define off

Prompt realizando la carga de datos
@carga-inicial/s-05-cliente.sql

--Agregar los demás scripts de esta carpetas

set define on
Prompt confirmando cambios
commit;

--Si se encuentra un error, no se sale de SQL *Plus
--no se hace commit ni rollback, es decir, se regresa al estado original.
whenever sqlerror continue none
Prompt Listo!