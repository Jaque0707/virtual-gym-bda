-- Inserta en la tabla aparato
create or replace procedure carga_aparato is 
  v_file   UTL_FILE.FILE_TYPE;
  v_line   VARCHAR2(32767);
  v_is_first_line BOOLEAN := TRUE;

  -- columnas
  v_1  VARCHAR2(40);
  v_2  VARCHAR2(40);
  v_3  VARCHAR2(40);
  v_4  VARCHAR2(40);
  v_5  VARCHAR2(200);
  v_6  VARCHAR2(40);
  v_7  VARCHAR2(40);
  v_8  VARCHAR2(20);

  v_rows number;          
  v_query varchar2(100); 


  -- función auxiliar: obtiene la n-ésima columna separada por coma
  function get_col(p_line in VARCHAR2, p_pos in PLS_INTEGER)
    return VARCHAR2
  is
  begin
    return REGEXP_SUBSTR(p_line, '[^,]+', 1, p_pos);
  end;
  --p_line: Linea completa del CSV 
  --p_pos: numero, indica que solumna se quiere 
  -- REGEXP, busca en p_line, todos los caracteres antes de la coma, p_pos indica el no de concidencia

begin
  -- 1. Iniciamos las variables 
    v_rows := 56;    
    v_query :='insert into aparato(NUMERO_INVENTARIO,NOMBRE,FECHA_ADQUISICION,FECHA_STATUS,DESCRIPCION,SALA_ID,TIPO_APARATO_ID,STATUS_APARATO_ID) values (:ph1,:ph2,:ph3,:ph4,:ph5,:ph6,:ph7,:ph8)';

  -- 1. Abre el archvio en modo leectura 
  v_file := UTL_FILE.FOPEN('INFRA_DIR', 'aparato.csv', 'R', 32767);

  loop
    begin
  --2. Lee cada linea del CVS
      UTL_FILE.GET_LINE(v_file, v_line);
    exeption
      when NO_DATA_FOUND then
        EXIT;
    END;

  -- 3. Saltar encabezado (primera línea)
    if v_is_first_line then
      v_is_first_line := FALSE;
      continue;
    end if;

    --4. Extraer los valores de cada columna haciendo uso de la función auxiliar
    v_1  := get_col(v_line, 1);
    v_2  := get_col(v_line, 2);
    v_3  := get_col(v_line, 3);
    v_4  := get_col(v_line, 4);
    v_5  := get_col(v_line, 5);
    v_6  := get_col(v_line, 6);
    v_7  := get_col(v_line, 7);
    v_8  := get_col(v_line, 8);

    --5. Realizar las inserciones                                                  
    execute immediate v_query                     
    using v_1, v_2, v_3,v_4,v_5,v_6,v_7,v_8 

  end loop;
  UTL_FILE.FCLOSE(v_file);
END;
/

begin
  carga_aparato;
end;
/