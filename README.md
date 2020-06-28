# Open Frailty Index: [Rockwood](https://bmcgeriatr.biomedcentral.com/articles/10.1186/1471-2318-8-24) methodology applied to EMR data

## Background 

The frailty index is a powerful general-purpose tool for predicting risks of complications, readmissions, ER utilization, and other preventable patient outcomes. Over the last 15 years, the Rockwood-style frailty score has been adapted to many sources of health data. The underlying algorithm is remarkably simple: 

1. Define at least 30 different 'deficits' (e.g. diagnoses, abnormal labs, abnormal vital signs) that cover a range of physiological systems (to avoid becoming a condition-specific index rather than a generalized one). The more non-redundant deficits are defined, the more precise the score. In this version we currently have 48 different deficits, each one mapping to 1 to 296 different codes (ICD9, ICD10, LOINC for abnormal lab results only, smoking status, and several vital signs).

2. For each individual, count up the number of _distinct_ deficits. Note that having multiple synonymous or near synonymous codes will not inflate the frailty score because the codes are first grouped into deficits as described above. In this version, we count distinct deficits over a rolling two-year time-window up to and including the current visit. We calculate a separate eFI for each visit date, making it possible to study eFI trajectories over time.

3. Divide the number of distinct deficits from the above by the total number of defined deficits. In this version, the denominator is dynamically calculated from the number of deficits groups empirically found to be supported by the local data source, with a maximum of 48.

## Design

