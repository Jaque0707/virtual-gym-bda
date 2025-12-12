-- @Autor: Benítez Pérez Michelle Paulina
--         Hernández García Pilar Jaqueline
-- @Fecha creación: 12/12/2024
-- @Descripción: Carga datos en la tabla HISTORIAL_STATUS_APARATO desde historial_status_aparato.csv

create or replace procedure carga_historial_status_aparato is
  v_file   UTL_FILE.FILE_TYPE;
  v_line   VARCHAR2(32767);
  v_is_first_line BOOLEAN := TRUE;

  -- Columnas de la tabla HISTORIAL_STATUS_APARATO
  v_fecha_status       DATE;
  v_status_aparato_id  NUMBER(1,0);
  v_aparato_id         NUMBER(10,0);

  v_count NUMBER := 0;
  v_errores NUMBER := 0;

  -- Función auxiliar: parsea CSV respetando comillas
  type t_fields is table of VARCHAR2(32767) index by PLS_INTEGER;

  function parse_csv_line(p_line in VARCHAR2) return t_fields is
    v_fields t_fields;
    v_field VARCHAR2(32767) := '';
    v_in_quotes BOOLEAN := FALSE;
    v_char VARCHAR2(1);
    v_field_idx PLS_INTEGER := 1;
    v_len PLS_INTEGER := LENGTH(p_line);
  begin
    -- Recorrer carácter por carácter
    for i in 1..v_len loop
      v_char := SUBSTR(p_line, i, 1);

      if v_char = '"' then
        -- Toggle el estado de comillas
        v_in_quotes := NOT v_in_quotes;
      elsif v_char = ',' and NOT v_in_quotes then
        -- Es un delimitador de campo (fuera de comillas)
        v_fields(v_field_idx) := v_field;
        v_field_idx := v_field_idx + 1;
        v_field := '';
      else
        -- Es un carácter del campo actual
        v_field := v_field || v_char;
      end if;
    end loop;

    -- Guardar el último campo
    v_fields(v_field_idx) := v_field;

    return v_fields;
  end parse_csv_line;

  -- Función para leer una línea lógica completa del CSV
  function read_csv_record(p_file in out UTL_FILE.FILE_TYPE) return VARCHAR2 is
    v_buffer VARCHAR2(32767);
    v_record VARCHAR2(32767) := '';
  begin
    loop
      begin
        UTL_FILE.GET_LINE(p_file, v_buffer);
      exception
        when NO_DATA_FOUND then
          if LENGTH(v_record) > 0 then
            -- Limpiar y retornar el último registro
            v_record := REPLACE(v_record, CHR(13), '');
            v_record := REPLACE(v_record, CHR(10), '');
            return v_record;
          else
            return NULL;
          end if;
      end;

      -- Limpiar caracteres de control de la línea
      v_buffer := REPLACE(v_buffer, CHR(13), '');
      v_buffer := REPLACE(v_buffer, CHR(10), '');

      -- Agregar la línea al registro actual
      if LENGTH(v_record) > 0 then
        v_record := v_record || ' ' || v_buffer;
      else
        v_record := v_buffer;
      end if;

      -- Retornar cuando tengamos un registro completo
      return v_record;
    end loop;
  end read_csv_record;

begin
  dbms_output.put_line('=============================================================');
  dbms_output.put_line('CARGA DE DATOS - TABLA HISTORIAL_STATUS_APARATO');
  dbms_output.put_line('=============================================================');
  dbms_output.put_line('');

  -- Abrir archivo CSV
  v_file := UTL_FILE.FOPEN('INFRA_DIR', 'historial_status_aparato.csv', 'R', 32767);

  loop
    -- Leer línea del archivo
    v_line := read_csv_record(v_file);

    exit when v_line IS NULL;

    -- Saltar encabezado
    if v_is_first_line then
      v_is_first_line := FALSE;
      dbms_output.put_line('Encabezado: ' || v_line);
      dbms_output.put_line('');
      continue;
    end if;

    -- Procesar cada línea
    declare
      v_fields t_fields;
    begin
      v_fields := parse_csv_line(v_line);

      -- Parsear campos
      v_fecha_status      := TO_DATE(TRIM(v_fields(1)), 'DD/MM/YYYY');
      v_status_aparato_id := TO_NUMBER(TRIM(v_fields(2)));
      v_aparato_id        := TO_NUMBER(TRIM(v_fields(3)));

      -- Insertar registro en la tabla HISTORIAL_STATUS_APARATO
      insert into historial_status_aparato(
        fecha_status,
        status_aparato_id,
        aparato_id
      ) values (
        v_fecha_status,
        v_status_aparato_id,
        v_aparato_id
      );

      v_count := v_count + 1;

      -- Mostrar progreso cada 100 registros
      if MOD(v_count, 100) = 0 then
        dbms_output.put_line('  [' || LPAD(v_count, 4, '0') || '] Procesados...');
      end if;

    exception
      when OTHERS then
        v_errores := v_errores + 1;
        dbms_output.put_line('');
        dbms_output.put_line('  ✗ ERROR en línea ' || (v_count + v_errores + 1));
        dbms_output.put_line('    ' || SQLERRM);
        if v_fields.EXISTS(1) then
          dbms_output.put_line('    Campo 1 (fecha_status): [' || v_fields(1) || ']');
        end if;
        if v_fields.EXISTS(2) then
          dbms_output.put_line('    Campo 2 (status_aparato_id): [' || v_fields(2) || ']');
        end if;
        if v_fields.EXISTS(3) then
          dbms_output.put_line('    Campo 3 (aparato_id): [' || v_fields(3) || ']');
        end if;
        dbms_output.put_line('');
        -- Continuar con el siguiente registro
    end;
  end loop;

  UTL_FILE.FCLOSE(v_file);

  dbms_output.put_line('');
  dbms_output.put_line('=============================================================');
  dbms_output.put_line('RESUMEN DE CARGA');
  dbms_output.put_line('=============================================================');
  dbms_output.put_line('  Registros procesados: ' || v_count);
  dbms_output.put_line('  Registros con error:  ' || v_errores);
  dbms_output.put_line('  Registros insertados: ' || (v_count - v_errores));

  if v_errores > 0 then
    dbms_output.put_line('');
    dbms_output.put_line(' ADVERTENCIA: Hubo errores durante la carga');
  else
    dbms_output.put_line(' Carga completada sin errores');
  end if;

  dbms_output.put_line('=============================================================');

exception
  when OTHERS then
    if UTL_FILE.IS_OPEN(v_file) then
      UTL_FILE.FCLOSE(v_file);
    end if;
    dbms_output.put_line('');
    dbms_output.put_line('ERROR FATAL: ' || SQLERRM);
    raise;
end carga_historial_status_aparato;
/

show errors

prompt
prompt Ejecutando carga de datos para tabla HISTORIAL_STATUS_APARATO...
prompt

set serveroutput on size unlimited
exec carga_historial_status_aparato;

commit;
