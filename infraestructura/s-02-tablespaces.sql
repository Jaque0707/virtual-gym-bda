--@Autor: Benítez Pérez Michelle Paulina
--        Hernández García Pilar Jaqueline
--@Fecha creación: 08/12/2025
--@Descripción: 

-- 1. Tablespace para Datos Operativos (Capa 1)
-- Almacena tablas como: gimnasio, sala, aparato, disciplina
CREATE TABLESPACE infra_c1_data_ts
    DATAFILE '/unam/bda/pf/c1/d03/infra_c1_data_ts.dbf' 
    SIZE 1G
    AUTOEXTEND ON NEXT 500M MAXSIZE 8G
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE
    SEGMENT SPACE MANAGEMENT AUTO;

-- 2. Tablespace para Índices (Capa 1)
-- Almacena los índices de las tablas operativas para búsquedas rápidas
CREATE TABLESPACE infra_c1_ix_ts
    DATAFILE '/unam/bda/pf/c1/d04/infra_c1_ix_ts.dbf' 
    SIZE 50M
    AUTOEXTEND ON NEXT 50M MAXSIZE 2G
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE
    SEGMENT SPACE MANAGEMENT AUTO;

-- 3. Tablespace para Multimedia (Capa 2)
-- Almacena datos BLOB pesados (videos/imágenes) con menor frecuencia de acceso (Warn/Cold)
CREATE TABLESPACE infra_c2_lob_ts
    DATAFILE '/unam/bda/pf/c2/d03/infra_c2_lob_ts.dbf' 
    SIZE 100M
    AUTOEXTEND ON NEXT 50M MAXSIZE 5G
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE
    SEGMENT SPACE MANAGEMENT AUTO;

-- 4. Tablespace para Iconos (Capa 1)
-- Almacena datos BLOB pequeños y de alto acceso (Hot Lobs)
CREATE TABLESPACE infra_c1_lob_ts
    DATAFILE '/unam/bda/pf/c1/d05/infra_c1_lob_ts.dbf' 
    SIZE 10M
    AUTOEXTEND ON NEXT 10M MAXSIZE 100M
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE
    SEGMENT SPACE MANAGEMENT AUTO;

-- 5. Tablespace para Históricos (Capa 2)
-- Almacena datos de historial_status_aparato
CREATE TABLESPACE infra_c2_hist_ts
    DATAFILE '/unam/bda/pf/c2/d04/infra_c2_hist_ts.dbf' 
    SIZE 100M
    AUTOEXTEND ON NEXT 50M MAXSIZE 3G
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE
    SEGMENT SPACE MANAGEMENT AUTO;