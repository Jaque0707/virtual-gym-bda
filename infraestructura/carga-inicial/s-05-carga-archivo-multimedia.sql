--@Autor: Benítez Pérez Michelle Paulina
--        Hernández García Pilar Jaqueline
--@Fecha creación: 12/12/2024
--@Descripción: Carga archivos multimedia (imágenes/videos) desde el sistema de archivos

-- Procedimiento para cargar archivos multimedia (BLOB) desde el filesystem
create or replace procedure carga_archivo_multimedia is
  v_file   UTL_FILE.FILE_TYPE;
  v_line   VARCHAR2(32767);
  v_is_first_line BOOLEAN := TRUE;

  -- Columnas del CSV
  v_nombre_archivo  VARCHAR2(100);
  v_fecha_inicio    DATE;
  v_fecha_fin       DATE;
  v_gimnasio_id     NUMBER(4,0);

  -- Para manejo de BLOB
  v_bfile  BFILE;
  v_blob   BLOB;
  v_archivo_id NUMBER;

  v_count NUMBER := 0;
  v_errores NUMBER := 0;

  -- Función auxiliar: parsea CSV respetando comillas
  type t_fields is table of VARCHAR2(32767) index by PLS_INTEGER;

  function parse_csv_line(p_line in VARCHAR2) return t_fields is
    v_fields t_fields;
    v_field VARCHAR2(32767) := '';
    v_in_quotes BOOLEAN := FALSE;
    v_idx PLS_INTEGER := 1;
    v_char CHAR(1);
  begin
    for i in 1..length(p_line) loop
      v_char := substr(p_line, i, 1);

      if v_char = '"' then
        v_in_quotes := not v_in_quotes;
      elsif v_char = ',' and not v_in_quotes then
        v_fields(v_idx) := v_field;
        v_field := '';
        v_idx := v_idx + 1;
      else
        v_field := v_field || v_char;
      end if;
    end loop;

    -- Agregar último campo
    v_fields(v_idx) := v_field;
    return v_fields;
  end parse_csv_line;

