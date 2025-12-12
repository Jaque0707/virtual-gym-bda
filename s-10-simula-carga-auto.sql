--@Autor:           Jorge Rodriguez
--@Fecha creación:  dd/mm/yyyy
--@Descripción:     

Prompt creación del procedimiento para simular carga de autos
connect jrc_autos/jorge@jrcbda_s2


create or replace procedure simula_carga_auto (
    p_num_autos        in number default 50,
    p_porcentaje  in number default 10   -- % de autos cuyo estatus va a cambiar
)
is
 --ID de tablas relacionadas 
  v_auto_id         number;
  v_status_id       number;
  v_agencia_id      number;
  v_cliente_id      number;

  v_tipo            char(1);
  v_rand            number;
  v_query_auto          varchar2(1000);
  v_query_auto_carga   varchar2(1000);
  v_query_auto_particular   varchar2(1000);
  v_query_historico_status   varchar2(1000);
  v_query_random_status   varchar2(1000);
  v_query_actualiza_auto_status  varchar2(1000);

begin
  v_query_auto:= '
    insert into auto (
      auto_id, marca, modelo, anio, num_serie,
      tipo, precio, descuento, foto, fecha_status,
      status_auto_id, agencia_id, cliente_id
    ) values(
      :1, :2, :3, :4, :5,
      :6, :7, :8, empty_blob(), sysdate,
      :9, :10, :11
    )';
  v_query_auto_carga := '
    insert into auto_carga (
      auto_id, peso_maximo, volumen, tipo_combustible
    ) values (
      :1, :2, :3, :4
    )';
  v_query_auto_particular := '
    insert into auto_particular (
      auto_id, num_cilindros, num_pasajeros, clase
    ) values (
      :1, :2, :3, :4
    )';
  v_query_historico_status := '
    insert into historico_status_auto (
      historico_status_auto_id, fecha_status, status_auto_id, auto_id
    ) values (
      :1, :2, :3, :4
    )';
  v_query_random_status := '
    select status_auto_id
    from (
      select status_auto_id from status_auto order by dbms_random.value
    ) where rownum = 1';
  v_query_actualiza_auto_status := '
    update auto
    set status_auto_id = :1,fecha_status   = :2
    where auto_id = :3';

  --inserta autos nuevos y actualiza estatus de algunos existentes
  for i in 1 .. p_num_autos loop   
    v_rand := dbms_random.value(1, 3);
    if v_rand < 2 then 
      v_tipo := 'p';       -- particular
    else
      v_tipo := 'c';       -- carga
    end if;

    -- random status
    select status_auto_id
    into v_status_id
    from (
      select status_auto_id from status_auto order by dbms_random.value
    ) where rownum = 1;

    -- random agencia
    select agencia_id
    into v_agencia_id
    from (
        select agencia_id from agencia order by dbms_random.value
    ) where rownum = 1;

    -- random cliente (nullable)
    select cliente_id
    into v_cliente_id
    from (
        select cliente_id from cliente order by dbms_random.value
    )
    where rownum = 1;

    -- genera un nuevo id
    v_auto_id := auto_seq.nextval;

    -- inserta un nuevo auto
    execute immediate v_query_auto using
      v_auto_id,
      'marca' || trunc(dbms_random.value(1, 100)),
      'modelo' || trunc(dbms_random.value(1, 50)),
      trunc(dbms_random.value(2000, 2025)),
      'serie-' || to_char(dbms_random.random),
      v_tipo,
      trunc(dbms_random.value(100000, 600000)),
      trunc(dbms_random.value(0, 50000)),
      v_status_id,
      v_agencia_id,
      v_cliente_id;

    -- inserta en el subtipo correspondiente 
    if v_tipo = 'c' then
      execute immediate v_query_auto_carga using
        v_auto_id,
        dbms_random.value(300, 1000),
        dbms_random.value(2, 10),
        'd';
    else
      execute immediate v_query_auto_particular using
        v_auto_id,
        trunc(dbms_random.value(4, 8)),
        trunc(dbms_random.value(2, 7)),
        'a';
    end if;

    -- Agrega entrada al histórico de estatus
    execute immediate v_query_historico_status using
        historico_status_auto_seq.nextval,
        systimestamp,
        v_status_id,
        v_auto_id;
    end loop;

    -- actualiza estatus de algunos autos existentes
    for r in (
        select auto_id
        from auto
        where mod(auto_id, 100) < p_porcentaje   --simula selección aleatoria
    ) loop
        -- selecciona nuevo estatus
        execute immediate v_query_random_status
        into v_status_id;

        -- actualiza el estatus del auto
        execute immediate v_query_actualiza_auto_status
        using
          v_status_id,
          systimestamp,
          r.auto_id;

        -- inserta en el histórico de estatus
        execute immediate v_query_historico_status using
          historico_status_auto_seq.nextval,
          systimestamp,
          v_status_id,
          r.auto_id;
    end loop;

    --actualiza los cambios
    commit;

end simula_carga_auto;
/
show errors
