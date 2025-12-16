--@Autor: Benítez Pérez Michelle Paulina
--        Hernández García Pilar Jaqueline
--@Fecha creación: 12/12/2024
--@Descripción: Procedimiento para simular carga diaria en el sistema de gimnasios
--              Actualiza el estatus de aparatos existentes y registra en el historial

connect infra_admin/infra_admin@pf_infraestr

set serveroutput on

prompt Creando procedimiento simula_carga_gym...

create or replace procedure simula_carga_gym (
    p_num_cambios_status in number default 2
)
is
  v_aparato_id         number(10,0);
  v_status_id          number(1,0);
  v_total_aparatos     number;
  v_total_status       number;
  v_cambios_realizados number := 0;

  cursor c_aparatos_random is
    select aparato_id, status_aparato_id
    from (
      select aparato_id, status_aparato_id
      from aparato
      order by dbms_random.value
    )
    where rownum <= p_num_cambios_status;

begin
  dbms_output.put_line('========================================');
  dbms_output.put_line('SIMULACION DE CARGA - GIMNASIO');
  dbms_output.put_line('========================================');

  -- Verificar que hay aparatos en la BD
  select count(*) into v_total_aparatos from aparato;
  select count(*) into v_total_status from status_aparato;

  if v_total_aparatos = 0 then
    dbms_output.put_line('ERROR: No hay aparatos en la base de datos');
    return;
  end if;

  if v_total_status = 0 then
    dbms_output.put_line('ERROR: No hay status de aparatos en la base de datos');
    return;
  end if;

  dbms_output.put_line('Total de aparatos disponibles: ' || v_total_aparatos);
  dbms_output.put_line('Cambios de status a realizar: ' || p_num_cambios_status);
  dbms_output.put_line('');

  -- Actualizar estatus de aparatos aleatorios
  for r in c_aparatos_random loop
    -- Seleccionar un nuevo estatus aleatorio (diferente al actual si es posible)
    select status_aparato_id
    into v_status_id
    from (
      select status_aparato_id
      from status_aparato
      where status_aparato_id != r.status_aparato_id  -- Evitar el mismo status
      order by dbms_random.value
    )
    where rownum = 1;

    -- Si no hay otros status disponibles, usar cualquiera
    if v_status_id is null then
      select status_aparato_id
      into v_status_id
      from (
        select status_aparato_id from status_aparato order by dbms_random.value
      )
      where rownum = 1;
    end if;

    -- Actualizar el estatus del aparato
    update aparato
    set status_aparato_id = v_status_id,
        fecha_status = sysdate
    where aparato_id = r.aparato_id;

    -- Insertar en el historial
    insert into historial_status_aparato (
      fecha_status,
      status_aparato_id,
      aparato_id
    ) values (
      sysdate,
      v_status_id,
      r.aparato_id
    );

    v_cambios_realizados := v_cambios_realizados + 1;

    -- Obtener el nombre del nuevo status para el log
    declare
      v_status_nombre varchar2(20);
    begin
      select nombre_status into v_status_nombre
      from status_aparato
      where status_aparato_id = v_status_id;

      dbms_output.put_line('  [' || lpad(v_cambios_realizados, 2, '0') || '] Aparato #' ||
                          r.aparato_id || ' -> ' || v_status_nombre);
    end;
  end loop;

  -- Confirmar cambios
  commit;

  dbms_output.put_line('');
  dbms_output.put_line('========================================');
  dbms_output.put_line('RESUMEN DE CARGA');
  dbms_output.put_line('========================================');
  dbms_output.put_line('Cambios de status realizados: ' || v_cambios_realizados);
  dbms_output.put_line('Registros insertados en historial: ' || v_cambios_realizados);
  dbms_output.put_line('Fecha/Hora: ' || to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'));
  dbms_output.put_line('========================================');

exception
  when others then
    rollback;
    dbms_output.put_line('ERROR: ' || sqlerrm);
    raise;
end simula_carga_gym;
/

show errors

prompt Procedimiento creado exitosamente.