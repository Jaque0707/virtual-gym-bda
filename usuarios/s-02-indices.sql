-- **************Llaves foraneas********************

--EMPLEADO 
create index empleado_puesto_id_ix
on empleado(puesto_id);

--PUESTO
create index sensor_cliente_id_ix 
on sensor(cliente_id);

--SESION 
create index sesion_instructor_id_ix
on sesion(empleado_instructor_id);

--BITACORA
create index bitacora_sesion_id_ix 
on bitacora(sesion_id); 

--CREDENCIAL 
create index credencial_cliente_id_ix
on credencial(cliente_id);

--HUELLA_DACTILAR
--N/A

--INSTRUCTOR 
create index instructor_suplente_id_ix 
on instructor(suplente_id)

--ADMINISTRATIVo 
--N/A

--SESION_APARATO 
create index sesion_aparato_sesion_id_ix
on sesion_aparato(sesion_id); 

--RESGISTRO_MEDIDAS 
create index registro_medidas_cliente_id_ix
on registro_medidas(cliente_id); 

--*********Columnas con busquedas frecuentes******* 
--CLIENTE
create index cliente_nombre_completo_ix
on cliente(apellido_paterno, apellido_materno, nombre);

--PUESTO
-- N/A 

-- EMPLEADO 
create index empleado_nombre_completo_ix
on empleado(apellido_paterno, apellido_materno, nombre);

--SESION 
create index sesion_cliente_id_folio_ix
on (cliente_id, folio); 

--HUELLA DACTILAR 
create index huella_dactilar_huellas_ix 
on huella_dactilar(empleado_id, num_dedo);