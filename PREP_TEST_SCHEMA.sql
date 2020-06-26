/** create mock schemas if needed **/
/*
Written by Alex F. Bokov, Ph.D. for use with SQLPlus and an i2b2 schema
Copyright 2020
MIT License
*/

/* 
If any of the following don't exist at your site,
have different names, or you wish to not use the 
real versions while creating the eFI scores, you
can create either dummy accounts or synonyms. 
Examples:
*/
/*
CREATE USER "ETL" IDENTIFIED BY "THEPASSWORD"    
      DEFAULT TABLESPACE "ENC_DATA"
      TEMPORARY TABLESPACE "TMP0GRP0";
 ALTER USER "ETL" LOCAL TEMPORARY TABLESPACE "TMP0GRP0";
 
CREATE USER "I2B2DEMODATA" IDENTIFIED BY "THEPASSWORD"
      DEFAULT TABLESPACE "ENC_DATA"
      TEMPORARY TABLESPACE "TMP0GRP0";
 ALTER USER "I2B2DEMODATA" LOCAL TEMPORARY TABLESPACE "TMP0GRP0";
 
CREATE USER "I2B2METADATA" IDENTIFIED BY "THEPASSWORD"
      DEFAULT TABLESPACE "ENC_DATA"
      TEMPORARY TABLESPACE "TMP0GRP0";
 ALTER USER "I2B2METADATA" LOCAL TEMPORARY TABLESPACE "TMP0GRP0";
 
CREATE USER "I2B2IDENTIFIED" IDENTIFIED BY "THEPASSWORD"
      DEFAULT TABLESPACE "ENC_DATA"
      TEMPORARY TABLESPACE "TMP0GRP0";
 ALTER USER "I2B2IDENTIFIED" LOCAL TEMPORARY TABLESPACE "TMP0GRP0";
*/

/** set needed privs **/
/*
-- ETLUSER = account you will be using to run these scripts
alter user ETLUSER quota unlimited on "ENC_DATA";
grant select any table to ETLUSER;
grant resource to ETLUSER;
grant unlimited tablespace to ETL;
grant unlimited tablespace to I2B2DEMODATA;
grant unlimited tablespace to I2B2METADATA;
grant unlimited tablespace to I2B2IDENTIFIED;

/** create dblinks **/
-- If some of the needed tables are on other databases
-- CREATE DATABASE LINK "PRODUCTION.MI" CONNECT TO OTHERUSER IDENTIFIED BY "XXX" USING 'PRODUCTION';


/** create mock tables **/
/*
These commands assume you are creating a dummy environment where these tables
don't yet exist. If they already exist, the DDL statements here will fail, but
hopefully that won't matter since the tables do exist.
*/
-- I2B2DEMODATA
CREATE TABLE
    I2B2DEMODATA.OBSERVATION_FACT
    (
      ENCOUNTER_NUM NUMBER(38), PATIENT_NUM NUMBER(38), CONCEPT_CD VARCHAR2(50), PROVIDER_ID
      VARCHAR2(50), START_DATE DATE, MODIFIER_CD VARCHAR2(100), INSTANCE_NUM NUMBER(18), VALTYPE_CD
      VARCHAR2(50), TVAL_CHAR VARCHAR2(4000), NVAL_NUM NUMBER(18,5), VALUEFLAG_CD VARCHAR2(50),
      QUANTITY_NUM NUMBER(18,5), UNITS_CD VARCHAR2(50), END_DATE DATE, LOCATION_CD VARCHAR2(50),
      OBSERVATION_BLOB CLOB, CONFIDENCE_NUM NUMBER(18,5), UPDATE_DATE DATE, DOWNLOAD_DATE DATE,
      IMPORT_DATE DATE, SOURCESYSTEM_CD VARCHAR2(50), UPLOAD_ID NUMBER(38), SUB_ENCOUNTER VARCHAR2
      (200), CONSTRAINT OBSERVATION_FACT_PK UNIQUE (ENCOUNTER_NUM, CONCEPT_CD, PROVIDER_ID,
      START_DATE, MODIFIER_CD, INSTANCE_NUM)
    );
CREATE TABLE
    I2B2DEMODATA.CONCEPT_DIMENSION
    (
      CONCEPT_PATH VARCHAR2(700) NOT NULL, CONCEPT_CD VARCHAR2(50) NOT NULL, NAME_CHAR VARCHAR2
      (2000), CONCEPT_BLOB CLOB, UPDATE_DATE DATE, DOWNLOAD_DATE DATE, IMPORT_DATE DATE,
      SOURCESYSTEM_CD VARCHAR2(50), UPLOAD_ID NUMBER(38), CONSTRAINT CONCEPT_DIMENSION_PK PRIMARY
      KEY (CONCEPT_PATH)
    );

