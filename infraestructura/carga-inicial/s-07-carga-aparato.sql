-- @Autor: Benítez Pérez Michelle Paulina
--         Hernández García Pilar Jaqueline
-- @Fecha creación: 12/12/2024
-- @Descripción: Carga datos en la tabla APARATO desde aparato.csv

create or replace procedure carga_aparato is
  v_file   UTL_FILE.FILE_TYPE;
  v_line   VARCHAR2(32767);
  v_is_first_line BOOLEAN := TRUE;

  -- Columnas de la tabla APARATO
  v_numero_inventario   VARCHAR2(18);
  v_nombre              VARCHAR2(40);
  v_fecha_adquisicion   DATE;
  v_fecha_status        DATE;
  v_descripcion         VARCHAR2(500);
  v_sala_id             NUMBER(7,0);
  v_tipo_aparato_id     NUMBER(4,0);
  v_status_aparato_id   NUMBER(1,0);

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
    v_quote_count PLS_INTEGER := 0;
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
        v_record := v_record || ' ' || v_buffer;  -- Espacio en lugar de salto
      else
        v_record := v_buffer;
      end if;

      -- Contar TODAS las comillas acumuladas hasta ahora en el registro completo
      v_quote_count := 0;
      for i in 1..LENGTH(v_record) loop
        if SUBSTR(v_record, i, 1) = '"' then
          v_quote_count := v_quote_count + 1;
        end if;
      end loop;

      -- Si el número de comillas es par, la línea lógica está completa
      if MOD(v_quote_count, 2) = 0 then
        return v_record;
      end if;

      -- Si es impar, necesitamos seguir leyendo
    end loop;
  end read_csv_record;

begin
  dbms_output.put_line('=============================================================');
  dbms_output.put_line('CARGA DE DATOS - TABLA APARATO');
  dbms_output.put_line('=============================================================');
  dbms_output.put_line('');

  -- Abrir archivo CSV
  v_file := UTL_FILE.FOPEN('INFRA_DIR', 'aparato.csv', 'R', 32767);

  loop
    -- Leer línea del archivo
    v_line := read_csv_record(v_file);

    exit when v_line IS NULL;

    -- Saltar encabezado
    if v_is_first_line then
      v_is_first_line := FALSE;
      dbms_output.put_line('Encabezado: ' || SUBSTR(v_line, 1, 100) || '...');
      dbms_output.put_line('');
      continue;
    end if;

    -- Procesar cada línea
    declare
      v_fields t_fields;
      v_field_count PLS_INTEGER;
    begin
      v_fields := parse_csv_line(v_line);
      v_field_count := v_fields.COUNT;

      -- Verificar que tengamos 8 campos
      if v_field_count < 8 then
        RAISE_APPLICATION_ERROR(-20001,
          'Número incorrecto de campos: ' || v_field_count || ' (se esperaban 8)');
      end if;

      -- Parsear campos
      v_numero_inventario  := TRIM(v_fields(1));
      v_nombre             := TRIM(v_fields(2));

      -- CRÍTICO: Convertir fechas desde formato DD/MM/YYYY
      v_fecha_adquisicion  := TO_DATE(TRIM(v_fields(3)), 'DD/MM/YYYY');
      v_fecha_status       := TO_DATE(TRIM(v_fields(4)), 'DD/MM/YYYY');

      v_descripcion        := TRIM(v_fields(5));
      v_sala_id            := TO_NUMBER(TRIM(v_fields(6)));
      v_tipo_aparato_id    := TO_NUMBER(TRIM(v_fields(7)));
      v_status_aparato_id  := TO_NUMBER(TRIM(v_fields(8)));

      -- Insertar registro en la tabla APARATO
      insert into aparato(
        numero_inventario,
        nombre,
        fecha_adquisicion,
        fecha_status,
        descripcion,
        sala_id,
        tipo_aparato_id,
        status_aparato_id
      ) values (
        v_numero_inventario,
        v_nombre,
        v_fecha_adquisicion,
        v_fecha_status,
        v_descripcion,
        v_sala_id,
        v_tipo_aparato_id,
        v_status_aparato_id
      );

      v_count := v_count + 1;

      -- Mostrar progreso cada 20 registros
      if MOD(v_count, 20) = 0 then
        dbms_output.put_line('  [' || LPAD(v_count, 3, '0') || '] Procesados...');
      end if;

    exception
      when OTHERS then
        v_errores := v_errores + 1;
        dbms_output.put_line('');
        dbms_output.put_line('  ✗ ERROR en línea ' || (v_count + v_errores + 1));
        dbms_output.put_line('    ' || SQLERRM);
        if v_field_count >= 1 then
          dbms_output.put_line('    Campo 1 (numero_inventario): [' || SUBSTR(v_fields(1), 1, 30) || ']');
        end if;
        if v_field_count >= 2 then
          dbms_output.put_line('    Campo 2 (nombre): [' || SUBSTR(v_fields(2), 1, 30) || ']');
        end if;
        if v_field_count >= 3 then
          dbms_output.put_line('    Campo 3 (fecha_adquisicion): [' || v_fields(3) || ']');
        end if;
        if v_field_count >= 4 then
          dbms_output.put_line('    Campo 4 (fecha_status): [' || v_fields(4) || ']');
        end if;
        dbms_output.put_line('    Línea (primeros 200 chars): ' || SUBSTR(v_line, 1, 200));
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
end carga_aparato;
/

show errors

prompt
prompt Ejecutando carga de datos para tabla APARATO...
prompt

set serveroutput on size unlimited
exec carga_aparato;

commit;
