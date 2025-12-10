


-- 1. Dar acceso al directorio donde estan los csv de carga
create or replace directory INFRA_DIR as 'vitual_gym-bda/infraestructura/carga-inicial';
grant read, write on directory INFRA_DIR to <colocar_usuario_carga>;

--2. llamadas a procedimiento que relizan la carga
@carga-inicial/s-07-carga-aparato 
  