-- I2B2METADATA
CREATE TABLE
    I2B2METADATA.I2B2
    (
      C_HLEVEL NUMBER(22) NOT NULL, C_FULLNAME VARCHAR2(700) NOT NULL, C_NAME VARCHAR2(2000) NOT
      NULL, C_SYNONYM_CD CHAR(1) NOT NULL, C_VISUALATTRIBUTES CHAR(3) NOT NULL, C_TOTALNUM NUMBER
      (22), C_BASECODE VARCHAR2(50), C_METADATAXML CLOB, C_FACTTABLECOLUMN VARCHAR2(50) NOT NULL,
      C_TABLENAME VARCHAR2(50) NOT NULL, C_COLUMNNAME VARCHAR2(50) NOT NULL, C_COLUMNDATATYPE
      VARCHAR2(50) NOT NULL, C_OPERATOR VARCHAR2(10) NOT NULL, C_DIMCODE VARCHAR2(700) NOT NULL,
      C_COMMENT CLOB, C_TOOLTIP VARCHAR2(900), M_APPLIED_PATH VARCHAR2(700) NOT NULL, UPDATE_DATE
      DATE NOT NULL, DOWNLOAD_DATE DATE, IMPORT_DATE DATE, SOURCESYSTEM_CD VARCHAR2(50),
      VALUETYPE_CD VARCHAR2(50), M_EXCLUSION_CD VARCHAR2(25), C_PATH VARCHAR2(700), C_SYMBOL
      VARCHAR2(50)
    );
    
create table I2B2METADATA.SCHEMES as select * from I2B2METADATA.SCHEMES@PRODUCTION.MI;
create table I2B2METADATA.TABLE_ACCESS as select * from I2B2METADATA.TABLE_ACCESS@PRODUCTION.MI;

--I2B2IDENTIFIED
-- if you have a separate identified datamart, uncomment and edit the following:
/* 
CREATE or replace SYNONYM "I2B2IDENTIFIED".patient_dimension FOR I2B2IDENTIFIED.patient_dimension@PRODUCTION.MI; 
CREATE or replace synonym I2B2IDENTIFIED.observation_fact for I2B2IDENTIFIED.observation_fact@PRODUCTION.MI;
*/
-- otherwise, uncomment and edit the following lines (i.e. have I2B2IDENTIFIED and I2B2DEMODATA pointing to the 
-- same datamart
/*
CREATE or replace SYNONYM "I2B2IDENTIFIED".patient_dimension FOR I2B2DEMODATA.patient_dimension@PRODUCTION.MI; 
CREATE or replace synonym I2B2IDENTIFIED.observation_fact for I2B2DEMODATA.observation_fact@PRODUCTION.MI;
*/

-- etl
/* If you have staging tables, uncomment and edit below to creat synonyms pointing to them.*/
/*
create or replace synonym etl.stage_diagnosis_facts for etl.stage_diagnosis_facts@PRODUCTION.MI;
-- create or replace synonym etl.stage_history_facts for etl.stage_history_facts@PRODUCTION.MI;
create or replace synonym etl.stage_lab_facts for etl.stage_lab_facts@PRODUCTION.MI;
create or replace synonym etl.stage_visit_vital_facts for etl.stage_visit_vital_facts@PRODUCTION.MI;
*/
/* If you don't have staging tables, or your staging tables are not in the same
   format at the i2b2 OBSERVATION_FACT table, just make all of them synonyms to 
   OBSERVATION_FACT (if you don't have a separate identified datamart, use 
   I2B2DEMODATA or whatever the correct name for that database is)
*/
/*
create or replace synonym etl.stage_diagnosis_facts for I2B2IDENTIFIED.OBSERVATION_FACT@PRODUCTION.MI;
-- create or replace synonym etl.stage_history_facts for I2B2IDENTIFIED.OBSERVATION_FACT@PRODUCTION.MI;
create or replace synonym etl.stage_lab_facts for I2B2IDENTIFIED.OBSERVATION_FACT@PRODUCTION.MI;
create or replace synonym etl.stage_visit_vital_facts for I2B2IDENTIFIED.OBSERVATION_FACT@PRODUCTION.MI;
*/

CREATE or replace SYNONYM etl.randFakeEncounter for etl.randFakeEncounter@PRODUCTION.MI;

/** populate needed tables **/

/*
If you only want to create eFI values for a subset of available patients or 
visits, create a local I2B2IDENTIFIED.observation_fact table and insert the
selected visits into that table. It may or may not save you some time to do
the same thing with STAGE_DIAGNOSIS_FACTS if you have staging tables.
*/

/* 
create table mapping codes to frailty classes that will get counted up to 
get eFI scores 
*/
CREATE TABLE CUSTOM_EFI_CODES_I2B2  
    (
      GRP INTEGER NOT NULL, DIAG VARCHAR2(20) NOT NULL, DEFICIT VARCHAR2(50), SOURCE VARCHAR2(30),
      NOTES VARCHAR2(160), PRIMARY KEY (GRP, DIAG)
    );
    
-- TODO: DDL for the CUSTOM_EFI_LABS_I2B2
-- TODO: the actual mapping tables

-- GRANT SELECT ON   CUSTOM_EFI_CODES_I2B2   TO ETLUSER;
-- and any other users you might need
