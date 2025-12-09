

CREATE OR REPLACE DIRECTORY CLIENTE_DIR AS '/unam/bda/virtual-gym-bda/operacion/carga-inicial';
GRANT READ, WRITE ON DIRECTORY CLIENTE_DIR TO admin_cliente; -- o tu usuario

DECLARE
  v_file   UTL_FILE.FILE_TYPE;
  v_line   VARCHAR2(32767);
  v_is_first_line BOOLEAN := TRUE;

  -- columnas
  v_nombre           VARCHAR2(40);
  v_ap_paterno       VARCHAR2(40);
  v_ap_materno       VARCHAR2(40);
  v_email            VARCHAR2(200);
  v_username         VARCHAR2(40);
  v_password         VARCHAR2(40);
  v_direccion        VARCHAR2(200);
  v_fecha_txt        VARCHAR2(20);
  v_curp_txt         VARCHAR2(30);
  v_foto_txt         VARCHAR2(200);

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