This is an open source project for calculating eFI using data imported from EMR systems into the [i2b2](https://github.com/i2b2) star schema. The fact that i2b2 data is already in an EAV table means we can calculate eFI within the database using ordinary SQL joins and self-joins, without introducing dependencies on external scripts. Since i2b2 supports value-flags for lab results, we can avoid the need to maintain a table with a reference range for each lab, some of which depend on patient demographics.

The mapping tables and SQL (Oracle SQLPlus) scripts in this repository will produce a table in the `OBSERVATION_FACT` format with a granularity of patient-date. Selecting the `START_DATE`, `PATIENT_NUM`, and `NVAL_NUM` from this result into a CSV file will provide all the necessary information for populating a customized variable in your EMR system (though of course the import process will vary depending on what EMR system you have). 

The entire result (named `STAGE_FRAILTY_FACTS`) can be directly inserted into the i2b2 `OBSERVATION_FACT` table, and the `09_Ontology_Frailty.sql` script will create the necessary entries in the metadata and `CONCEPT_DIMENSION`. 

## Deployment Process

The high-level workflow is as follows:

1. Edit `rename.sh` so that it renames the placeholder names of databases, tables, and codes to ones that are valid for your site.
2. Run `09_Ontology_Frailty.sql` to create the necessary entries in `I2B2`, `SCHEMES`, `TABLE_ACCESS`, and `CONCEPT_DIMENSION`.
3. Run `10_fact_Frailty.sql` to create two intermediate tables which are then used to create the final output `STAGE_FRAILTY_FACTS` and insert it into `OBSERVATION_FACT`.

**Warning:** This is not an automated deployment process! At minimum you will need to edit `rename.sh` and probably also parts of the other scripts, especially `PREP_TEST_SCHEMA.sql`. We recommend you read and understand the intent of each SQL statement before you run it, and that you run them individually. If you use Postgres, MSSQL, or any other RDBMS than Oracle you will likely need to convert the code to the appropriate dialect of SQL.

## Future Directions

We want eFI to be deployable in as automated a manner as possible to encourage uptake by academic medical centers which will, in turn, benefit patients, providers, and researchers. The process of testing, hardening, documenting, and packaging code for wide deployment is a difficult one and frequently underestimated by health systems. You can help by trying this code out at your site and contributing your suggestions or patches back to this repository. We are looking for another CTSA site with which to partner on a grant for a multi-site implementation study of this open source clinical and research tool.

This is an open source project but you **may** incorporate this code into commercial products and we welcome collaborations with industry partners. For more information, please see our [license](https://github.com/bokov/FreeFI/raw/master/LICENSE). Please note that the concept of eFI itself is not patentable because a) the details of its implementation have been published in peer reviewed journals for about 15 years (see below) and b) because it amounts to nothing more than an unweighted average of indicator variables.

## Disclaimer

This is research code, freely distributed as-is with no warranty of suitability for any purpose expressed or implied. If you choose to work with these scripts we recommend you use de-identified data and check with your IRB to insure that you are doing this in a manner that complies with your institution's policies.

## References

Here is a partial bibliography of academic publications on which the score calculated by these scripts is based:


M. E. Charlson, P. Pompei, K. L. Ales, and C. R. MacKenzie, “A new method of classifying prognostic comorbidity in longitudinal studies: development and validation,” *J Chronic Dis*, vol. 40, no. 5, pp. 373–383, 1987.


A. Clegg *et al.*, “Development and validation of an electronic frailty index using routine primary care electronic health record data,” *Age Ageing*, vol. 45, no. 3, pp. 353–360, May 2016, doi: [*10.1093/ageing/afw039*](https://doi.org/10.1093/ageing/afw039).


A. Elixhauser, C. Steiner, D. R. Harris, and R. M. Coffey, “Comorbidity Measures for Use with Administrative Data,” *Medical Care*, pp. 8–27, 1998.


N. M. Pajewski, K. Lenoir, B. J. Wells, J. D. Williamson, and K. E. Callahan, “Frailty Screening Using the Electronic Health Record Within a Medicare Accountable Care Organization,” *The Journals of Gerontology: Series A*, vol. 74, no. 11, pp. 1771–1777, Oct. 2019, doi: [*10.1093/gerona/glz017*](https://doi.org/10.1093/gerona/glz017).


H. Quan *et al.*, “Coding Algorithms for Defining Comorbidities in ICD-9-CM and ICD-10 Administrative Data:,” *Medical Care*, vol. 43, no. 11, pp. 1130–1139, Nov. 2005, doi: [*10.1097/01.mlr.0000182534.19832.83*](https://doi.org/10.1097/01.mlr.0000182534.19832.83).


K. Rockwood, “A global clinical measure of fitness and frailty in elderly people,” *Canadian Medical Association Journal*, vol. 173, no. 5, pp. 489–495, Aug. 2005, doi: [*10.1503/cmaj.050051*](https://doi.org/10.1503/cmaj.050051).


K. Rockwood, M. Andrew, and A. Mitnitski, “A Comparison of Two Approaches to Measuring Frailty in Elderly People,” *The Journals of Gerontology Series A: Biological Sciences and Medical Sciences*, vol. 62, no. 7, pp. 738–743, Jul. 2007, doi: [*10.1093/gerona/62.7.738*](https://doi.org/10.1093/gerona/62.7.738).


K. Rockwood and A. Mitnitski, “Frailty in Relation to the Accumulation of Deficits,” *The Journals of Gerontology Series A: Biological Sciences and Medical Sciences*, vol. 62, no. 7, pp. 722–727, Jul. 2007, doi: [*10.1093/gerona/62.7.722*](https://doi.org/10.1093/gerona/62.7.722).


K. Rockwood, A. Mitnitski, X. Song, B. Steen, and I. Skoog, “Long-Term Risks of Death and Institutionalization of Elderly People in Relation to Deficit Accumulation at Age 70: LONG-TERM RISK OF DEATH DEFINED BY AGE 70,” *Journal of the American Geriatrics Society*, vol. 54, no. 6, pp. 975–979, Jun. 2006, doi: [*10.1111/j.1532-5415.2006.00738.x*](https://doi.org/10.1111/j.1532-5415.2006.00738.x).


M. Tonelli *et al.*, “Methods for identifying 30 chronic conditions: application to administrative data,” *BMC Med Inform Decis Mak*, vol. 15, no. 1, p. 31, Jan. 2016, doi: [*10.1186/s12911-015-0155-5*](https://doi.org/10.1186/s12911-015-0155-5).


J. Weaver, S. Sajjan, E. M. Lewiecki, and S. T. Harris, “Diagnosis and Treatment of Osteoporosis Before and After Fracture: A Side-by-Side Analysis of Commercially Insured and Medicare Advantage Osteoporosis Patients,” *JMCP*, vol. 23, no. 7, pp. 735–744, Jul. 2017, doi: [*10.18553/jmcp.2017.23.7.735*](https://doi.org/10.18553/jmcp.2017.23.7.735).


F. G. Peña *et al.*, “Comparison of alternate scoring of variables on the performance of the frailty index,” *BMC Geriatr*, vol. 14, no. 1, p. 25, Dec. 2014, doi: [*10.1186/1471-2318-14-25*](https://doi.org/10.1186/1471-2318-14-25).



S. D. Searle, A. Mitnitski, E. A. Gahbauer, T. M. Gill, and K. Rockwood, “A standard procedure for creating a frailty index,” *BMC Geriatr*, vol. 8, no. 1, p. 24, Dec. 2008, doi: [*10.1186/1471-2318-8-24*](https://doi.org/10.1186/1471-2318-8-24).
