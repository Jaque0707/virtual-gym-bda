connect opera_admin/opera_admin@pf_operacion as sysdba

create or replace procedure carga_clientes is 
  v_file   UTL_FILE.FILE_TYPE;
  v_line   VARCHAR2(32767);
  v_line_no PLS_INTEGER := 0;
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
    v_start PLS_INTEGER;
    v_end   PLS_INTEGER;
    v_val   VARCHAR2(32767);
  BEGIN
    -- inicio del campo: 1 o después de la (pos-1)-ésima coma
    IF p_pos = 1 THEN
      v_start := 1;
    ELSE
      v_start := INSTR(p_line, ',', 1, p_pos - 1) + 1;
      IF v_start = 1 THEN
        RETURN NULL; -- no existe esa columna
      END IF;
    END IF;

    -- fin del campo: coma número pos, o fin de línea
    v_end := INSTR(p_line, ',', 1, p_pos);

    IF v_end = 0 THEN
      v_val := SUBSTR(p_line, v_start);
    ELSE
      v_val := SUBSTR(p_line, v_start, v_end - v_start);
    END IF;

    -- si viene vacío (por ",," o ",<fin>"), regresa NULL
    RETURN NULLIF(v_val, '');
  END;



BEGIN
  DBMS_OUTPUT.PUT_LINE('Leyendo OPERA_DIR/cliente.csv ...');

  v_file := UTL_FILE.FOPEN('OPERA_DIR', 'cliente.csv', 'R', 32767);

  for  i in 1 .. 201 LOOP  
    BEGIN
      UTL_FILE.GET_LINE(v_file, v_line);
      v_line_no := v_line_no + 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        EXIT;
    END;

    -- saltar encabezado (primera línea)
    IF v_is_first_line THEN
      v_is_first_line := FALSE;
      CONTINUE;
    END IF;

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

    BEGIN
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
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR en línea #'||v_line_no||' fecha_txt="'||v_fecha_txt||'"');
        DBMS_OUTPUT.PUT_LINE('LINEA: '||SUBSTR(v_line, 1, 300));
        RAISE;
    END;

  END LOOP;
  UTL_FILE.FCLOSE(v_file);
  
  DBMS_OUTPUT.PUT_LINE('Carga clientes OK.');

  EXCEPTION
  WHEN OTHERS THEN
    IF UTL_FILE.IS_OPEN(v_file) THEN
      UTL_FILE.FCLOSE(v_file);
    END IF;
    ROLLBACK;
    RAISE;
END;
/

SET SERVEROUTPUT ON
BEGIN
  carga_clientes;
END;
/


