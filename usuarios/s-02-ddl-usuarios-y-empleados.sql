--------------------------------------------------------
--  TABLAS BASE
--------------------------------------------------------

CREATE TABLE cliente (
  cliente_id        NUMBER(12) GENERATED ALWAYS AS IDENTITY,
  nombre            VARCHAR2(40)  NOT NULL,
  apellido_paterno  VARCHAR2(40)  NOT NULL,
  apellido_materno  VARCHAR2(40),
  email             VARCHAR2(200) NOT NULL,
  username          VARCHAR2(40)  NOT NULL,
  password          VARCHAR2(40)  NOT NULL,
  direccion         VARCHAR2(200) NOT NULL,
  fecha_nacimiento  DATE          NOT NULL,
  curp              VARCHAR2(20)  NOT NULL,
  foto              BLOB          NOT NULL,
  
  CONSTRAINT cliente_fecha_nacimiento_chk,
    CHECK (fecha_nacimiento <= SYSDATE),
  CONSTRAINT cliente_email_uk unique(email)
    USING INDEX
      TABLESPACE clientes_c1_data_ts ,
  CONSTRAINT cliente_curp_uk unique(curp)
    USING INDEX
      TABLESPACE clientes_c1_data_ts ,
  CONSTRAINT cliente_username_uk unique(username)
    USING INDEX
      TABLESPACE clientes_c1_data_ts , 
  CONSTRAINT pk_cliente PRIMARY KEY (cliente_id)
    USING INDEX
      TABLESPACE clientes_c1_data_ts              -- índice de la PK en el TS de datos
)
TABLESPACE clientes_c1_data_ts                    -- filas de la tabla
LOB (foto) STORE AS SECUREFILE 
  cliente_foto_lob (
    TABLESPACE usuarios_c2_lob_ts                    -- segmento LOB de la foto
      INDEX cliente_foto_lob_ix
        TABLESPACE clientes_c1_data_ts              -- índice del LOB
);

CREATE TABLE puesto (
  puesto_id   NUMBER(12) GENERATED ALWAYS AS IDENTITY,
  clave       VARCHAR2(5)    NOT NULL,
  descripcion VARCHAR2(200)  NOT NULL,
  nombre      VARCHAR2(40)   NOT NULL,
  CONSTRAINT pk_puesto PRIMARY KEY (puesto_id)
    USING INDEX
      TABLESPACE operacion_c1_data_ts,  
  CONSTRAINT puesto_clave_uk unique(clave)
    USING INDEX
      TABLESPACE operacion_c1_data_ts 
)
TABLESPACE operacion_c1_data_ts; 

CREATE TABLE empleado (
  empleado_id      NUMBER(12) GENERATED ALWAYS AS IDENTITY,
  nombre           VARCHAR2(40)  NOT NULL,
  apellido_paterno VARCHAR2(40)  NOT NULL,
  apellido_materno VARCHAR2(40),
  curp             VARCHAR2(20)  NOT NULL,
  rfc              VARCHAR2(20)  NOT NULL,
  fecha_nacimiento DATE          NOT NULL,
  email            VARCHAR2(200) NOT NULL,
  foto             BLOB          NOT NULL,
  tipo_empleado    CHAR(1)  NOT NULL,
  puesto_id        NUMBER(12)   NOT NULL,
  CONSTRAINT pk_empleado PRIMARY KEY (empleado_id),
  CONSTRAINT empleado_fecha_nacimiento_chk
    CHECK (fecha_nacimiento <= SYSDATE),
  -- Instructor (I) / Administrativo (A)
  CONSTRAINT empleado_tipo_empleado_chk
    CHECK (tipo_empleado IN ('I','A')),
  CONSTRAINT empleado_curp_uk unique(curp)
    USING INDEX
      TABLESPACE operacion_c1_data_ts, 
  CONSTRAINT empleado_rfc_uk unique(rfc)
    USING INDEX
      TABLESPACE operacion_c1_data_ts,
  CONSTRAINT empleado_email_uk unique(email)
    USING INDEX
      TABLESPACE operacion_c1_data_ts            
)
TABLESPACE operacion_c1_data_ts                     
LOB (foto) STORE AS SECUREFILE 
  empleado_foto_lob (
    TABLESPACE usuarios_c2_lob_ts                   
    INDEX empleado_foto_lob_ix
      TABLESPACE operacion_c1_data_ts              
);

CREATE TABLE sensor (
  sensor_id     NUMBER(12) GENERATED ALWAYS AS IDENTITY,
  numero_serie  VARCHAR2(20)  NOT NULL,
  fecha_compra  DATE          NOT NULL,
  marca         VARCHAR2(40)  NOT NULL,
  cliente_id    NUMBER(12)  NOT NULL,
  CONSTRAINT pk_sensor PRIMARY KEY (sensor_id)
    USING INDEX
      TABLESPACE cliente_c1_data_ts ,
  CONSTRAINT sensor_fecha_compra_chk
    CHECK (fecha_compra <= SYSDATE),
  CONSTRAINT sensor_numero_serie_uk unique(numero_serie)
    USING INDEX
      TABLESPACE cliente_c1_data_ts            
)
TABLESPACE cliente_c1_data_ts; 

