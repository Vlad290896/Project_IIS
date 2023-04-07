SELECT * FROM patients_gen_health_state;
SELECT * FROM mts_to_view;
SELECT * FROM countries_view;
SELECT * FROM patients_view;

-----------------------------------------------------------

DROP VIEW OLAP_FACT_FINAL_HEALTH_STATE;
CREATE OR REPLACE VIEW OLAP_FACT_FINAL_HEALTH_STATE AS
SELECT P.Subject, PV.Symptoms
    , SUM(P.Health_State) as Final_Health_State
FROM patients_gen_health_state P 
    INNER JOIN patients_view PV
        ON P.subject =  PV.subject
GROUP BY P.Subject, PV.Symptoms;

SELECT * FROM OLAP_FACT_FINAL_HEALTH_STATE;

------------------------------------------------------------

DROP VIEW OLAP_DIM_SUBJ_SIT_COUNTRY;
CREATE OR REPLACE VIEW OLAP_DIM_SUBJ_SIT_COUNTRY AS
SELECT 
    PV.subject as subject,
    CV.countryName as countryName
FROM patients_view PV 
    INNER JOIN countries_view CV ON PV.subject = CV.subject;
    
SELECT * FROM OLAP_DIM_SUBJ_SIT_COUNTRY;


------------------------------------------------------------

DROP VIEW OLAP_DIM_SUBJ_AGE_VISITS;
CREATE OR REPLACE VIEW OLAP_DIM_SUBJ_AGE_VISITS AS
SELECT 
	PV.subject as subject,
	PV.Age as age,
	P.VIS as vis
FROM patients_view PV 
	INNER JOIN patients_gen_health_state P ON PV.idpacient = P.subject;
    
-------------------------------------------------------------

DROP VIEW OLAP_DIM_SUBJ_COUNTRY_OPINION;
CREATE OR REPLACE VIEW OLAP_DIM_SUBJ_COUNTRY_OPINION AS
SELECT 
	MTS.subject as subject,
    CV.countryName as country_name,
	MTS.MTSRES1 as gen_opinion
FROM
	countries_view CV
	INNER JOIN mts_to_view MTS ON CV.subject = MTS.subject
WHERE MTS.MTSRES1 LIKE 'AGREE';

select * from OLAP_DIM_SUBJ_COUNTRY_OPINION;
SELECT COUNT(MTSRES1) AS OPINIONS FROM mts_to_view WHERE MTSRES1 LIKE 'AGREE';
SELECT subject, MTSRES1 AS OPINIONS 
FROM
    mts_to_view 
WHERE
    MTSRES1 LIKE 'AGREE';

-------------------------------------------------------------

DROP VIEW OLAP_VIEW_FHEALTH_STATE_COUNTRIES;
CREATE OR REPLACE VIEW OLAP_VIEW_FHEALTH_STATE_COUNTRIES AS
SELECT 
CASE
    WHEN GROUPING(D1.subject) = 1 THEN '{Total General}'
    ELSE cast(D1.subject as varchar2(20)) END AS subject,
  CASE 
    WHEN GROUPING(D1.subject) = 1 THEN ' '
    WHEN GROUPING(D1.countryName) = 1 THEN 'Subtotal ' || D1.subject
    ELSE D1.countryName END AS countryName,
  CASE 
    WHEN GROUPING(D1.subject) = 1 THEN ' '
    WHEN GROUPING(D1.countryName) = 1 THEN ' '
    WHEN GROUPING(D1.subject) = 1 THEN 'subtotal country ' || D1.countryName
    ELSE to_char(D1.subject) END AS Subject_Identifier,    
  SUM(NVL(f.Final_Health_State, 0)) as Final_Health_State   
FROM OLAP_DIM_SUBJ_SIT_COUNTRY D1
    INNER JOIN OLAP_FACT_FINAL_HEALTH_STATE F ON D1.subject = F.subject
