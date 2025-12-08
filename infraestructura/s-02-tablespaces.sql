--@Autor: Benítez Pérez Michelle Paulina
--        Hernández García Pilar Jaqueline
--@Fecha creación: 08/12/2025
--@Descripción: 

-- 1. Tablespace para Datos (Capa 1 - Alto Desempeño)
-- Asignación propuesta: 10 GB
CREATE TABLESPACE infraestr_c1_data_ts
  DATAFILE '/unam/bda/pf/c1/d01/infraestr_c1_data_ts_01.dbf'
  SIZE 100M
  AUTOEXTEND ON NEXT 50M MAXSIZE 10G
  EXTENT MANAGEMENT LOCAL AUTOALLOCATE
  SEGMENT SPACE MANAGEMENT AUTO;

-- 2. Tablespace para Índices (Capa 1 - Alto Desempeño)
-- Asignación propuesta: 5 GB 
CREATE TABLESPACE infraestr_c1_ix_ts
  DATAFILE '/unam/bda/pf/c1/d02/infraestr_c1_ix_ts_01.dbf'
  SIZE 100M
  AUTOEXTEND ON NEXT 50M MAXSIZE 5G
  EXTENT MANAGEMENT LOCAL AUTOALLOCATE
  SEGMENT SPACE MANAGEMENT AUTO;

-- 3. Tablespace para objetos LOB (Capa 2 - Costo Medio/Almacenamiento Masivo)
-- Asignación propuesta: 10 GB (Los LOBs suelen consumir mucho espacio)
CREATE TABLESPACE infraestr_c2_lob_ts
  DATAFILE '/unam/bda/pf/c2/d01/infraestr_c2_lob_ts_01.dbf'
  SIZE 100M
  AUTOEXTEND ON NEXT 100M MAXSIZE 10G
  EXTENT MANAGEMENT LOCAL AUTOALLOCATE
  SEGMENT SPACE MANAGEMENT AUTO;

-- 4. Tablespace para Datos Históricos (Capa 2 - Datos "Fríos")
-- Asignación ropuesta: 5 GB
-- Se recomienda compresión para datos históricos para ahorrar espacio
CREATE TABLESPACE infraestr_c2_hist_ts
  DATAFILE '/unam/bda/pf/c2/d02/infraestr_c2_hist_ts_01.dbf'
  SIZE 100M
  AUTOEXTEND ON NEXT 50M MAXSIZE 5G
  DEFAULT ROW STORE COMPRESS ADVANCED -- Opcional: Recomendado para históricos
  EXTENT MANAGEMENT LOCAL AUTOALLOCATE
  SEGMENT SPACE MANAGEMENT AUTO;

