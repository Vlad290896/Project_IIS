DROP DIRECTORY ext_file_xlsx;

CREATE OR REPLACE DIRECTORY ext_file_xlsx AS 'V:\Pentru_Facultate\Master\Anul_2\Semestrul_2\Integrare_Informationala\Laborator\Project\Project_Files';
GRANT ALL ON DIRECTORY ext_file_xlsx TO PUBLIC;


-- DROP PACKAGE EXCELTABLE;
-- DROP PACKAGE XUTL_CDF;
-- DROP PACKAGE XUTL_OFFICECRYPTO;
-- DROP PACKAGE XUTL_XLS;
-- DROP PACKAGE XUTL_XLSB;
-- DROP TYPE EXCELTABLECELLLIST;
-- DROP TYPE EXCELTABLECELL;
-- DROP TYPE EXCELTABLEIMPL;

DROP VIEW MTS_TO_VIEW;
CREATE OR REPLACE VIEW MTS_TO_VIEW AS
SELECT t.*
from TABLE(
    ExcelTable.getRows(
       ExcelTable.getFile('EXT_FILE_XLSX','mts.xlsx')
       , 'mts'
       ,   ' "SUBJECT"               VARCHAR2(10)
           , "SIT"                   VARCHAR2(5)
           , "VIS"                   VARCHAR2(50)
           , "UNV"                   VARCHAR2(50)
           , "MTSRES1"	             VARCHAR2(50)
           , "MTSRES2"               VARCHAR2(50)
           , "MTSRES3"               VARCHAR2(50)
           , "MTSRES4"               VARCHAR2(50)
		   , "QSCAT"                 VARCHAR2(100)'
     , 'A2'
     )
) t;
SELECT * FROM MTS_TO_VIEW;
