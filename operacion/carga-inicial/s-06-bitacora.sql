connect opera_admin/opera_admin@pf_operacion

create or replace procedure carga_bitacoras is 
  v_file   UTL_FILE.FILE_TYPE;
  v_line   VARCHAR2(32767);
  v_line_no PLS_INTEGER := 0;
  v_is_first_line BOOLEAN := FALSE;

  -- columnas (texto)
  v_calorias_txt  VARCHAR2(30);
  v_minuto_txt    VARCHAR2(30);
  v_sesion_txt    VARCHAR2(30);

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
  DBMS_OUTPUT.PUT_LINE('Leyendo OPERA_DIR/bitacora.csv ...');

  v_file := UTL_FILE.FOPEN('OPERA_DIR', 'bitacora.csv', 'R', 32767);

  for  i in 1 .. 1000 LOOP  
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

    -- extraer columnas (orden esperado en bitacora.csv):
    -- 1 CALORIAS, 2 MINUTO, 3 SESION_ID
    v_calorias_txt := get_col(v_line, 1);
    v_minuto_txt   := get_col(v_line, 2);
    v_sesion_txt   := get_col(v_line, 3);

    BEGIN
      INSERT INTO bitacora (
        calorias,
        minuto,
        sesion_id
      ) VALUES (
        TO_NUMBER(v_calorias_txt),
        TO_NUMBER(v_minuto_txt),
        TO_NUMBER(v_sesion_txt)
      );
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR en línea #'||v_line_no||' sesion_id="'||v_sesion_txt||'"');
        DBMS_OUTPUT.PUT_LINE('LINEA: '||SUBSTR(v_line, 1, 300));
        RAISE;
    END;

  END LOOP;
  UTL_FILE.FCLOSE(v_file);
  
  DBMS_OUTPUT.PUT_LINE('Carga bitacoras OK.');

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
  carga_bitacoras;
END;
/
