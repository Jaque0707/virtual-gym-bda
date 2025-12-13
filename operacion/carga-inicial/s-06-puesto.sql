connect opera_admin/opera_admin@pf_operacion as sysdba

create or replace procedure carga_puestos is
  v_file          UTL_FILE.FILE_TYPE;
  v_line          VARCHAR2(32767);
  v_line_no       PLS_INTEGER := 0;
  v_is_first_line BOOLEAN := TRUE;

  -- columnas (en grande para que NUNCA truene al asignar)
  v_clave       VARCHAR2(5);
  v_descripcion VARCHAR2(200);
  v_nombre      VARCHAR2(40);

  TYPE t_cols IS TABLE OF VARCHAR2(32767) INDEX BY PLS_INTEGER;
  v_cols t_cols;

  PROCEDURE parse_csv_line(p_line IN VARCHAR2, p_cols OUT t_cols) IS
    i         PLS_INTEGER := 1;
    col_idx   PLS_INTEGER := 1;
    ch        CHAR(1);
    in_quotes BOOLEAN := FALSE;
    buf       VARCHAR2(32767) := '';
    len       PLS_INTEGER := NVL(LENGTH(p_line), 0);

    PROCEDURE push_col IS
    BEGIN
      p_cols(col_idx) := NULLIF(buf, '');
      col_idx := col_idx + 1;
      buf := '';
    END;
  BEGIN
    p_cols.DELETE;

    WHILE i <= len LOOP
      ch := SUBSTR(p_line, i, 1);

      IF ch = '"' THEN
        IF in_quotes AND i < len AND SUBSTR(p_line, i+1, 1) = '"' THEN
          -- "" dentro de comillas
          IF LENGTH(buf) < 32767 THEN buf := buf || '"'; END IF;
          i := i + 1;
        ELSE
          in_quotes := NOT in_quotes;
        END IF;

      ELSIF ch = ',' AND NOT in_quotes THEN
        push_col;

      ELSE
        IF LENGTH(buf) < 32767 THEN buf := buf || ch; END IF;
      END IF;

      i := i + 1;
    END LOOP;

    push_col;
  END;

  FUNCTION col(p_cols IN t_cols, p_pos IN PLS_INTEGER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_cols.EXISTS(p_pos) THEN p_cols(p_pos) ELSE NULL END;
  END;

BEGIN
  DBMS_OUTPUT.PUT_LINE('Leyendo OPERA_DIR/puesto.csv ...');

  v_file := UTL_FILE.FOPEN('OPERA_DIR', 'puesto.csv', 'R', 32767);

  for i in 1 .. 5 loop
    BEGIN
      UTL_FILE.GET_LINE(v_file, v_line);
      v_line_no := v_line_no + 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        EXIT;
    END;

    -- si tu CSV tiene header, deja esto. Si NO tiene header, comenta este bloque.
    IF v_is_first_line THEN
      v_is_first_line := FALSE;
      CONTINUE;
    END IF;

    parse_csv_line(v_line, v_cols);

    v_clave       := col(v_cols, 1);
    v_descripcion := col(v_cols, 2);
    v_nombre      := col(v_cols, 3);

    DBMS_OUTPUT.PUT_LINE(
    'L'||v_line_no||
    ' clave="'||NVL(v_clave,'<NULL>')||'"'||
    ' desc="'||SUBSTR(NVL(v_descripcion,'<NULL>'),1,60)||'"'||
    ' nom="'||SUBSTR(NVL(v_nombre,'<NULL>'),1,60)||'"'
    );

    INSERT INTO puesto (clave, descripcion, nombre)
    VALUES (
    SUBSTR(TRIM(v_clave), 1, 5),
    SUBSTR(TRIM(v_descripcion), 1, 200),
    SUBSTR(TRIM(v_nombre), 1, 40)
    );

  end loop;

  UTL_FILE.FCLOSE(v_file);
  COMMIT;

  DBMS_OUTPUT.PUT_LINE('Carga puestos OK.');

EXCEPTION
  WHEN OTHERS THEN
    IF UTL_FILE.IS_OPEN(v_file) THEN
      UTL_FILE.FCLOSE(v_file);
    END IF;
    ROLLBACK;
    -- Esto te imprime exactamente el backtrace (no agrega funcionalidad, solo diagnóstico)
    DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    RAISE;
END;
/

SET SERVEROUTPUT ON
BEGIN
  carga_puestos;
END;
/

