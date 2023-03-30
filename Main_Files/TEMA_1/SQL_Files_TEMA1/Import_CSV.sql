DROP DIRECTORY ext_file_csv;

CREATE OR REPLACE DIRECTORY ext_file_csv AS 'V:\Pentru_Facultate\Master\Anul_2\Semestrul_2\Integrare_Informationala\Laborator\Project\Project_Files\Log_Files_Gen_Health_State_Table';
GRANT ALL ON DIRECTORY ext_file_csv TO PUBLIC;
DROP TABLE PATIENTS_GEN_HEALTH_STATE;
CREATE TABLE PATIENTS_GEN_HEALTH_STATE (
  SUBJECT               integer,
  SIT      	  	        VARCHAR2(5),
  VIS                   NUMERIC(10),
  UNV                   NUMERIC(2),
  Time_Point            NUMERIC(2),
  Mobility              NUMERIC(2),
  Self_Care             NUMERIC(2),
  Usual_Activity        NUMERIC(2),
  Pain_Discomfort       NUMERIC(2),
  Anxiety               NUMERIC(2),
  Health_State          NUMERIC(2),
  QSCAT                 VARCHAR2(10)
)
ORGANIZATION EXTERNAL (
  TYPE ORACLE_LOADER
  DEFAULT DIRECTORY ext_file_csv
  ACCESS PARAMETERS (
    RECORDS DELIMITED BY NEWLINE SKIP 1
    FIELDS TERMINATED BY ','
    MISSING FIELD VALUES ARE NULL
  )
  LOCATION ('eq5d5l_gen_health_state.csv')
)
REJECT LIMIT UNLIMITED;
SELECT * FROM PATIENTS_GEN_HEALTH_STATE;
