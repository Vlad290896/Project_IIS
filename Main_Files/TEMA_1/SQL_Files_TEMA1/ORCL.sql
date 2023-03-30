alter session set "_ORACLE_SCRIPT"=true;

create user clinicalTrial identified by "clinicalTrial";
grant all PRIVILEGES to clinicalTrial;

DROP USER clinicalTrial cascade;