GROUP BY ROLLUP (d1.subject, d1.countryName)
ORDER BY d1.subject, d1.countryName;

select * from OLAP_FACT_FINAL_HEALTH_STATE;
select * from OLAP_DIM_SUBJ_SIT_COUNTRY;

----------------------------------------------------------------------------
DROP VIEW OLAP_VIEW_FHEALTH_STATE_AGE_GENDER;
CREATE OR REPLACE VIEW OLAP_VIEW_FHEALTH_STATE_AGE_GENDER AS
SELECT 
CASE
    WHEN GROUPING(D2.VIS) = 1 THEN '{Total General}'
    ELSE CAST(D2.VIS as varchar2(20)) END AS VIS,
  CASE 
    WHEN GROUPING(D2.VIS) = 1 THEN ' '
    WHEN GROUPING(D2.age) = 1 THEN 'Age subtotal ' || D2.VIS
    ELSE D2.age END AS Age,
  CASE 
    WHEN GROUPING(D2.VIS) = 1 THEN ' '
    WHEN GROUPING(D2.age) = 1 THEN ' '
    WHEN GROUPING(D2.Subject) = 1 THEN 'Age: ' || D2.age
    ELSE to_char(D2.Subject) END AS Subject_Identifier,    
  SUM(NVL(f.Final_Health_State, 0)) as Final_Health_State   
FROM OLAP_DIM_SUBJ_AGE_VISITS D2
    INNER JOIN OLAP_FACT_FINAL_HEALTH_STATE f ON D2.Subject = F.Subject
GROUP BY ROLLUP (d2.VIS, d2.age, d2.Subject)
ORDER BY d2.VIS, d2.age, d2.Subject;

select *  FROM OLAP_VIEW_FHEALTH_STATE_AGE_GENDER; 

---------------------------------------------------------------------------

DROP VIEW OLAP_DIM_SUBJ_AGE_GENDER;
CREATE OR REPLACE VIEW OLAP_DIM_SUBJ_AGE_GENDER AS
SELECT 
	PV.idpacient as idpacient,
	PV.Age as age,
	PV.Gender as gender,
	CV.Id as Id, 
	CV.countryName as countryName
FROM patients_view PV
	INNER JOIN countries_view CV on PV.idpacient = CV.subject;


---------------------------------------------------------------------------

DROP VIEW OLAP_VIEW_FHEALTH_STATE_CTY_AGE_GENDER;
CREATE OR REPLACE VIEW OLAP_VIEW_FHEALTH_STATE_CTY_AGE_GENDER AS
SELECT 
CASE
    WHEN GROUPING(D3.countryName) = 1 THEN '{Total General}'
    ELSE D3.countryName END AS countryName,
  CASE 
    WHEN GROUPING(D3.countryName) = 1 THEN ' '
    WHEN GROUPING(D3.age) = 1 THEN 'subtotal Region ' || D3.countryName
    ELSE D3.age END AS Age,
  CASE 
    WHEN GROUPING(D3.countryName) = 1 THEN ' '
    WHEN GROUPING(D3.age) = 1 THEN ' '
    WHEN GROUPING(D3.gender) = 1 THEN 'subtotal gender ' || D3.gender
    ELSE to_char(D3.id) END AS Subject_Identifier,    
  SUM(NVL(f.Final_Health_State, 0)) as Final_Health_State   
FROM OLAP_DIM_SUBJ_AGE_GENDER D3
    INNER JOIN OLAP_FACT_FINAL_HEALTH_STATE F ON D3.idpacient = F.subject
GROUP BY ROLLUP (d3.countryName, d3.age, d3.gender, d3.id)
ORDER BY d3.countryName, d3.age, d3.gender, d3.id;

SELECT * FROM OLAP_FACT_FINAL_HEALTH_STATE;
SELECT * FROM OLAP_DIM_SUBJ_AGE_GENDER;

