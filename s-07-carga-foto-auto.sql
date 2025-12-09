
--@Autor:           Jorge Rodriguez
--@Fecha creación:  dd/mm/yyyy
--@Descripción:     
prompt ==> Conectando como jrc_autos
connect jrc_autos/jorge@jrcbda_s2

-- Procedimiento para cargar fotos de autos. Se asume que existen 100 fotos
-- nombradas del 1.jpg al 100.jpg en el directorio configurado en la
-- base de datos como P16_AUTOS_DIR. Se asume que existen 100 registros
-- en la tabla auto con auto_id del 1 al 100.
create or replace procedure carga_img_auto is 
    v_bfile  bfile;
    v_blob   blob;
    v_foto   varchar2(20);
begin
  for v_id in 1..100 loop
    
    --construye el nombre de la foto
    v_foto := v_id || '.jpg';

    -- obtener la referencia al blob locator para actualizarlo. Se requiere
    -- hacer uso de la cláusula select ... for update para bloquear el registro
    -- por unos instantes mientras se realiza la carga del archivo
    select foto
    into v_blob
    from auto
    where auto_id = v_id
    for update;
    
    --obtiene referencia al archivo en el s.o. Notar que se hace uso del
    -- objeto directory configurado previamente. Debe especificarse en
    -- mayúsculas. El segundo parámetro es el nombre del archivo 
    v_bfile := bfilename('P16_AUTOS_DIR', v_foto);
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
prompt ==> Realizando carga de fotos de autos
begin
  carga_img_auto;
end;
/
prompt ==> Carga de fotos de autos finalizada, confirmando cambios.
commit; 
prompt ==> Total de datos cargados en fotos:
select round(sum(dbms_lob.getlength(foto))/1024/1024,2) as total_mb_fotos
from auto;
disconnect 