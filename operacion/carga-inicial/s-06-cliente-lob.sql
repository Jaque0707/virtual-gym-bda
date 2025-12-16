  
prompt ==> Conectando como opera_admin
connect opera_admin/opera_admin@pf_operacion

-- Procedimiento para cargar fotos de clientes

create or replace procedure carga_img_clientes is 
    v_bfile  bfile;
    v_blob   blob;
    v_foto   varchar2(20);
begin
  for v_id in 1..11 loop
    
    --construye el nombre de la foto
    v_foto := 'img_clientes/' || v_id || '.png';

    -- obtener la referencia al blob locator para actualizarlo. Se requiere
    -- hacer uso de la cláusula select ... for update para bloquear el registro
    -- por unos instantes mientras se realiza la carga del archivo
    select foto
    into v_blob
    from cliente
    where cliente_id = v_id
    for update;
    
    --obtiene referencia al archivo en el s.o. Notar que se hace uso del
    -- objeto directory configurado previamente. Debe especificarse en
    -- mayúsculas. El segundo parámetro es el nombre del archivo

    v_bfile := bfilename('OPERA_DIR', v_foto);
    if dbms_lob.fileexists(v_bfile) = 0 then
        raise_application_error(-20001, 
          'El archivo ' 
          || v_foto 
          || ' no existe'
        );
    end if;

    -- abrir el archivo del s.o para leerlo
    dbms_lob.fileopen(v_bfile, dbms_lob.file_readonly);

    -- lee los bytes del archivo y los escribe en la columna foto para el
    -- id del auto en turno. Notar que para cargar archivos grandes debe 
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
  end loop;
end;
/
show errors
prompt ==> Realizando carga de fotos de clientes
begin
  carga_img_clientes;
end;
/
prompt ==> Carga de fotos de clientes finalizada, confirmando cambios.
commit; 
prompt ==> Total de datos cargados en fotos:
select round(sum(dbms_lob.getlength(foto))/1024/1024,2) as total_mb_fotos
from cliente;
