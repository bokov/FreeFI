/**** 10_fact_Frailty.sql ****/
/* 
Written by Alex F. Bokov, Ph.D. for use with SQLPlus and an i2b2 schema
Copyright 2020
Released free of charge for use and modification under the MIT License

get all unique combos of patients, visit-days, 
and unique frailty buckets (mapped from codes_frailty)
that occurred DURING EACH GIVEN VISIT AND ANYTIME 
WITHIN THE LAST 2 YEARS OF THAT VISIT 
(approximated as 730 days)
 */

/* Only the visit-days assigned to one or more frailty groups

At sites where an ETL staging table for diagnoses is not 
available, the OBSERVATION_FACT table can be substituted.

Note: If you have separate identified and de-id datamarts
at your site, make sure to use the same datamart for 
creating tmp_frailty_pt_dt_grp00 and tmp_frailty_pt_dt_grp01
 */

create table etl.tmp_frailty_pt_dt_grp00 as
select patient_num,round(start_date) dt, grp
from etl.stage_lab_facts obs join 
 CUSTOM_EFI_LABS_I2B2  cdf
on obs.concept_cd = cdf.code and obs.valueflag_cd = cdf.valueflag
union
select patient_num,round(start_date) dt, grp
from etl.stage_visit_vital_facts obs join 
 CUSTOM_EFI_LABS_I2B2  cdf
on obs.concept_cd = cdf.code and obs.valueflag_cd = cdf.valueflag
union
select patient_num,round(start_date) dt, grp
from ETL.STAGE_DIAGNOSIS_FACTS obs join 
 CUSTOM_EFI_CODES_I2B2  cdf
on obs.concept_cd LIKE cdf.diag||'%'
/* -- apparently we shouldn't rely on history facts anymore
union
select patient_num,round(start_date) dt, grp
from ETL.STAGE_HISTORY_FACTS obs join 
 CUSTOM_EFI_CODES_I2B2  cdf
on obs.concept_cd LIKE cdf.diag||'%'
 */
;

-- here bitmap didn't make a difference?
create bitmap index etl.tmp_pndt00a on
etl.tmp_frailty_pt_dt_grp00(patient_num,dt)
; 
-- 4.773s	660723r -- woooow, bitmap indices really help!

/* All visit-days, with unique frailty groups for them and the previous 730 days */
create table 
etl.tmp_frailty_pt_dt_grp01 as 
select distinct obs.patient_num,round(obs.start_date) start_date, grp.grp
from I2B2IDENTIFIED.observation_fact obs
left join etl.tmp_frailty_pt_dt_grp00 grp
on obs.patient_num = grp.patient_num 
and start_date < dt + 730 -- timewindow
and start_date >= dt
--order by patient_num,start_date
; 
--331.303s	5537767r

create bitmap index etl.tmp_pndt01 on
etl.tmp_frailty_pt_dt_grp01
(patient_num ASC, start_date ASC)
;

/* final fact table */
create table etl.STAGE_FRAILTY_FACTS as 
with 
facts as (
 select patient_num     patient_num,
 start_date             start_date,
 COUNT(grp)              nval_num
from etl.tmp_frailty_pt_dt_grp01
GROUP BY patient_num, start_date),
ngrp as (
select count( grp) nn 
from (select grp from  CUSTOM_EFI_CODES_I2B2 
union select grp from  CUSTOM_EFI_LABS_I2B2 ))
select 
 etl.randFakeEncounter.nextVal encounter_num,
 patient_num            patient_num,
 'CUSTOM:EFI'           concept_cd,
 '@'                    provider_id,
 start_date             start_date,
 '@'                    modifier_cd,
 1                      instance_num,
 'N'                    valtype_cd,
 'E'                    tval_char,
 nval_num/nn            nval_num,
 '@'                    valueflag_cd,
 '{ratio}'              units_cd,
 '@'                    location_cd,
 SYSDATE                update_date,
 SYSDATE                download_date,
 SYSDATE                import_date,
 'CIRD@UTHSCSA'         sourcesystem_cd,
 1                      upload_id,
 -1                     sub_encounter
from facts,ngrp
;
-- whole thing:
-- Cost         CPU Cost        I/O Cost
-- 1777871	480020640814	1764187
-- just payload:
-- 1027163	460425097048	1014038
-- changed order:
-- 1340536      471446241221    1327097
-- Running sys.dbms_stats.gather_table_stats and analyze index ... compute statistics
--   does not change the above costs.

-- 3.901s	932158r
-- 4.801s	932158r

/* 
Some sites have a de-identified datamart physically separate from the
identified version. If these facts are created on identified data 
(I2B2IDENTIFIED) the dates need to be obfuscated by using a 
patient-specific random date-shift value that at some sites is a column
in I2B2IDENTIFIED.PATIENT_DIMENSION. Other sites use PATIENT_MAPPING for 
storing date shifts, and should change the JOIN clause accordingly. If 
neither applies to you, comment out the portion of the line in the query 
that says "+ pd.date_shift start_date" and commend out the join clause
on the last line
 */
insert into I2B2DEMODATA.observation_fact(
        encounter_num,patient_num,concept_cd,provider_id,start_date,
        modifier_cd,instance_num,valtype_cd,tval_char,nval_num,valueflag_cd,units_cd,location_cd,
        update_date,download_date,import_date,sourcesystem_cd,
        upload_id,sub_encounter)
select 
 encounter_num,fact.patient_num,concept_cd,provider_id,
 start_date + pd.date_shift start_date,
 modifier_cd,instance_num,valtype_cd,
 tval_char,nval_num,  -- the frailty score
 valueflag_cd,units_cd,location_cd,fact.update_date,
 fact.download_date,fact.import_date,fact.sourcesystem_cd,
 fact.upload_id,sub_encounter
from etl.STAGE_FRAILTY_FACTS fact
join I2B2IDENTIFIED.patient_dimension pd on fact.patient_num = pd.patient_num
; 
-- 30.709s	932158s

/* Cleanup */
drop table 
etl.tmp_frailty_pt_dt_grp00 CASCADE constraints purge;
drop table 
etl.tmp_frailty_pt_dt_grp01 CASCADE constraints purge;
