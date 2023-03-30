alter session set "_ORACLE_SCRIPT"=true;

create user clinicalTrial identified by "clinicalTrial";
GRANT ALL PRIVILEGES
to clinicalTrial;

DROP USER clinicalTrial cascade;
