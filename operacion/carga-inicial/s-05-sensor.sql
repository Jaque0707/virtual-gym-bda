

CREATE OR REPLACE DIRECTORY CLIENTE_DIR AS '/unam/bda/virtual-gym-bda/operacion/carga-inicial';
GRANT READ, WRITE ON DIRECTORY CLIENTE_DIR TO admin_cliente; -- o tu usuario

create or replace procedure carga_sensor is 
  v_file   UTL_FILE.FILE_TYPE;
  v_line   VARCHAR2(32767);
  v_is_first_line BOOLEAN := TRUE;

  -- columnas
  v_id           VARCHAR2(50); 
  v_num_serie    VARCHAR2(50); 
  v_fecha_compra VARCHAR2(50); 
  v_marca        VARCHAR2(50); 
  v_cliente_id   VARCHAR2(50); 

  -- función auxiliar para obtener la n-ésima columna separada por coma
  FUNCTION get_col(p_line IN VARCHAR2, p_pos IN PLS_INTEGER)
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN REGEXP_SUBSTR(p_line, '[^,]+', 1, p_pos);
  END;
BEGIN
  -- abrir archivo en modo lectura
  v_file := UTL_FILE.FOPEN('CLIENTE_DIR', 'cliente.csv', 'R', 32767);

  LOOP
    BEGIN
      UTL_FILE.GET_LINE(v_file, v_line);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        EXIT;
    END;

    -- saltar encabezado (primera línea)
    --IF v_is_first_line THEN
      --v_is_first_line := FALSE;
      --CONTINUE;
    --END IF;

    -- extraer columnas
    v_nombre      := get_col(v_line, 1);
    v_ap_paterno  := get_col(v_line, 2);
    v_ap_materno  := get_col(v_line, 3);
    v_email       := get_col(v_line, 4);
    v_username    := get_col(v_line, 5);
    v_password    := get_col(v_line, 6);
    v_direccion   := get_col(v_line, 7);
    v_fecha_txt   := get_col(v_line, 8);
    v_curp_txt    := get_col(v_line, 9);
    v_foto_txt    := get_col(v_line,10); -- no lo usamos, pero lo leemos

    INSERT INTO cliente (
      nombre,
      apellido_paterno,
      apellido_materno,
      email,
      username,
      password,
      direccion,
      fecha_nacimiento,
      curp,
      foto
    ) VALUES (
      v_nombre,
      v_ap_paterno,
      v_ap_materno,
      v_email,
      v_username,
      v_password,
      v_direccion,
      TO_DATE(v_fecha_txt, 'DD/MM/YYYY'),
      SUBSTR(v_curp_txt, 1, 20),
      EMPTY_BLOB()  -- BLOB inicial
    );
  END LOOP;
  UTL_FILE.FCLOSE(v_file);
END;
/
