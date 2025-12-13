connect opera_admin/opera_admin@pf_operacion

create or replace procedure carga_sesiones is 
  v_file   UTL_FILE.FILE_TYPE;
  v_line   VARCHAR2(32767);
  v_line_no PLS_INTEGER := 0;
  v_is_first_line BOOLEAN := TRUE;

  -- columnas (texto)
  v_cliente_txt        VARCHAR2(30);
  v_duracion_txt       VARCHAR2(30);
  v_fecha_inicio_txt   VARCHAR2(20);
  v_sala_id_rid_txt    VARCHAR2(30);
  v_instructor_id_txt  VARCHAR2(30);

  -- función auxiliar para obtener la n-ésima columna separada por coma
  FUNCTION get_col(p_line IN VARCHAR2, p_pos IN PLS_INTEGER)
    RETURN VARCHAR2
  IS
    v_start PLS_INTEGER;
    v_end   PLS_INTEGER;
    v_val   VARCHAR2(32767);
  BEGIN
    IF p_pos = 1 THEN
      v_start := 1;
    ELSE
      v_start := INSTR(p_line, ',', 1, p_pos - 1) + 1;
      IF v_start = 1 THEN
        RETURN NULL;
      END IF;
    END IF;

    v_end := INSTR(p_line, ',', 1, p_pos);

    IF v_end = 0 THEN
      v_val := SUBSTR(p_line, v_start);
    ELSE
      v_val := SUBSTR(p_line, v_start, v_end - v_start);
    END IF;

    RETURN NULLIF(v_val, '');
  END;

BEGIN
  DBMS_OUTPUT.PUT_LINE('Leyendo OPERA_DIR/sesion.csv ...');

  v_file := UTL_FILE.FOPEN('OPERA_DIR', 'sesion.csv', 'R', 32767);

  for i in 1 .. 500 LOOP  
    BEGIN
      UTL_FILE.GET_LINE(v_file, v_line);
      v_line_no := v_line_no + 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        EXIT;
    END;

    -- saltar encabezado
    IF v_is_first_line THEN
      v_is_first_line := FALSE;
      CONTINUE;
    END IF;

    -- extraer columnas
    v_cliente_txt       := get_col(v_line, 1);
    v_duracion_txt      := get_col(v_line, 2);
    v_fecha_inicio_txt  := get_col(v_line, 3);
    v_sala_id_rid_txt   := get_col(v_line, 4);
    v_instructor_id_txt := get_col(v_line, 5);

    BEGIN
      INSERT INTO sesion (
        cliente_id,
        duracion_minutos,
        fecha_inicio,
        sala_id_rid,
        empleado_instructor_id
      ) VALUES (
        TO_NUMBER(v_cliente_txt),
        TO_NUMBER(v_duracion_txt),
        TO_DATE(v_fecha_inicio_txt, 'DD/MM/YYYY'),
        TO_NUMBER(v_sala_id_rid_txt),
        TO_NUMBER(v_instructor_id_txt)
      );
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
          'ERROR en línea #'||v_line_no||
          ' fecha_inicio="'||v_fecha_inicio_txt||'"'
        );
        DBMS_OUTPUT.PUT_LINE('LINEA: '||SUBSTR(v_line, 1, 300));
        RAISE;
    END;

  END LOOP;

  UTL_FILE.FCLOSE(v_file);
  DBMS_OUTPUT.PUT_LINE('Carga sesiones OK.');

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
  carga_sesiones;
END;
/

