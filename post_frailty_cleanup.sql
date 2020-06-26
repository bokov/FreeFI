/* 
Written by Alex F. Bokov, Ph.D. for use with SQLPlus and an i2b2 schema
Copyright 2020
Released free of charge for use and modification under the MIT License
*/

/*
uncomment block for full cleanup as needed if you are using local dummy
accounts. DO NOT run this if I2B2DEMODATA, I2B2METADATA, 
or I2B2IDENTIFIED point to your production accounts rather than to 
dummy accounts!
*/

/* 
drop table etl.stage_frailty_facts CASCADE constraints purge;
truncate table I2B2DEMODATA.observation_fact;
truncate table I2B2DEMODATA.concept_dimension;
truncate table I2B2METADATA.I2B2;
truncate table I2B2METADATA.schemes;
truncate table I2B2METADATA.table_access;
truncate table I2B2IDENTIFIED.observation_fact;
-- DROP sequence "ETL"."RANDFAKEENCOUNTER";
 */

