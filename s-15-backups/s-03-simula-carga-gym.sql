--@Autor: Benítez Pérez Michelle Paulina
--        Hernández García Pilar Jaqueline
--@Fecha creación: 12/12/2024
--@Descripción: Procedimiento para simular carga diaria en el sistema de gimnasios
--              - Inserta nuevos aparatos
--              - Actualiza status de aparatos existentes
--              - Registra todo en historial_status_aparato

connect infra_admin/infra_admin@pf_infraestr

prompt Creando procedimiento simula_carga_gym...

create or replace procedure simula_carga_gym (
    p_num_aparatos        in number default 10,     -- Aparatos nuevos a insertar
    p_porcentaje_cambios  in number default 10      -- % de aparatos existentes que cambiarán status
)
is
  v_aparato_id          number(10,0);
  v_status_id           number(1,0);
  v_tipo_aparato_id     number(10,0);
  v_sala_id             number(10,0);
  v_gimnasio_id         number(10,0);
  v_num_inventario      varchar2(50);
  v_nombre_aparato      varchar2(100);

  -- Contadores
  v_count_tipos         number;
  v_count_status        number;
  v_count_salas         number;
  v_count_gimnasios     number;
  v_aparatos_insertados number := 0;
  v_cambios_status      number := 0;

  -- Queries dinámicos (como en el ejemplo)
  v_query_aparato           varchar2(2000);
  v_query_historial         varchar2(1000);
  v_query_random_status     varchar2(500);
  v_query_actualiza_status  varchar2(500);

  -- Arrays para nombres de aparatos
  type t_nombres is table of varchar2(100) index by pls_integer;
  v_nombres_aparatos t_nombres;

begin
  -- Inicializar nombres de aparatos comunes
  v_nombres_aparatos(1) := 'Maquina de remo';
  v_nombres_aparatos(2) := 'Cinta de correr';
  v_nombres_aparatos(3) := 'Bicicleta estática';
  v_nombres_aparatos(4) := 'Elíptica';
  v_nombres_aparatos(5) := 'Maquina de extension de cuadriceps';
  v_nombres_aparatos(6) := 'Maquina de press de pecho';
  v_nombres_aparatos(7) := 'Maquina de prensa de piernas';
  v_nombres_aparatos(8) := 'Maquina de poleas';
  v_nombres_aparatos(9) := 'Banco de pesas ajustable';
  v_nombres_aparatos(10) := 'Rack de sentadillas';
  v_nombres_aparatos(11) := 'Maquina Smith';
  v_nombres_aparatos(12) := 'Maquina de curl de biceps';

  -- Preparar queries dinámicos (estilo ejemplo)
  v_query_aparato := '
    insert into aparato (
      numero_inventario, nombre, fecha_adquisicion, fecha_status,
      descripcion, sala_id, tipo_aparato_id, status_aparato_id
    ) values (
      :1, :2, :3, :4, :5, :6, :7, :8
    )';

  v_query_historial := '
    insert into historial_status_aparato (
      fecha_status, status_aparato_id, aparato_id
    ) values (
      :1, :2, :3
    )';

  v_query_random_status := '
    select status_aparato_id
    from (
      select status_aparato_id from status_aparato order by dbms_random.value
    ) where rownum = 1';

  v_query_actualiza_status := '
    update aparato
    set status_aparato_id = :1, fecha_status = :2
    where aparato_id = :3';

  -- Verificar que existen datos base
  select count(*) into v_count_tipos from tipo_aparato;
  select count(*) into v_count_status from status_aparato;
  select count(*) into v_count_salas from sala;
  select count(*) into v_count_gimnasios from gimnasio;

  if v_count_tipos = 0 or v_count_status = 0 or v_count_salas = 0 then
    raise_application_error(-20001,
      'ERROR: No hay datos base. Ejecute carga inicial primero.');
  end if;

  -- ============================================================
  -- PARTE 1: INSERTAR NUEVOS APARATOS 
  -- ============================================================
  for i in 1 .. p_num_aparatos loop
    -- Seleccionar tipo de aparato aleatorio
    select tipo_aparato_id
    into v_tipo_aparato_id
    from (
      select tipo_aparato_id from tipo_aparato order by dbms_random.value
    ) where rownum = 1;

    -- Seleccionar status aleatorio (mayoría VIGENTE)
    if dbms_random.value < 0.8 then
      -- 80% VIGENTE
      select status_aparato_id into v_status_id
      from status_aparato where nombre_status = 'VIGENTE';
    else
      -- 20% otro status aleatorio
      execute immediate v_query_random_status into v_status_id;
    end if;

    -- Seleccionar sala aleatoria
    select sala_id
    into v_sala_id
    from (
      select sala_id from sala order by dbms_random.value
    ) where rownum = 1;

    -- Generar número de inventario único
    select gimnasio_id into v_gimnasio_id
    from sala where sala_id = v_sala_id;

    v_num_inventario := 'GYM-' || v_gimnasio_id || '-' ||
                        to_char(dbms_random.value(1000, 9999), 'FM0000');

    -- Seleccionar nombre de aparato
    v_nombre_aparato := v_nombres_aparatos(
      trunc(dbms_random.value(1, v_nombres_aparatos.count + 1))
    );

    -- Insertar aparato usando query dinámico
    execute immediate v_query_aparato using
      v_num_inventario,
      v_nombre_aparato,
      sysdate - trunc(dbms_random.value(0, 365)),  -- Fecha adquisición en último año
      sysdate,                                      -- Fecha status
      'Aparato generado por simulación de carga',  -- Descripción
      v_sala_id,
      v_tipo_aparato_id,
      v_status_id;

    -- Obtener el ID del aparato recién insertado
    select max(aparato_id) into v_aparato_id from aparato;

    -- Insertar en historial
    execute immediate v_query_historial using
      sysdate,
      v_status_id,
      v_aparato_id;

    v_aparatos_insertados := v_aparatos_insertados + 1;

  end loop;

  -- ============================================================
  -- PARTE 2: ACTUALIZAR STATUS DE APARATOS EXISTENTES
  -- ============================================================

  -- Actualizar status de algunos aparatos existentes (como en el ejemplo)
  for r in (
    select aparato_id, status_aparato_id
    from aparato
    where mod(aparato_id, 100) < p_porcentaje_cambios  -- Simula selección aleatoria
  ) loop

    -- Seleccionar nuevo status aleatorio (diferente al actual si es posible)
    begin
      select status_aparato_id
      into v_status_id
      from (
        select status_aparato_id
        from status_aparato
        where status_aparato_id != r.status_aparato_id
        order by dbms_random.value
      ) where rownum = 1;
    exception
      when no_data_found then
        -- Si no hay otros status, usar cualquiera
        execute immediate v_query_random_status into v_status_id;
    end;

    -- Actualizar el status del aparato usando query dinámico
    execute immediate v_query_actualiza_status using
      v_status_id,
      sysdate,
      r.aparato_id;

    -- Insertar en historial
    execute immediate v_query_historial using
      sysdate,
      v_status_id,
      r.aparato_id;

    v_cambios_status := v_cambios_status + 1;

  end loop;

  dbms_output.put_line('  Cambios de status realizados: ' || v_cambios_status);
  dbms_output.put_line('');

  -- Commit de todos los cambios
  commit;

exception
  when others then
    rollback;
    dbms_output.put_line('');
    dbms_output.put_line('ERROR en simulación: ' || sqlerrm);
    dbms_output.put_line('Todos los cambios fueron revertidos (rollback)');
    raise;

end simula_carga_gym;
/

show errors