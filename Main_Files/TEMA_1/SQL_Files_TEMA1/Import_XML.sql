CREATE OR REPLACE DIRECTORY ext_file_xml AS 'V:\Pentru_Facultate\Master\Anul_2\Semestrul_2\Integrare_Informationala\Laborator\Project\Project_Files';
SELECT * FROM all_directories WHERE directory_name='EXT_FILE_CSV';
GRANT ALL ON DIRECTORY ext_file_xml TO PUBLIC;

DROP VIEW countries_view;
CREATE OR REPLACE VIEW countries_view AS
select x.Id, x.countryName, x.subject
    from XMLTABLE(
        '/countries/country'
        passing XMLTYPE(
            BFILENAME('EXT_FILE_XML', 'COUNTRIES.xml')
            , nls_charset_id('AL32UTF8')
        )
        columns
              id            integer         path 'id'  
            , countryName   varchar2(20)    path 'countryName'
            , subject       integer         path 'subject'
        ) x;
SELECT * FROM countries_view;