begin
  dbms_output.put_line('=============================================================');
  dbms_output.put_line('CARGA DE ARCHIVOS MULTIMEDIA');
  dbms_output.put_line('=============================================================');
  dbms_output.put_line('');

  -- Abrir CSV con metadatos
  v_file := UTL_FILE.FOPEN('INFRA_DIR', 'archivo_multimedia.csv', 'R', 32767);

  loop
    begin
      UTL_FILE.GET_LINE(v_file, v_line);
    exception
      when NO_DATA_FOUND then
        exit;
    end;

    -- Saltar encabezado
    if v_is_first_line then
      v_is_first_line := FALSE;
      continue;
    end if;

    -- Procesar cada línea
    declare
      v_fields t_fields;
      v_tamaño_archivo NUMBER;
      v_extension VARCHAR2(10);
    begin
      v_fields := parse_csv_line(v_line);

      -- Parsear campos (limpiar caracteres especiales como \r \n)
      v_nombre_archivo := trim(replace(replace(v_fields(1), chr(13), ''), chr(10), ''));
      v_fecha_inicio   := to_date(trim(replace(replace(v_fields(2), chr(13), ''), chr(10), '')), 'yyyy/mm/dd');
      v_fecha_fin      := to_date(trim(replace(replace(v_fields(3), chr(13), ''), chr(10), '')), 'yyyy/mm/dd');
      v_gimnasio_id    := to_number(trim(replace(replace(v_fields(4), chr(13), ''), chr(10), '')));

      -- Obtener extensión del archivo
      v_extension := upper(substr(v_nombre_archivo, instr(v_nombre_archivo, '.', -1)));

      -- Insertar registro con BLOB vacío primero
      insert into archivo_multimedia(
        archivo_multimedia,
        fecha_inicio,
        fecha_fin,
        gimnasio_id
      ) values (
        empty_blob(),  -- BLOB vacío inicialmente
        v_fecha_inicio,
        v_fecha_fin,
        v_gimnasio_id
      ) returning archivo_id, archivo_multimedia
        into v_archivo_id, v_blob;

      -- Obtener referencia al archivo en el filesystem
      -- IMPORTANTE: Usar MULTIMEDIA_DIR en mayúsculas
      v_bfile := bfilename('INFRA_DIR', v_nombre_archivo);

      -- Verificar que el archivo existe en el sistema de archivos
      if dbms_lob.fileexists(v_bfile) = 0 then
        raise_application_error(-20001,
          'El archivo ' || v_nombre_archivo ||
          ' no existe en INFRA_DIR (/opt/oracle/oradata/FREE/proyecto/infraestructura)');
      end if;

      -- Abrir archivo para lectura
      dbms_lob.fileopen(v_bfile, dbms_lob.file_readonly);

      -- Cargar contenido del archivo en el BLOB
      dbms_lob.loadfromfile(
        dest_lob => v_blob,
        src_lob  => v_bfile,
        amount   => dbms_lob.getlength(v_bfile)
      );

      -- Obtener tamaño final
      v_tamaño_archivo := dbms_lob.getlength(v_blob);

      -- Validar que se cargó correctamente
      if v_tamaño_archivo <> dbms_lob.getlength(v_bfile) then
        raise_application_error(-20002,
          'Error al cargar ' || v_nombre_archivo ||
          ': longitudes no coinciden (archivo=' ||
          dbms_lob.getlength(v_bfile) || ', BLOB=' || v_tamaño_archivo || ')');
      end if;

      -- Cerrar archivo
      dbms_lob.fileclose(v_bfile);

      v_count := v_count + 1;

      -- Formatear tamaño en KB o MB
      if v_tamaño_archivo < 1024*1024 then
        dbms_output.put_line('  [' || lpad(v_count, 2, '0') || '] ' ||
          rpad(v_nombre_archivo, 20) || ' -> ' ||
          lpad(round(v_tamaño_archivo/1024, 1), 8) || ' KB  (Gym #' || v_gimnasio_id || ')');
      else
        dbms_output.put_line('  [' || lpad(v_count, 2, '0') || '] ' ||
          rpad(v_nombre_archivo, 20) || ' -> ' ||
          lpad(round(v_tamaño_archivo/1024/1024, 2), 8) || ' MB  (Gym #' || v_gimnasio_id || ')');
      end if;

    exception
      when others then
        v_errores := v_errores + 1;
        dbms_output.put_line('');
        dbms_output.put_line('  ✗ ERROR en línea: ' || v_line);
        dbms_output.put_line('    Error: ' || SQLERRM);
        dbms_output.put_line('    Campo 1 (archivo): [' || v_fields(1) || ']');
        dbms_output.put_line('    Campo 2 (fecha_inicio): [' || v_fields(2) || ']');
        dbms_output.put_line('    Campo 3 (fecha_fin): [' || v_fields(3) || ']');
        dbms_output.put_line('    Campo 4 (gimnasio_id): [' || v_fields(4) || ']');
        dbms_output.put_line('');
        -- No hacer rollback aquí, continuar con el siguiente
    end;
  end loop;

  UTL_FILE.FCLOSE(v_file);

  dbms_output.put_line('');
  dbms_output.put_line('=============================================================');
  dbms_output.put_line('RESUMEN DE CARGA');
  dbms_output.put_line('=============================================================');
  dbms_output.put_line('  Archivos procesados: ' || v_count);
  dbms_output.put_line('  Errores: ' || v_errores);

  if v_errores > 0 then
    dbms_output.put_line('');
    dbms_output.put_line('ADVERTENCIA: Hubo errores durante la carga');
  else
    dbms_output.put_line('Carga completada sin errores');
  end if;

  dbms_output.put_line('=============================================================');

exception
  when others then
    if UTL_FILE.IS_OPEN(v_file) then
      UTL_FILE.FCLOSE(v_file);
    end if;
    dbms_output.put_line('');
    dbms_output.put_line('ERROR FATAL: ' || SQLERRM);
    raise;
end;
/

show errors

prompt Ejecutando carga de archivos multimedia...

set serveroutput on size unlimited
exec carga_archivo_multimedia;

commit;