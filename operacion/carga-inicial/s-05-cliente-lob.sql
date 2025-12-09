CREATE OR REPLACE DIRECTORY CLIENTE_IMG_DIR AS '/unam/bda/virtual-gym-bda/operacion/carga-inicial/img_clientes';

GRANT READ, WRITE ON DIRECTORY CLIENTE_IMG_DIR TO admin_cliente;

create or replace procedure carga_img_cliente is 
  v_bfile    BFILE;
  v_blob     BLOB;
  v_filename VARCHAR2(128);
BEGIN
  -- Recorremos clientes aleatorios que todavía no tienen foto
  FOR v_id in 1...50 loop
    
  -- Nombre de archivo según el índice aleatorio (ajusta al patrón de tus fotos)
    v_filename := v_id || '.jpg';

  -- Obtenemos el BLOB de la fila a actualizar
    SELECT foto
    INTO   v_blob
    FROM   cliente
    WHERE  cliente_id = v_id
    FOR UPDATE;

  -- Localizador al archivo físico
    v_bfile := BFILENAME('CLIENTE_IMG_DIR', v_filename);
    if dbms_lob.fileexists(v_bfile) = 0 then
        raise_application_error(-20001, 
          'El archivo ' 
          || v_foto 
          || ' no existe'
        );
    end if;

    --Abrir el archivo 
    DBMS_LOB.FILEOPEN(v_bfile, DBMS_LOB.FILE_READONLY);

    -- lee los bytes del archivo y los escribe en la columna foto para el
    -- id del foto del cliente en turno. Notar que para cargar archivos grandes debe 
    -- realizarse por partes. Para efectos de esta práctica se asume 
    -- que las fotos son pequeñas y caben en una sola operación.
    dbms_lob.loadfromfile(
        dest_lob => v_blob,
        src_lob  => v_bfile,
        amount   => dbms_lob.getlength(v_bfile)
    );
    --valida longitudes del archivo cargado y el archivo en el s.o.
    if dbms_lob.getlength(v_blob) <> dbms_lob.getlength(v_bfile) then
        raise_application_error(-20002, 
          'Longitudes no coinciden, error al cargar el archivo ' 
          || v_foto
        );
    end if;
    --cerrar el archivo del s.o.
    dbms_lob.fileclose(v_bfile);


  END LOOP;
END;
/
