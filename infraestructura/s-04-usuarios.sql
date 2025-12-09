--@Autor: Benítez Pérez Michelle Paulina
--        Hernández García Pilar Jaqueline
--@Fecha creación: 08/12/2025
--@Descripción: 

connect sys/systemP@pf_infraestr as sysdba

create user infra_admin identified by infra_admin
  default tablespace infra_c1_data_ts
  quota unlimited on infra_c1_data_ts
  quota unlimited on infra_c1_ix_ts
  quota unlimited on infra_c2_lob_ts
  quota unlimited on infra_c1_lob_ts
  quota unlimited on infra_c2_hist_ts;

grant create session, create table, create sequence, create procedure to infra_admin;
grant sysbackup to infra_admin;