CREATE TABLE sesion (
  sesion_id                NUMBER(12)   GENERATED ALWAYS AS IDENTITY,
  folio                    NUMBER(12)  NOT NULL,
  cliente_id               NUMBER(12)   NOT NULL,
  duracion_minutos         NUMBER(5,2)  NOT NULL,
  fecha_inicio             DATE         NOT NULL,
  sala_id_rid              NUMBER(12)   NOT NULL,
  empleado_instructor_id   NUMBER(12)   NOT NULL,
  CONSTRAINT pk_sesion PRIMARY KEY (sesion_id)
    USING INDEX
      TABLESPACE operacion_c1_data_ts,
  CONSTRAINT sesion_folio_chk
    CHECK (folio > 0),
  CONSTRAINT sesion_duracion_minutos_chk
    CHECK (duracion_minutos > 0),
  CONSTRAINT sesion_fecha_inicio_chk
    CHECK (fecha_inicio <= SYSDATE),
  CONSTRAINT sesion_folio_uk unique(folio); 
    USING INDEX
      TABLESPACE operacion_c1_data_ts            
)
TABLESPACE operacion_c1_data_ts;   

CREATE TABLE bitacora (
  bitacora_id NUMBER(12) GENERATED ALWAYS AS IDENTITY,
  calorias    NUMBER(10,2) NOT NULL,
  minuto      NUMBER(3),
  sesion_id   NUMBER(12) NOT NULL,
  CONSTRAINT pk_bitacora PRIMARY KEY (bitacora_id)
    USING INDEX
      TABLESPACE operacion_c1_data_ts            
)
TABLESPACE operacion_c1_data_ts;

CREATE TABLE credencial (
  credencial_id    NUMBER(12)    GENERATED ALWAYS AS IDENTITY,
  folio            VARCHAR2(20)  NOT NULL,
  fecha_expedicion DATE          DEFAULT SYSDATE NOT NULL,
  vigencia         DATE          NOT NULL,
  codigo_barras    VARCHAR2(20),
  cliente_id       NUMBER(12)    NOT NULL,
  CONSTRAINT pk_credencial PRIMARY KEY (credencial_id)
    USING INDEX
      TABLESPACE cliente_c1_data_ts,
  CONSTRAINT credencial_folio_uk unique(folio),
  CONSTRAINT credencial_codigo_barras_uk unique(codigo_barras)
    USING INDEX
      TABLESPACE cliente_c1_data_ts            
)
TABLESPACE cleinte_c1_data_ts;  

CREATE TABLE huella_dactilar (
  huella_id       NUMBER(12) GENERATED ALWAYS AS IDENTITY,
  empleado_id     NUMBER(12)  NOT NULL,
  num_dedo        NUMBER(12)  NOT NULL,
  huella_dactilar BLOB         NOT NULL,
  CONSTRAINT pk_huella_dactilar PRIMARY KEY (huella_id)
    USING INDEX
      TABLESPACE operacion_c1_data_ts,
  CONSTRAINT huella_dactilar_num_dedo_chk
    CHECK (num_dedo BETWEEN 1 AND 12)
)
TABLESPACE operacion_c1_data_ts
LOB (huella_dactilar) STORE AS SECUREFILE huella_dactilar_lob (
  TABLESPACE sensibles_c2_lob_ts       
  INDEX huella_dactilar_lob_ix
    TABLESPACE operacion_c1_data_ts
);

CREATE TABLE instructor (
  empleado_id        NUMBER(12)  NOT NULL,
  suplente_id        NUMBER(12)  NOT NULL,
  cedula_profesional VARCHAR2(20)  NOT NULL,
  anios_experiencia  NUMBER(2)  NOT NULL,
  url_trayectoria    VARCHAR2(500),
  CONSTRAINT pk_instructor PRIMARY KEY (empleado_id)
    USING INDEX
      TABLESPACE operacion_c1_data_ts,
  CONSTRAINT instructor_cedula_profesional_uk unique(cedula_profesional)  
    USING INDEX
      TABLESPACE operacion_c1_data_ts            
)
TABLESPACE operacion_c1_data_ts;

CREATE TABLE administrativo (
  empleado_id       NUMBER(12)  NOT NULL,
  username          VARCHAR2(40) NOT NULL,
  password          VARCHAR2(40) NOT NULL,
  descripcion_rol   VARCHAR2(200) NOT NULL,
  certificado_digital BLOB       NOT NULL,
  CONSTRAINT pk_administrativo PRIMARY KEY (empleado_id)
    USING INDEX
      TABLESPACE operacion_c1_data_ts, 
  CONSTRAINT administrativo_username_uk unique(username)
    USING INDEX
      TABLESPACE operacion_c1_data_ts
)
TABLESPACE operacion_c1_data_ts
LOB (certificado_digital) STORE AS SECUREFILE administrativo_cert_lob (
    TABLESPACE sensibles_c2_lob_ts       
    INDEX administrativo_cert_lob_ix
      TABLESPACE operacion_c1_data_ts
);

CREATE TABLE sesion_aparato (
  sesion_aparato_id NUMBER(12) GENERATED ALWAYS AS IDENTITY,
  aparato_id_rid        NUMBER(12) NOT NULL,
  sesion_id         NUMBER(12) NOT NULL,
  CONSTRAINT pk_sesion_aparato PRIMARY KEY (sesion_aparato_id)
    USING INDEX
      TABLESPACE operacion_c1_data_ts            
)
TABLESPACE operacion_c1_data_ts;

CREATE TABLE registro_medidas (
  registro_medidas_id      NUMBER(12) GENERATED ALWAYS AS IDENTITY,
  fecha_registro   DATE         NOT NULL,
  masa_corporal    NUMBER(5,2)  NOT NULL,
  estatura         NUMBER(4,2),
  peso             NUMBER(5,2)  NOT NULL,
  cliente_id       NUMBER(12) NOT NULL,
  CONSTRAINT pk_registro_medidas PRIMARY KEY (registro_medidas_id)
    USING INDEX
      TABLESPACE cliente_c1_data_ts            
)
TABLESPACE cliente_c1_data_ts;
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