-- @Autor: Benítez Pérez Michelle Paulina
--         Hernández García Pilar Jaqueline
-- @Fecha creación: 12/12/2024
-- @Descripción: Carga datos en la tabla SALA desde sala.csv

create or replace procedure carga_sala is
  v_file   UTL_FILE.FILE_TYPE;
  v_line   VARCHAR2(32767);
  v_is_first_line BOOLEAN := TRUE;

  -- Columnas de la tabla SALA
  v_clave                     VARCHAR2(3);
  v_nombre                    VARCHAR2(40);
  v_capacidad_maxima          NUMBER(3,0);
  v_gimnasio_id               NUMBER(4,0);
  v_empleado_responsable_rid  NUMBER(8,0);

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
      -- (Para simplicidad, asumimos una línea = un registro)
      return v_record;
    end loop;
  end read_csv_record;

begin
  dbms_output.put_line('=============================================================');
  dbms_output.put_line('CARGA DE DATOS - TABLA SALA');
  dbms_output.put_line('=============================================================');
  dbms_output.put_line('');

  -- Abrir archivo CSV
  v_file := UTL_FILE.FOPEN('INFRA_DIR', 'sala.csv', 'R', 32767);

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

      -- Parsear campos (limpiar espacios y caracteres especiales)
      v_clave                     := TRIM(v_fields(1));
      v_nombre                    := TRIM(v_fields(2));
      v_capacidad_maxima          := TO_NUMBER(TRIM(v_fields(3)));
      v_gimnasio_id               := TO_NUMBER(TRIM(v_fields(4)));
      v_empleado_responsable_rid  := TO_NUMBER(TRIM(v_fields(5)));

      -- Insertar registro en la tabla SALA
      insert into sala(
        clave,
        nombre,
        capacidad_maxima,
        gimnasio_id,
        empleado_responsable_rid
      ) values (
        v_clave,
        v_nombre,
        v_capacidad_maxima,
        v_gimnasio_id,
        v_empleado_responsable_rid
      );

      v_count := v_count + 1;

      -- Mostrar progreso cada 10 registros
      if MOD(v_count, 10) = 0 then
        dbms_output.put_line('  [' || LPAD(v_count, 3, '0') || '] Procesados...');
      end if;

    exception
      when DUP_VAL_ON_INDEX then
        v_errores := v_errores + 1;
        dbms_output.put_line('');
        dbms_output.put_line('  ✗ ERROR: Clave duplicada');
        dbms_output.put_line('    Línea: ' || v_line);
        dbms_output.put_line('    Clave: ' || v_clave);
        dbms_output.put_line('');
      when OTHERS then
        v_errores := v_errores + 1;
        dbms_output.put_line('');
        dbms_output.put_line('  ✗ ERROR en línea: ' || v_line);
        dbms_output.put_line('    ' || SQLERRM);
        if v_fields.EXISTS(1) then
          dbms_output.put_line('    Campo 1 (clave): [' || v_fields(1) || ']');
        end if;
        if v_fields.EXISTS(2) then
          dbms_output.put_line('    Campo 2 (nombre): [' || v_fields(2) || ']');
        end if;
        if v_fields.EXISTS(3) then
          dbms_output.put_line('    Campo 3 (capacidad_maxima): [' || v_fields(3) || ']');
        end if;
        if v_fields.EXISTS(4) then
          dbms_output.put_line('    Campo 4 (gimnasio_id): [' || v_fields(4) || ']');
        end if;
        if v_fields.EXISTS(5) then
          dbms_output.put_line('    Campo 5 (empleado_responsable_rid): [' || v_fields(5) || ']');
        end if;
        dbms_output.put_line('');
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
end carga_sala;
/

show errors

prompt Ejecutando carga de datos para tabla SALA...

set serveroutput on size unlimited
exec carga_sala;

commit;