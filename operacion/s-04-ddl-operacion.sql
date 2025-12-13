
connect opera_admin/opera_admin@pf_operacion 


-- Operación
DROP TABLE IF EXISTS SESION_APARATO;
DROP TABLE IF EXISTS BITACORA;
DROP TABLE IF EXISTS SESION;

-- Empleado
DROP TABLE IF EXISTS HUELLA_DACTILAR;
DROP TABLE IF EXISTS ADMINISTRATIVO;
DROP TABLE IF EXISTS INSTRUCTOR;
DROP TABLE IF EXISTS EMPLEADO;
DROP TABLE IF EXISTS PUESTO;

-- Cliente
DROP TABLE IF EXISTS REGISTRO_MEDIDAS;
DROP TABLE IF EXISTS CREDENCIAL;
DROP TABLE IF EXISTS SENSOR;
DROP TABLE IF EXISTS CLIENTE;


DROP TABLE IF EXISTS sesion_folio_cliente; 


----------------------------------------------------------------------------------
-- CLIENTES
----------------------------------------------------------------------------------

CREATE TABLE CLIENTE (
  CLIENTE_ID        NUMBER(12) GENERATED ALWAYS AS IDENTITY,
  NOMBRE            VARCHAR2(40)  NOT NULL,
  APELLIDO_PATERNO  VARCHAR2(40)  NOT NULL,
  APELLIDO_MATERNO  VARCHAR2(40),
  EMAIL             VARCHAR2(200) NOT NULL,
  USERNAME          VARCHAR2(40)  NOT NULL,
  PASSWORD          VARCHAR2(40)  NOT NULL,
  DIRECCION         VARCHAR2(200) NOT NULL,
  FECHA_NACIMIENTO  DATE          NOT NULL,
  CURP              VARCHAR2(20)  NOT NULL,
  FOTO              BLOB          NOT NULL,
  CONSTRAINT CLIENTE_EMAIL_UK UNIQUE (EMAIL)
    USING INDEX TABLESPACE cliente_c1_data_ts,
  CONSTRAINT CLIENTE_CURP_UK UNIQUE (CURP)
    USING INDEX TABLESPACE cliente_c1_data_ts,
  CONSTRAINT CLIENTE_USERNAME_UK UNIQUE (USERNAME)
    USING INDEX TABLESPACE cliente_c1_data_ts,
  CONSTRAINT PK_CLIENTE PRIMARY KEY (CLIENTE_ID)
    USING INDEX TABLESPACE cliente_c1_data_ts
)
TABLESPACE cliente_c1_data_ts
LOB (FOTO) STORE AS SECUREFILE 
CLIENTE_FOTO_LOB (
  TABLESPACE cliente_c2_lob_ts
  INDEX cliente_foto_lob_idx (TABLESPACE cliente_c1_data_ts)
);


CREATE TABLE SENSOR (
  SENSOR_ID     NUMBER(12) GENERATED ALWAYS AS IDENTITY,
  NUMERO_SERIE  VARCHAR2(20)  NOT NULL,
  FECHA_COMPRA  DATE          NOT NULL,
  MARCA         VARCHAR2(40)  NOT NULL,
  CLIENTE_ID    NUMBER(12)  NOT NULL,
  CONSTRAINT PK_SENSOR PRIMARY KEY (SENSOR_ID)
    USING INDEX
      TABLESPACE cliente_c1_data_ts,
  CONSTRAINT SENSOR_CLIENTE_ID_UK UNIQUE(CLIENTE_ID)
    USING INDEX
      TABLESPACE cliente_c1_data_ts,
  CONSTRAINT SENSOR_NUMERO_SERIE_UK UNIQUE(NUMERO_SERIE)
    USING INDEX
      TABLESPACE cliente_c1_data_ts            
)
TABLESPACE cliente_c1_data_ts;

CREATE TABLE CREDENCIAL (
  CREDENCIAL_ID    NUMBER(12)    GENERATED ALWAYS AS IDENTITY,
  FOLIO            VARCHAR2(20)  NOT NULL,
  FECHA_EXPEDICION DATE          DEFAULT SYSDATE NOT NULL,
  VIGENCIA         DATE          NOT NULL,
  CODIGO_BARRAS    VARCHAR2(20),
  CLIENTE_ID       NUMBER(12)    NOT NULL,
  CONSTRAINT PK_CREDENCIAL PRIMARY KEY (CREDENCIAL_ID)
    USING INDEX
      TABLESPACE cliente_c1_data_ts,
  CONSTRAINT CREDENCIAL_FOLIO_UK UNIQUE(FOLIO)
    USING INDEX
      TABLESPACE cliente_c1_data_ts,
  CONSTRAINT CREDENCIAL_CODIGO_BARRAS_UK UNIQUE(CODIGO_BARRAS)
    USING INDEX
      TABLESPACE cliente_c1_data_ts            
)
TABLESPACE cliente_c1_data_ts; 

