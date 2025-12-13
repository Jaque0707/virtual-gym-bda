connect opera_admin/opera_admin@pf_operacion

create or replace procedure carga_empleados is 
  v_file   UTL_FILE.FILE_TYPE;
  v_line   VARCHAR2(32767);
  v_line_no PLS_INTEGER := 0;
  v_is_first_line BOOLEAN := FALSE;

  -- columnas
  v_nombre        VARCHAR2(40);
  v_ap_paterno    VARCHAR2(40);
  v_ap_materno    VARCHAR2(40);
  v_curp          VARCHAR2(20);
  v_rfc           VARCHAR2(20);
  v_fecha_txt     VARCHAR2(20);
  v_email         VARCHAR2(200);
  v_foto_txt      VARCHAR2(200);
  v_tipo_empleado VARCHAR2(2);
  v_puesto_txt    VARCHAR2(30);

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
  DBMS_OUTPUT.PUT_LINE('Leyendo OPERA_DIR/empleado.csv ...');

  v_file := UTL_FILE.FOPEN('OPERA_DIR', 'empleado_instructor.csv', 'R', 32767);

  for  i in 1 .. 25 LOOP  
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

    -- extraer columnas (orden esperado en empleado.csv):
    -- 1 NOMBRE, 2 APELLIDO_PATERNO, 3 APELLIDO_MATERNO, 4 CURP, 5 RFC,
    -- 6 FECHA_NACIMIENTO, 7 EMAIL, 8 FOTO, 9 TIPO_EMPLEADO, 10 PUESTO_ID
    v_nombre        := get_col(v_line, 1);
    v_ap_paterno    := get_col(v_line, 2);
    v_ap_materno    := get_col(v_line, 3);
    v_curp          := get_col(v_line, 4);
    v_rfc           := get_col(v_line, 5);
    v_fecha_txt     := get_col(v_line, 6);
    v_email         := get_col(v_line, 7);
    v_foto_txt      := get_col(v_line, 8); -- no lo usamos, pero lo leemos
    v_tipo_empleado := get_col(v_line, 9);
    v_puesto_txt    := get_col(v_line,10);

    BEGIN
      INSERT INTO empleado (
        nombre,
        apellido_paterno,
        apellido_materno,
        curp,
        rfc,
        fecha_nacimiento,
        email,
        foto,
        tipo_empleado,
        puesto_id
      ) VALUES (
        v_nombre,
        v_ap_paterno,
        v_ap_materno,
        SUBSTR(v_curp, 1, 20),
        SUBSTR(v_rfc, 1, 20),
        TO_DATE(v_fecha_txt, 'DD/MM/YYYY'),
        v_email,
        EMPTY_BLOB(),                      -- BLOB inicial
        SUBSTR(v_tipo_empleado, 1, 1),     -- CHAR(1)
        TO_NUMBER(v_puesto_txt)
      );
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR en línea #'||v_line_no||' fecha_txt="'||v_fecha_txt||'"');
        DBMS_OUTPUT.PUT_LINE('LINEA: '||SUBSTR(v_line, 1, 300));
        RAISE;
    END;

  END LOOP;
  UTL_FILE.FCLOSE(v_file);
  
  DBMS_OUTPUT.PUT_LINE('Carga empleados instructores 1 OK.');

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
  carga_empleados;
END;
/
