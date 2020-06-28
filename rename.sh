#!/usr/bin/env bash
# Written by Alex F. Bokov, Ph.D. for use with SQLPlus and an i2b2 schema
# Copyright 2020
# MIT License



###############################################################################
# This is a script for renaming table and schema references to accommodate    #
# sites that might vary in how their databases are organized and named        #
###############################################################################

sed -i "s/ CUSTOM_EFI_CODES_I2B2 /MY_LOOKUP_SCHEMA.CUSTOM_EFI_CODES_I2B2@MY_LOOKUP_DB.mi/gI" *.sql
sed -i "s/ CUSTOM_EFI_LABS_I2B2 /MY_LOOKUP_SCHEMA.CUSTOM_EFI_LABS_I2B2@MY_LOOKUP_DB.mi/gI" *.sql
sed -i "s/I2B2DEMODATA/MY_DATAMART/gI" *.sql
sed -i "s/I2B2METADATA.I2B2/MY_ONTOLOGY.MY_TERMS/gI" *.sql
sed -i "s/I2B2METADATA/MY_ONTOLOGY/gI" *.sql
sed -i "s/I2B2IDENTIFIED/MY_IDENTIFIED_DATAMART/gI" *.sql
sed -i "s/ETLUSER/C##ALEX/gI" *.sql
sed -i "s/'i2b2'/'MY_TERMS'/gI" *.sql
# These alter your mapping tables. You can add any other local codes here as 
# needed
sed -i "s/PAT_ENC:BP_SYSTOLIC_ART/LOCAL_BP_SYSTOLIC_ART_CODE/gI" *.csv
sed -i "s/PAT_ENC:BP_SYSTOLIC/LOCAL_BP_SYSTOLIC_CODE/gI" *.csv
sed -i "s/PAT_ENC:BP_DIASTOLIC/LOCAL_BP_DIASTOLIC_CODE/gI" *.csv
sed -i "s/PAT_ENC:BP_DIASTOLIC_ART/LOCAL_BP_DIASTOLIC_ART_CODE/gI" *.csv
sed -i "s/PAT_ENC:BMI/LOCAL_BMI_CODE/gI" *.csv
sed -i "s/TOBACCO_USER:4/LOCAL_FORMER_SMOKER_CODE/gI" *.csv
sed -i "s/TOBACCO_USER:1/LOCAL_CURRENT_SMOKER_CODE/gI" *.csv


###############################################################################
# If you are going to contribute patches back to this project, please         #
# uncomment and edit the below lines and run them before sending us your code #
###############################################################################
#sed -i "s/MY_LOOKUP_SCHEMA.CUSTOM_EFI_CODES_I2B2@MY_LOOKUP_DB.mi/ CUSTOM_EFI_CODES_I2B2 /gI" *.sql
#sed -i "s/MY_LOOKUP_SCHEMA.CUSTOM_EFI_LABS_I2B2@MY_LOOKUP_DB.mi/ CUSTOM_EFI_LABS_I2B2 /gI" *.sql
#sed -i "s/MY_DATAMART/I2B2DEMODATA/gI" *.sql
#sed -i "s/MY_ONTOLOGY.MY_TERMS/I2B2METADATA.I2B2/gI" *.sql
#sed -i "s/MY_ONTOLOGY/I2B2METADATA/gI" *.sql
#sed -i "s/MY_IDENTIFIED_DATAMART/I2B2IDENTIFIED/gI" *.sql
#sed -i "s/C##ALEX/ETLUSER/gI" *.sql
#sed -i "s/'MY_TERMS'/'i2b2'/gI" *.sql


