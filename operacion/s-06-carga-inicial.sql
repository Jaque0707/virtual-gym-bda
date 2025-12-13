
--@Descripción: Archivo principal
--si ocurre un error, se hace rollback de los datos y
--se sale de SQL *Plus

whenever sqlerror exit rollback
connect sys/systemP@pf_operacion as sysdba

CREATE OR REPLACE DIRECTORY OPERA_DIR AS 'operacion/carga-inicial';

GRANT READ, WRITE ON DIRECTORY OPERA_DIR TO opera_admin; 

set define off

Prompt realizando la carga de datos

@carga-inicial/s-06-cliente.sql
@carga-inicial/s-06-sensor.sql
@carga-inicial/s-06-credencial.sql
@carga-inicial/s-06-registro-medidas.sql
@carga-inicial/s-06-puesto.sql
@carga-inicial/s-06-empleado-instructor.sql
@carga-inicial/s-06-empleado-admin.sql
@carga-inicial/s-06-instructor.sql
@carga-inicial/s-06-admin.sql
@carga-inicial/s-06-huella.sql
@carga-inicial/s-06-sesion.sql
--Agregar los demás scripts de esta carpetas

set define on
Prompt confirmando cambios
commit;

--Si se encuentra un error, no se sale de SQL *Plus
--no se hace commit ni rollback, es decir, se regresa al estado original.
whenever sqlerror continue none
Prompt Listo!