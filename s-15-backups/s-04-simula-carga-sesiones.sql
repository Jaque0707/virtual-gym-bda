--@Autor: Benítez Pérez Michelle Paulina
--        Hernández García Pilar Jaqueline
--@Fecha creación: 14/12/2024
--@Descripción: Procedimiento para simular carga diaria de sesiones y bitácora
--              Genera sesiones de clientes con instructores, y registra
--              las calorías consumidas por minuto en la tabla bitácora.

Prompt Creando procedimiento simula_carga_sesiones
connect opera_admin/opera_admin@pf_operacion

create or replace procedure simula_carga_sesiones (
    p_num_sesiones        in number default 50,      -- Sesiones a generar
    p_duracion_min        in number default 30,      -- Duración mínima en minutos
    p_duracion_max        in number default 120,     -- Duración máxima en minutos
    p_dias_atras          in number default 1,       -- Días hacia atrás para fecha_inicio
    p_num_aparatos_sesion in number default 3        -- Aparatos promedio por sesión
)
is
  v_cliente_id          number(12);
  v_instructor_id       number(12);
  v_sala_id_rid         number(12);
  v_aparato_id_rid      number(12);
  v_duracion_minutos    number(5,2);
  v_fecha_inicio        date;
  v_sesion_id           number(12);
  v_calorias_minuto     number(10,2);
  v_num_aparatos        number(2);
  v_hora_inicio         number(2);
  v_minuto_inicio       number(2);

  -- Queries preparados
  v_query_sesion        varchar2(1000);
  v_query_bitacora      varchar2(1000);
  v_query_sesion_aparato varchar2(1000);

  -- Cursor para contar registros
  v_count_clientes      number;
  v_count_instructores  number;
  v_count_salas         number;
  v_count_aparatos      number;

begin
  -- Verificar que existen datos base
  select count(*) into v_count_clientes from cliente;
  select count(*) into v_count_instructores from instructor;

  if v_count_clientes = 0 or v_count_instructores = 0 then
    raise_application_error(-20001, 'No hay clientes o instructores en la BD. Ejecute carga inicial primero.');
  end if;

  -- Nota: Las salas y aparatos están en otro PDB (pf_infraestr)
  -- Por ahora usamos valores basados en la carga inicial conocida
  -- En producción, se debería crear un database link o sincronizar IDs
  v_count_salas := 50;      -- Basado en infraestructura/carga-inicial/sala.csv
  v_count_aparatos := 100;   -- Basado en infraestructura/carga-inicial/aparato.csv

  dbms_output.put_line('Usando rangos de IDs: Salas(1-' || v_count_salas || '), Aparatos(1-' || v_count_aparatos || ')');

  -- Preparar queries con bind variables
  v_query_sesion := '
    insert into sesion (
      cliente_id, duracion_minutos, fecha_inicio,
      sala_id_rid, empleado_instructor_id
    ) values (
      :1, :2, :3, :4, :5
    ) returning sesion_id into :6';

  v_query_bitacora := '
    insert into bitacora (
      calorias, minuto, sesion_id
    ) values (
      :1, :2, :3
    )';

  v_query_sesion_aparato := '
    insert into sesion_aparato (
      aparato_id_rid, sesion_id
    ) values (
      :1, :2
    )';

  -- Generar sesiones nuevas
  for i in 1 .. p_num_sesiones loop

    -- Seleccionar cliente aleatorio
    select cliente_id
    into v_cliente_id
    from (
      select cliente_id from cliente order by dbms_random.value
    ) where rownum = 1;

    -- Seleccionar instructor aleatorio
    select empleado_id
    into v_instructor_id
    from (
      select empleado_id from instructor order by dbms_random.value
    ) where rownum = 1;

    -- Generar sala_id aleatoria (entre 1 y v_count_salas)
    v_sala_id_rid := trunc(dbms_random.value(1, v_count_salas + 1));

    -- Generar duración aleatoria entre min y max
    v_duracion_minutos := trunc(dbms_random.value(p_duracion_min, p_duracion_max + 1));

    -- Generar fecha de inicio aleatoria en los últimos p_dias_atras días
    -- Horario de gimnasio: 6 AM a 10 PM (6-22)
    v_hora_inicio := trunc(dbms_random.value(6, 22));
    v_minuto_inicio := trunc(dbms_random.value(0, 60));

    v_fecha_inicio := trunc(sysdate - dbms_random.value(0, p_dias_atras))
                      + (v_hora_inicio/24)
                      + (v_minuto_inicio/1440);

    -- Insertar sesión y obtener el ID generado
    execute immediate v_query_sesion
      using
        v_cliente_id,
        v_duracion_minutos,
        v_fecha_inicio,
        v_sala_id_rid,
        v_instructor_id,
        out v_sesion_id;

    -- Insertar registros de bitácora (uno por minuto de la sesión)
    for minuto in 1 .. trunc(v_duracion_minutos) loop
      -- Generar calorías aleatorias por minuto
      -- Rango típico: 8-15 calorías/minuto dependiendo de intensidad
      -- Agregamos variabilidad: algunos minutos más intensos, otros menos
      if dbms_random.value < 0.2 then
        -- 20% del tiempo: intensidad baja (5-8 cal/min)
        v_calorias_minuto := dbms_random.value(5, 8);
      elsif dbms_random.value < 0.7 then
        -- 50% del tiempo: intensidad media (8-12 cal/min)
        v_calorias_minuto := dbms_random.value(8, 12);
      else
        -- 30% del tiempo: intensidad alta (12-18 cal/min)
        v_calorias_minuto := dbms_random.value(12, 18);
      end if;

      -- Insertar en bitácora
      execute immediate v_query_bitacora
        using
          round(v_calorias_minuto, 2),
          minuto,
          v_sesion_id;
    end loop;

    -- Insertar aparatos usados en la sesión
    -- Generar número aleatorio de aparatos (1 a p_num_aparatos_sesion)
    v_num_aparatos := trunc(dbms_random.value(1, p_num_aparatos_sesion + 1));

    for j in 1 .. v_num_aparatos loop
      -- Generar aparato_id aleatorio
      v_aparato_id_rid := trunc(dbms_random.value(1, v_count_aparatos + 1));

      -- Insertar relación sesión-aparato
      -- Manejar posibles duplicados (mismo aparato dos veces en misma sesión)
      begin
        execute immediate v_query_sesion_aparato
          using
            v_aparato_id_rid,
            v_sesion_id;
      exception
        when dup_val_on_index then
          null; -- Ignorar duplicados
      end;
    end loop;

  end loop;

  -- Commit de todos los cambios
  commit;

  -- Mostrar estadísticas
  declare
    v_total_sesiones number;
    v_total_bitacora number;
    v_total_calorias number;
    v_sesiones_hoy   number;
  begin
    select count(*) into v_total_sesiones from sesion;
    select count(*) into v_total_bitacora from bitacora;
    select nvl(sum(calorias), 0) into v_total_calorias from bitacora;
    select count(*) into v_sesiones_hoy
      from sesion where trunc(fecha_inicio) = trunc(sysdate);

  end;

exception
  when others then
    rollback;
    dbms_output.put_line('ERROR en simulación: ' || sqlerrm);
    raise;

end simula_carga_sesiones;
/

show errors