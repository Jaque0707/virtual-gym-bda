
#Colocar en /etc/profile.d

export UNAM_HOME=/unam

export ORACLE_HOSTNAME=h2-bda-mbp.fi.unam
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=$ORACLE_BASE/product/23ai/dbhomeFree
export ORA_INVENTORY=$ORACLE_BASE/oraInventory
export ORACLE_SID=free
export NLS_LANG=American_America.AL32UTF8
export PATH=$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH

export TNS_ADMIN=$ORACLE_HOME/network/admin

alias sqlplus='rlwrap sqlplus'