CREATE TABLE REGISTRO_MEDIDAS (
  REGISTRO_MEDIDAS_ID      NUMBER(12) GENERATED ALWAYS AS IDENTITY,
  FECHA_REGISTRO   DATE         NOT NULL,
  MASA_CORPORAL    NUMBER(5,2)  NOT NULL,
  ESTATURA         NUMBER(4,2),
  PESO             NUMBER(5,2)  NOT NULL,
  CLIENTE_ID       NUMBER(12) NOT NULL,
  CONSTRAINT PK_REGISTRO_MEDIDAS PRIMARY KEY (REGISTRO_MEDIDAS_ID)
    USING INDEX
      TABLESPACE cliente_c1_data_ts            
)
TABLESPACE cliente_c1_data_ts;

----------------------------------------------------------------------------------
-- EMPLEADOS
----------------------------------------------------------------------------------

CREATE TABLE PUESTO (
  PUESTO_ID   NUMBER(12) GENERATED ALWAYS AS IDENTITY,
  CLAVE       VARCHAR2(5)    NOT NULL,
  DESCRIPCION VARCHAR2(200)  NOT NULL,
  NOMBRE      VARCHAR2(40)   NOT NULL,
  CONSTRAINT PK_PUESTO PRIMARY KEY (PUESTO_ID)
    USING INDEX
      TABLESPACE empleado_c1_data_ts,  
  CONSTRAINT PUESTO_CLAVE_UK UNIQUE(CLAVE)
    USING INDEX
      TABLESPACE empleado_c1_data_ts 
)
TABLESPACE empleado_c1_data_ts; 

CREATE TABLE EMPLEADO (
  EMPLEADO_ID      NUMBER(12) GENERATED ALWAYS AS IDENTITY,
  NOMBRE           VARCHAR2(40)  NOT NULL,
  APELLIDO_PATERNO VARCHAR2(40)  NOT NULL,
  APELLIDO_MATERNO VARCHAR2(40),
  CURP             VARCHAR2(20)  NOT NULL,
  RFC              VARCHAR2(20)  NOT NULL,
  FECHA_NACIMIENTO DATE          NOT NULL,
  EMAIL            VARCHAR2(200) NOT NULL,
  FOTO             BLOB          NOT NULL,
  TIPO_EMPLEADO    CHAR(1)  NOT NULL,
  PUESTO_ID        NUMBER(12)   NOT NULL,
  CONSTRAINT PK_EMPLEADO PRIMARY KEY (EMPLEADO_ID)
    USING INDEX
      TABLESPACE empleado_c1_data_ts,
  -- Instructor (I) / Administrativo (A)
  CONSTRAINT EMPLEADO_TIPO_EMPLEADO_CHK
    CHECK (TIPO_EMPLEADO IN ('I','A')),
  CONSTRAINT EMPLEADO_CURP_UK UNIQUE(CURP)
    USING INDEX
      TABLESPACE empleado_c1_data_ts, 
  CONSTRAINT EMPLEADO_RFC_UK UNIQUE(RFC)
    USING INDEX
      TABLESPACE empleado_c1_data_ts,
  CONSTRAINT EMPLEADO_EMAIL_UK UNIQUE(EMAIL)
    USING INDEX
      TABLESPACE empleado_c1_data_ts            
)
TABLESPACE empleado_c1_data_ts                     
LOB (FOTO) STORE AS SECUREFILE 
EMPLEADO_FOTO_LOB (
  TABLESPACE empleado_c2_lob_ts                   
  INDEX EMPLEADO_FOTO_LOB_IX (TABLESPACE empleado_c1_data_ts)             
);

CREATE TABLE INSTRUCTOR (
  EMPLEADO_ID        NUMBER(12)  NOT NULL,
  SUPLENTE_ID        NUMBER(12)  NOT NULL,
  CEDULA_PROFESIONAL VARCHAR2(20)  NOT NULL,
  ANIOS_EXPERIENCIA  NUMBER(2)  NOT NULL,
  URL_TRAYECTORIA    VARCHAR2(500),
  CONSTRAINT PK_INSTRUCTOR PRIMARY KEY (EMPLEADO_ID)
    USING INDEX
      TABLESPACE empleado_c1_data_ts,
  CONSTRAINT INSTRUCTOR_CEDULA_PROFESIONAL_UK UNIQUE(CEDULA_PROFESIONAL)  
    USING INDEX
      TABLESPACE empleado_c1_data_ts            
)
TABLESPACE empleado_c1_data_ts;

