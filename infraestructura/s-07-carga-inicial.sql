--@Autor: Benítez Pérez Michelle Paulina
--        Hernández García Pilar Jaqueline
--@Fecha creación: 08/12/2025
--@Descripción: 

connect sys/systemP@pf_infraestr as sysdba

-- 1. Dar acceso al directorio donde estan los csv de carga /opt/oracle/oradata/FREE/proyecto/infraestructura
create or replace directory INFRA_DIR as 'proyecto/infraestructura';
grant read, write on directory INFRA_DIR to infra_admin;

prompt Verificar INFRA_DIR

SELECT directory_name, directory_path
  FROM dba_directories
  WHERE directory_name = 'INFRA_DIR';

whenever  sqlerror exit rollback

prompt Conectarse como infra_admin

connect infra_admin/infra_admin@pf_infraestr

prompt Ejecutar procedimientos

--2. llamadas a procedimientos que realizan la carga

@carga-inicial/s-01-carga-tipo-aparato
@carga-inicial/s-02-carga-status-aparato
@carga-inicial/s-03-carga-gimnasio
@carga-inicial/s-04-carga-disciplina
@carga-inicial/s-05-carga-archivo-multimedia
@carga-inicial/s-06-carga-sala
@carga-inicial/s-07-carga-aparato



Prompt confirmando cambios
commit;

Prompt Listo!