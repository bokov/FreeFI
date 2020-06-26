/**** 09_Ontology_Frailty.sql ****/
/* 
Written by Alex F. Bokov, Ph.D. for use with SQLPlus and an i2b2 schema
Copyright 2020
Released free of charge for use and modification under the MIT License

Check your I2B2METADATA.I2B2, I2B2METADATA.SCHEMES, I2B2METADATA.TABLE_ACCESS, 
and I2B2DEMODATA.CONCEPT_DIMENSION tables before running this script, and 
comment out below the insertions for which values already exist.
*/


/* TERMS TABLE addition */
-- parent term, since custom doesn't exist yet
INSERT INTO I2B2METADATA.I2B2 (
        C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, 
        C_TOTALNUM, C_BASECODE, C_FACTTABLECOLUMN, C_TABLENAME, C_COLUMNNAME, 
        C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, C_TOOLTIP, M_APPLIED_PATH, 
        UPDATE_DATE, DOWNLOAD_DATE, IMPORT_DATE, SOURCESYSTEM_CD) 
VALUES (
 1,                                      --c_hlevel, 
 '\i2b2\Custom\',                        --c_fullname, 
 'Custom Variables (experimental)',      --c_name,
 'N',                                    --c_synonym_cd,
 'FA ',                                  --c_visualattributes,
 null,                                   --c_totalnum,
 'CUSTOM',                               --c_basecode,
 'concept_cd',                           --c_facttablecolumn,
 'concept_dimension',                    --c_tablename,
 'concept_path',                         --c_columname,
 'T',                                    --c_columndatatype,
 'LIKE',                                 --c_operator,
 '\i2b2\Custom\',                        --c_dimcode,
 ' \ i2b2 \ Visit Details \ ',           --c_tooltip,
 '@',                                    --m_applied_path,
 sysdate,                                --update_date,
 sysdate,                                --download_date,
 sysdate,                                --import_date,
 'CIRD@UTHSCSA'                          --sourcesystem_cd
 );
 
-- Child term, for the actual frailty fact
INSERT INTO I2B2METADATA.I2B2 (
        C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, 
        C_TOTALNUM, C_BASECODE, C_METADATAXML, C_FACTTABLECOLUMN, C_TABLENAME, 
        C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, C_TOOLTIP, 
        M_APPLIED_PATH, UPDATE_DATE, DOWNLOAD_DATE, IMPORT_DATE, SOURCESYSTEM_CD) 
values
(2,                                             --c_hlevel
 '\i2b2\Custom\eFI\',                           --c_fullname,
 'Electronic Frailty Index [experimental]',     --c_name,
 'N',                                           --c_synonym,
 'LA',                                          --c_visualattributes,
 null,                                          --c_totalnum,
 'CUSTOM:EFI',                                  --c_basecode,
 '<?xml version="1.0"?>
<ValueMetadata>
 <Version>3.02</Version>
 <CreationDateTime>19-FEB-20</CreationDateTime>
 <TestID>CUSTOM:EFI</TestID>
 <TestName>Electronic Frailty Index</TestName>
 <DataType>Integer</DataType>
 <CodeType>GRP</CodeType>
 <Loinc>CUSTOM:EFI</Loinc>
 <Flagstouse>HL</Flagstouse>
 <Oktousevalues>Y</Oktousevalues>
 <MaxStringLength></MaxStringLength>
 <LowofLowValue></LowofLowValue>
 <HighofLowValue></HighofLowValue>
 <LowofHighValue></LowofHighValue>
 <HighofHighValue></HighofHighValue>
 <LowofToxicValue></LowofToxicValue>
 <HighofToxicValue></HighofToxicValue>
 <EnumValues></EnumValues>
 <CommentsDeterminingExclusion>
   <Com></Com>
 </CommentsDeterminingExclusion>
 <UnitValues>
   <NormalUnits></NormalUnits>
   <ConvertingUnits>
     <Units>Default</Units>
     <MultiplyingFactor></MultiplyingFactor>
   </ConvertingUnits>
 </UnitValues>
 <Analysis>
   <Enums />
   <Counts />
   <New />
 </Analysis>
</ValueMetadata>',                               --c_metadataxml,
 'concept_cd',                                   --c_facttablecolumn,
 'concept_dimension',                            --c_tablename,
 'concept_path',                                 --c_columnname,
 'T',                                            --c_columndatatype,
 '=',                                            --c_operator,
 '\i2b2\Custom\eFI\',                            --c_dimcode,
 ' \ i2b2 \ Custom \ eFI \ ',                    --c_tooltip,
 '@',                                            --m_applied_path,
 sysdate,                                        --update_date,
 sysdate,                                        --download_date,
 sysdate,                                        --import_date,
 'CIRD@UTHSCSA'                                  --sourcesystem_cd
 );

/* CONCEPT_DIMENSION */

insert into I2B2DEMODATA.concept_dimension(concept_path, concept_cd, name_char)
select distinct c_dimcode concept_path, c_basecode concept_cd, c_name name_char 
from I2B2METADATA.I2B2
where c_basecode like ('CUSTOM%')
;

/* SCHEMES
using MERGE to avoid duplicate insertions, as per
https://stackoverflow.com/a/16163063/945039 */

MERGE INTO I2B2METADATA.schemes sch USING DUAL ON (sch.C_KEY= 'CUSTOM:')
WHEN NOT MATCHED THEN INSERT(C_KEY,C_NAME,C_DESCRIPTION)
VALUES ('CUSTOM:','Experimental Analytic Variables','These are experimental and can change at any time. Use at own risk');

/*
--uncomment if needed
insert into I2B2METADATA.table_access(c_table_cd, c_table_name, c_protected_access, c_hlevel, c_fullname, c_name, 
                              c_synonym_cd, c_visualattributes, c_facttablecolumn, c_dimtablename, 
                              c_columnname, c_columndatatype, c_operator, c_dimcode, c_tooltip)

select regexp_replace(substr(c_fullname, 2, length(c_fullname) -2), '\\', '_') c_table_cd, 'i2b2' c_table_name, 'N' c_protected_access, '0' c_hlevel, c_fullname, c_name, 'N' C_synonym_cd, 'FA' C_visualattributes, 
         'concept_cd' c_facttablecolumn, 'concept_dimension' c_dimtablename, 'concept_path' c_columnname, 'T' c_columndatatype,
         'LIKE' c_operator, c_fullname c_dimcode, c_name c_tooltip
from I2B2METADATA.I2B2 
where c_hlevel = 1 and c_fullname = '\i2b2\Custom\';
*/