---------------------------------------------------------------------------
DROP VIEW OLAP_VIEW_FHEALTH_STATE_CTY_OPINION;
CREATE OR REPLACE VIEW OLAP_VIEW_FHEALTH_STATE_CTY_OPINION AS
SELECT
CASE
    WHEN GROUPING(C.countryName) = 1 THEN '{Total General}'
    ELSE C.countryName END AS countryName,
CASE
    WHEN GROUPING(C.countryName) = 1 THEN ' '
    WHEN GROUPING(D4.subject) = 1 THEN 'subtotal regiune' || to_char(D4.subject)
    ELSE to_char(D4.subject) END AS Subject_Identifier,
    COUNT(*) AS Total_Patients
FROM OLAP_DIM_SUBJ_COUNTRY_OPINION D4
    INNER JOIN OLAP_DIM_SUBJ_SIT_COUNTRY C ON D4.subject = C.subject
    INNER JOIN olap_dim_subj_country_opinion O ON C.subject = O.subject
GROUP BY
    ROLLUP(C.countryName, D4.subject)
ORDER BY
    C.countryName, D4.subject;

select * from olap_dim_subj_country_opinion;

---------------------------------------------------------------------------

SELECT PV.idpacient, CV.countryName,
SUM(P.health_state) AS final_health_state,
RANK() OVER(ORDER BY SUM(P.health_state) DESC) AS POZ
FROM patients_view PV
 INNER JOIN patients_gen_health_state P ON P.subject = PV.idpacient
 INNER JOIN countries_view CV ON CV.subject = PV.idpacient
GROUP BY PV.idpacient, CV.countryName;

---------------------------------------------------------------------------

SELECT CV.countryName,
PV.idpacient, PV.Symptoms, SUM(P.health_state) AS health_state 
FROM patients_gen_health_state P
  INNER JOIN patients_view PV ON P.subject = PV.idpacient
  INNER JOIN countries_view CV ON PV.idpacient = CV.subject
GROUP BY ROLLUP(CV.countryName, PV.idpacient, PV.Symptoms)
ORDER BY 1,2,3;

------------------------------------------------------------------------------

SELECT * FROM
(SELECT 
  CASE 
       WHEN GROUPING(PV.idpacient) = 1 AND GROUPING(PV.Symptoms) = 0 
          THEN 'Subtotal simptom'
       ELSE to_char(PV.idpacient, 0)
  END as idpacient,
  CASE 
       WHEN GROUPING(PV.idpacient) = 0 AND GROUPING(PV.Symptoms) = 1 
          THEN 'Subtotal site'          
       ELSE PV.Symptoms
  END AS Symptoms,
  SUM(health_state) AS final_health_state
FROM patients_view PV
  INNER JOIN patients_gen_health_state P ON PV.idpacient = P.Subject
GROUP BY GROUPING SETS(PV.idpacient, PV.Symptoms, (PV.idpacient, PV.Symptoms))
ORDER BY 1,2,3)
PIVOT (
  SUM(final_health_state) 
  FOR Symptoms IN (
      'FLU' as "Gripa",
      'MIGRAINE' as "Migrena",
      'ALLERGY' as "Alergie",
      'COLD' as "Raceala",
      'Subtotal site' as "Total site")
  )
ORDER BY 1;

----------------------------------------------------------------------------

SELECT P.subject, SUM(P.health_state) AS health_state
FROM patients_view PV 
INNER JOIN patients_gen_health_state P ON PV.subject = P.subject
GROUP BY P.subject
ORDER BY SUM(P.health_state) DESC;

----------------------------------------------------------------------------

SELECT
    P.subject,
    P.sit,
    CV.countryName,
    SUM(P.health_state) AS final_health_state
FROM patients_gen_health_state P
    INNER JOIN patients_view PV ON P.subject = PV.subject
    INNER JOIN countries_view CV ON PV.subject = CV.subject
GROUP BY CUBE(P.subject, P.sit, CV.countryName)
ORDER BY 1,2
FETCH NEXT 109 ROWS ONLY;









