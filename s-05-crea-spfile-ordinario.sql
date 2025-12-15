--@Autores: Benítez Pérez Michelle Paulina
--          Hernández García Pilar Jaqueline
--@Fecha creación: 08/12/2025
--@Descripción: Creación del archivo spfile a partir del pfile

-- autenticar como usuario sys
connect sys/Med1aStream* as sysdba

-- crear el spfile
create spfile from pfile;

-- verificar la creación
!ls ${ORACLE_HOME}/dbs/spfile${ORACLE_SID}.ora
