--TS CLIENTES 

CREATE BIGFILE TABLESPACE clientes_c1_data_ts
    DATAFILE '/unam/bda/pf/c1/d01/clientes_c1_data_ts_01.dbf'
    SIZE 5G
    AUTOEXTEND ON NEXT 500M
    MAXSIZE 20G;

--TS OPERACION 

REATE BIGFILE TABLESPACE operacion_c1_data_ts
    DATAFILE '/unam/bda/pf/c1/d02/operacion_c1_data_ts_01.dbf'
    SIZE 5G
    AUTOEXTEND ON NEXT 500M
    MAXSIZE 20G;
    
CREATE BIGFILE TABLESPACE sensibles_c2_lob_ts
    DATAFILE '/unam/bda/pf/c2/d02/sensibles_c2_lob_ts_01.dbf'
    SIZE 10G
    AUTOEXTEND ON NEXT 1G
    MAXSIZE 50G;


CREATE BIGFILE TABLESPACE operacion_c2_lob_ts
    DATAFILE '/unam/bda/pf/c2/d01/operacion_c2_lob_ts_01.dbf'
    SIZE 10G
    AUTOEXTEND ON NEXT 1G
    MAXSIZE 50G;