CREATE TABLE ADMINISTRATIVO (
  EMPLEADO_ID       NUMBER(12)  NOT NULL,
  USERNAME          VARCHAR2(40) NOT NULL,
  PASSWORD          VARCHAR2(40) NOT NULL,
  DESCRIPCION_ROL   VARCHAR2(200) NOT NULL,
  CERTIFICADO_DIGITAL BLOB       NOT NULL,
  CONSTRAINT PK_ADMINISTRATIVO PRIMARY KEY (EMPLEADO_ID)
    USING INDEX
      TABLESPACE empleado_c1_data_ts, 
  CONSTRAINT ADMINISTRATIVO_USERNAME_UK UNIQUE(USERNAME)
    USING INDEX
      TABLESPACE empleado_c1_data_ts
)
TABLESPACE empleado_c1_data_ts
LOB (CERTIFICADO_DIGITAL) STORE AS SECUREFILE 
ADMINISTRATIVO_CERT_LOB (
  TABLESPACE empleado_c2_lob_ts       
  INDEX ADMINISTRATIVO_CERT_LOB_IX (TABLESPACE empleado_c1_data_ts)
);

CREATE TABLE HUELLA_DACTILAR (
  HUELLA_ID       NUMBER(12) GENERATED ALWAYS AS IDENTITY,
  EMPLEADO_ID     NUMBER(12)  NOT NULL,
  NUM_DEDO        NUMBER(12)  NOT NULL,
  HUELLA_DACTILAR BLOB         NOT NULL,
  CONSTRAINT PK_HUELLA_DACTILAR PRIMARY KEY (HUELLA_ID)
    USING INDEX
      TABLESPACE empleado_c1_data_ts,
  CONSTRAINT HUELLA_DACTILAR_NUM_DEDO_CHK
    CHECK (NUM_DEDO BETWEEN 1 AND 12)
)
TABLESPACE empleado_c1_data_ts
LOB (HUELLA_DACTILAR) STORE AS SECUREFILE 
HUELLA_DACTILAR_LOB (
  TABLESPACE empleado_c2_lob_ts       
  INDEX HUELLA_DACTILAR_LOB_IX (TABLESPACE empleado_c1_data_ts)
);

----------------------------------------------------------------------------------
-- OPERACION
----------------------------------------------------------------------------------

CREATE TABLE SESION (
  SESION_ID                NUMBER(12)   GENERATED ALWAYS AS IDENTITY,
  FOLIO                    NUMBER(12)  NOT NULL,
  CLIENTE_ID               NUMBER(12)   NOT NULL,
  DURACION_MINUTOS         NUMBER(5,2)  NOT NULL,
  FECHA_INICIO             DATE         NOT NULL,
  SALA_ID_RID              NUMBER(12)   NOT NULL,
  EMPLEADO_INSTRUCTOR_ID   NUMBER(12)   NOT NULL,
  CONSTRAINT PK_SESION PRIMARY KEY (SESION_ID)
    USING INDEX
      TABLESPACE operacion_c1_data_ts,
  CONSTRAINT SESION_FOLIO_CHK
    CHECK (FOLIO > 0),
  CONSTRAINT SESION_DURACION_MINUTOS_CHK
    CHECK (DURACION_MINUTOS > 0),
  CONSTRAINT SESION_FOLIO_CLIENTE_UK UNIQUE(FOLIO,CLIENTE_ID)
    USING INDEX
      TABLESPACE operacion_c1_data_ts            
)
TABLESPACE operacion_c1_data_ts;   

CREATE TABLE BITACORA (
  BITACORA_ID NUMBER(12) GENERATED ALWAYS AS IDENTITY,
  CALORIAS    NUMBER(10,2) NOT NULL,
  MINUTO      NUMBER(3),
  SESION_ID   NUMBER(12) NOT NULL,
  CONSTRAINT PK_BITACORA PRIMARY KEY (BITACORA_ID)
    USING INDEX
      TABLESPACE operacion_c1_data_ts            
)
TABLESPACE operacion_c1_data_ts;


