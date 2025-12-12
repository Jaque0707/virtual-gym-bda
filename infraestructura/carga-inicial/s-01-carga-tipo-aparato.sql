-- Inserta en la tabla tipo_aparato
create or replace procedure carga_tipo_aparato is
  v_file   UTL_FILE.FILE_TYPE;
  v_line   VARCHAR2(32767);
  v_is_first_line BOOLEAN := TRUE;

  -- columnas
  v_descripcion  VARCHAR2(500);
  v_nombre_tipo  VARCHAR2(500);

  v_rows number;
  v_query varchar2(500);

  -- función auxiliar: parsea CSV respetando comillas
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
        v_record := v_record || ' ' || v_buffer;
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
  -- 1. Iniciamos las variables
  v_rows := 100;
  v_query := 'insert into tipo_aparato(DESCRIPCION,NOMBRE_TIPO) values (:ph1,:ph2)';

  -- 2. Abre el archivo en modo lectura
  v_file := UTL_FILE.FOPEN('INFRA_DIR', 'tipo_aparato.csv', 'R', 32767);

  loop
    -- 3. Lee un registro completo del CSV
    v_line := read_csv_record(v_file);

    exit when v_line IS NULL;

    -- 4. Saltar encabezado (primera línea)
    if v_is_first_line then
      v_is_first_line := FALSE;
      continue;
    end if;

    -- 5. Parsear la línea CSV
    declare
      v_fields t_fields;
      v_field_count PLS_INTEGER;
    begin
      v_fields := parse_csv_line(v_line);

      -- Contar cuántos campos se parsearon
      v_field_count := v_fields.COUNT;

      -- 6. Extraer los valores de cada columna
      if v_field_count >= 2 then
        v_descripcion := TRIM(v_fields(1));
        v_nombre_tipo := TRIM(v_fields(2));

        -- 7. Realizar las inserciones
        execute immediate v_query
        using v_descripcion, v_nombre_tipo;
      else
        RAISE_APPLICATION_ERROR(-20001,
          'Numero incorrecto de campos: ' || v_field_count || ' (se esperaban 2)');
      end if;

    exception
      when others then
        -- Mostrar información de depuración en caso de error
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('Error procesando registro');
        DBMS_OUTPUT.PUT_LINE('Numero de campos parseados: ' || v_field_count);
        if v_field_count >= 1 then
          DBMS_OUTPUT.PUT_LINE('Campo 1 (DESCRIPCION): [' || SUBSTR(v_fields(1), 1, 50) || ']');
        end if;
        if v_field_count >= 2 then
          DBMS_OUTPUT.PUT_LINE('Campo 2 (NOMBRE_TIPO): [' || SUBSTR(v_fields(2), 1, 50) || ']');
        end if;
        DBMS_OUTPUT.PUT_LINE('Linea (primeros 300 chars): ' || SUBSTR(v_line, 1, 300));
        DBMS_OUTPUT.PUT_LINE('SQLCODE: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('SQLERRM: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('========================================');
        RAISE;
    end;

  end loop;

  UTL_FILE.FCLOSE(v_file);
  COMMIT;

  DBMS_OUTPUT.PUT_LINE('Carga de tipo_aparato completada exitosamente');
END;
/

-- Ejecutar el procedimiento
BEGIN
  carga_tipo_aparato;
END;
/

COMMIT;
