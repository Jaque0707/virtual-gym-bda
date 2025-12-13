connect opera_admin/opera_admin@pf_operacion

create or replace procedure carga_sensores is
  v_file          UTL_FILE.FILE_TYPE;
  v_line          VARCHAR2(32767);
  v_line_no       PLS_INTEGER := 0;
  v_is_first_line BOOLEAN := TRUE;

  -- columnas
  v_numero_serie  VARCHAR2(20);
  v_fecha_txt     VARCHAR2(20);
  v_marca         VARCHAR2(40);
  v_cliente_txt   VARCHAR2(30);

  TYPE t_cols IS TABLE OF VARCHAR2(32767) INDEX BY PLS_INTEGER;
  v_cols t_cols;

  -- Parser CSV: respeta comillas, "" escapadas, y conserva vacíos (,, => NULL)
  PROCEDURE parse_csv_line(p_line IN VARCHAR2, p_cols OUT t_cols) IS
    i         PLS_INTEGER := 1;
    col_idx   PLS_INTEGER := 1;
    ch        CHAR(1);
    in_quotes BOOLEAN := FALSE;
    buf       VARCHAR2(32767) := '';
    len       PLS_INTEGER := NVL(LENGTH(p_line), 0);

    PROCEDURE push_col IS
    BEGIN
      p_cols(col_idx) := NULLIF(buf, ''); -- convierte vacío a NULL
      col_idx := col_idx + 1;
      buf := '';
    END;
  BEGIN
    p_cols.DELETE;

    WHILE i <= len LOOP
      ch := SUBSTR(p_line, i, 1);

      IF ch = '"' THEN
        -- "" dentro de comillas = comilla literal
        IF in_quotes AND i < len AND SUBSTR(p_line, i+1, 1) = '"' THEN
          buf := buf || '"';
          i := i + 1;
        ELSE
          in_quotes := NOT in_quotes;
        END IF;

      ELSIF ch = ',' AND NOT in_quotes THEN
        push_col;
      ELSE
        buf := buf || ch;
      END IF;

      i := i + 1;
    END LOOP;

    push_col; -- última columna
  END;

  FUNCTION col(p_cols IN t_cols, p_pos IN PLS_INTEGER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_cols.EXISTS(p_pos) THEN p_cols(p_pos) ELSE NULL END;
  END;

BEGIN
  DBMS_OUTPUT.PUT_LINE('Leyendo OPERA_DIR/sensor.csv ...');

  v_file := UTL_FILE.FOPEN('OPERA_DIR', 'sensor.csv', 'R', 32767);

  for i in 1 .. 101 loop
    BEGIN
      UTL_FILE.GET_LINE(v_file, v_line);
      v_line_no := v_line_no + 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        EXIT;
    END;

    -- Si tu sensor.csv NO tiene encabezado, comenta este bloque
    IF v_is_first_line THEN
      v_is_first_line := FALSE;
      CONTINUE;
    END IF;

    parse_csv_line(v_line, v_cols);

    v_numero_serie := col(v_cols, 1);
    v_fecha_txt    := col(v_cols, 2);
    v_marca        := col(v_cols, 3);
    v_cliente_txt  := col(v_cols, 4);

    BEGIN
      INSERT INTO sensor (numero_serie, fecha_compra, marca, cliente_id)
      VALUES (
        v_numero_serie,
        TO_DATE(TRIM(v_fecha_txt), 'DD/MM/YYYY'),
        v_marca,
        TO_NUMBER(TRIM(v_cliente_txt))
      );
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR en línea #'||v_line_no||
                             ' fecha_txt="'||v_fecha_txt||'" cliente_txt="'||v_cliente_txt||'"');
        DBMS_OUTPUT.PUT_LINE('LINEA: '||SUBSTR(v_line, 1, 300));
        RAISE;
    END;
  end loop;

  UTL_FILE.FCLOSE(v_file);
  COMMIT;

  DBMS_OUTPUT.PUT_LINE('Carga sensores OK.');

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
  carga_sensores;
END;
/