CREATE TABLE SESION_APARATO (
  SESION_APARATO_ID NUMBER(12) GENERATED ALWAYS AS IDENTITY,
  APARATO_ID_RID        NUMBER(12) NOT NULL,
  SESION_ID         NUMBER(12) NOT NULL,
  CONSTRAINT PK_SESION_APARATO PRIMARY KEY (SESION_APARATO_ID)
    USING INDEX
      TABLESPACE operacion_c1_data_ts            
)
TABLESPACE operacion_c1_data_ts;

--------------------------------------------------------
--  FOREIGN KEYS
--------------------------------------------------------

ALTER TABLE sensor
  ADD CONSTRAINT fk_sensor_cliente
  FOREIGN KEY (cliente_id)
  REFERENCES cliente (cliente_id);

ALTER TABLE sesion
  ADD CONSTRAINT fk_sesion_cliente
  FOREIGN KEY (cliente_id)
  REFERENCES cliente (cliente_id);

-- si quieres que apunte específicamente al sub-tipo INSTRUCTOR:
ALTER TABLE sesion
  ADD CONSTRAINT fk_sesion_instructor
  FOREIGN KEY (empleado_instructor_id)
  REFERENCES instructor (empleado_id);

ALTER TABLE bitacora
  ADD CONSTRAINT fk_bitacora_sesion
  FOREIGN KEY (sesion_id)
  REFERENCES sesion (sesion_id);

ALTER TABLE credencial
  ADD CONSTRAINT fk_credencial_cliente
  FOREIGN KEY (cliente_id)
  REFERENCES cliente (cliente_id);

ALTER TABLE empleado
  ADD CONSTRAINT fk_empleado_puesto
  FOREIGN KEY (puesto_id)
  REFERENCES puesto (puesto_id);

ALTER TABLE huella_dactilar
  ADD CONSTRAINT fk_huella_empleado
  FOREIGN KEY (empleado_id)
  REFERENCES empleado (empleado_id);

ALTER TABLE instructor
  ADD CONSTRAINT fk_instr_empleado
  FOREIGN KEY (empleado_id)
  REFERENCES empleado (empleado_id);

ALTER TABLE instructor
  ADD CONSTRAINT fk_instr_suplente
  FOREIGN KEY (suplente_id)
  REFERENCES empleado (empleado_id);

ALTER TABLE administrativo
  ADD CONSTRAINT fk_admin_empleado
  FOREIGN KEY (empleado_id)
  REFERENCES empleado (empleado_id);

ALTER TABLE sesion_aparato
  ADD CONSTRAINT fk_sesaparato_sesion
  FOREIGN KEY (sesion_id)
  REFERENCES sesion (sesion_id);

ALTER TABLE registro_medidas
  ADD CONSTRAINT fk_regmed_cliente
  FOREIGN KEY (cliente_id)
  REFERENCES cliente (cliente_id);

-- Se rquieren las tablas SALA y APARATO que se encuentran eb el otro modulo
-- ALTER TABLE sesion
--   ADD CONSTRAINT fk_sesion_sala
--   FOREIGN KEY (sala_id)
--   REFERENCES sala (sala_id);
--
-- ALTER TABLE sesion_aparato
--   ADD CONSTRAINT fk_sesaparato_aparato
--   FOREIGN KEY (aparato_id)
--   REFERENCES aparato (aparato_id);


CREATE TABLE sesion_folio_cliente (
  cliente_id   NUMBER(12) NOT NULL,
  ultimo_folio NUMBER(12) NOT NULL,
  CONSTRAINT pk_sesion_folio_cliente PRIMARY KEY (cliente_id)
);


---Triggers 
CREATE OR REPLACE TRIGGER trg_sesion_folio
BEFORE INSERT ON sesion
FOR EACH ROW
DECLARE
  v_nuevo_folio NUMBER(12);
BEGIN
  UPDATE sesion_folio_cliente
  SET ultimo_folio = ultimo_folio + 1
  WHERE cliente_id = :NEW.cliente_id;

  IF SQL%ROWCOUNT = 0 THEN
    v_nuevo_folio := 1;
    INSERT INTO sesion_folio_cliente (cliente_id, ultimo_folio)
    VALUES (:NEW.cliente_id, v_nuevo_folio);
  ELSE
    SELECT ultimo_folio
    INTO v_nuevo_folio
    FROM sesion_folio_cliente
    WHERE cliente_id = :NEW.cliente_id;
  END IF;

  :NEW.folio := v_nuevo_folio;
END;
/
SHOW ERRORS TRIGGER trg_sesion_folio

