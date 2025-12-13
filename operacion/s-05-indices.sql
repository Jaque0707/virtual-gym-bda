connect opera_admin/opera_admin@pf_operacion as sysdba


DROP INDEX IF EXISTS empleado_puesto_id_ix;
DROP INDEX IF EXISTS sensor_cliente_id_ix;
DROP INDEX IF EXISTS sesion_instructor_id_ix;
DROP INDEX IF EXISTS bitacora_sesion_id_ix;
DROP INDEX IF EXISTS credencial_cliente_id_ix;
DROP INDEX IF EXISTS instructor_suplente_id_ix;
DROP INDEX IF EXISTS sesion_aparato_sesion_id_ix;
DROP INDEX IF EXISTS registro_medidas_cliente_id_ix;
DROP INDEX IF EXISTS cliente_nombre_completo_ix;
DROP INDEX IF EXISTS empleado_nombre_completo_ix;
DROP INDEX IF EXISTS sesion_cliente_id_folio_ix;
DROP INDEX IF EXISTS huella_dactilar_empleado_dedo_ix;

-- **************Llaves foraneas********************

--EMPLEADO 
create index empleado_puesto_id_ix
on empleado(puesto_id)
TABLESPACE empleado_c1_data_ts;

--SENSOR
--create index sensor_cliente_id_ix 
--on sensor(cliente_id)
--TABLESPACE cliente_c1_data_ts;

--SESION 
create index sesion_instructor_id_ix
on sesion(empleado_instructor_id)
TABLESPACE operacion_c1_data_ts;

--BITACORA
create index bitacora_sesion_id_ix 
on bitacora(sesion_id)
TABLESPACE operacion_c1_data_ts;

--CREDENCIAL 
create index credencial_cliente_id_ix
on credencial(cliente_id)
TABLESPACE cliente_c1_data_ts;

--HUELLA_DACTILAR
--N/A

--INSTRUCTOR 
create index instructor_suplente_id_ix 
on instructor(suplente_id)
TABLESPACE empleado_c1_data_ts;

--ADMINISTRATIVo 
--N/A

--SESION_APARATO 
create index sesion_aparato_sesion_id_ix
on sesion_aparato(sesion_id)
TABLESPACE operacion_c1_data_ts;

--RESGISTRO_MEDIDAS 
create index registro_medidas_cliente_id_ix
on registro_medidas(cliente_id)
TABLESPACE cliente_c1_data_ts;

--*********Columnas con busquedas frecuentes******* 
--CLIENTE
create index cliente_nombre_completo_ix
on cliente(apellido_paterno, apellido_materno, nombre)
TABLESPACE cliente_c1_data_ts;

--PUESTO
-- N/A 

-- EMPLEADO 
create index empleado_nombre_completo_ix
on empleado(apellido_paterno, apellido_materno, nombre)
TABLESPACE empleado_c1_data_ts;

--SESION 
create index sesion_cliente_id_folio_ix
on sesion(cliente_id, folio)
TABLESPACE operacion_c1_data_ts;

--HUELLA DACTILAR 
create index huella_dactilar_empleado_dedo_ix 
on huella_dactilar(empleado_id, num_dedo)
TABLESPACE empleado_c1_data_ts;