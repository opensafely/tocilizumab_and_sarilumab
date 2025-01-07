from ehrql import codelist_from_csv

covid_icd10_codes = ["U071", "U072", "U109", "U099"]

ethnicity_snomed_codes = codelist_from_csv(
  "codelists/opensafely-ethnicity-snomed-0removed-2e641f61.csv",
  column = "snomedcode",
  category_column="Grouping_6",
)

### Solid cancer
non_haematological_cancer_opensafely_snomed_codes_new = codelist_from_csv(
  "codelists/user-bangzheng-cancer-excluding-lung-and-haematological-snomed-new.csv",
  column = "code",
)

lung_cancer_opensafely_snomed_codes = codelist_from_csv(
  "codelists/opensafely-lung-cancer-snomed.csv", 
  column = "id"
)

chemotherapy_radiotherapy_opensafely_snomed_codes = codelist_from_csv(
  "codelists/opensafely-chemotherapy-or-radiotherapy-snomed.csv", 
  column = "id"
)

solid_cancer_codes=non_haematological_cancer_opensafely_snomed_codes_new+lung_cancer_opensafely_snomed_codes+chemotherapy_radiotherapy_opensafely_snomed_codes


### Patients with a haematological diseases
haematopoietic_stem_cell_transplant_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-haematopoietic-stem-cell-transplant-snomed.csv", 
  column = "code"
)

haematopoietic_stem_cell_transplant_nhsd_icd10_codes = codelist_from_csv(
  "codelists/nhsd-haematopoietic-stem-cell-transplant-icd-10.csv", 
  column = "code"
)

haematopoietic_stem_cell_transplant_nhsd_opcs4_codes = codelist_from_csv(
  "codelists/nhsd-haematopoietic-stem-cell-transplant-opcs4.csv", 
  column = "code"
)

haematological_malignancies_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-haematological-malignancies-snomed.csv",
  column = "code"
)

haematological_malignancies_nhsd_icd10_codes = codelist_from_csv(
  "codelists/nhsd-haematological-malignancies-icd-10.csv", 
  column = "code"
)

sickle_cell_disease_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-sickle-spl-atriskv4-snomed-ct.csv",
  column = "code",
)

sickle_cell_disease_nhsd_icd10_codes = codelist_from_csv(
  "codelists/nhsd-sickle-spl-hes-icd-10.csv",
  column = "code",
)

### Immune-mediated inflammatory disorders (IMID)
immunosuppresant_drugs_dmd_codes = codelist_from_csv(
  "codelists/nhsd-immunosuppresant-drugs-pra-dmd.csv", 
  column = "code"
)

oral_steroid_drugs_dmd_codes = codelist_from_csv(
  "codelists/nhsd-oral-steroid-drugs-pra-dmd.csv",
  column = "dmd_id",
)

### Primary immune deficiencies
immunosupression_nhsd_codes_new = codelist_from_csv(
  "codelists/user-bangzheng-nhsd-immunosupression-pcdcluster-snomed-ct-new.csv",
  column = "code",
)

## Solid organ transplant
solid_organ_transplant_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-transplant-spl-atriskv4-snomed-ct.csv",
  column = "code",
)
solid_organ_transplant_nhsd_snomed_codes_new = codelist_from_csv(
  "codelists/user-bangzheng-nhsd-transplant-spl-atriskv4-snomed-ct-new.csv",
  column = "code",
)

solid_organ_transplant_nhsd_opcs4_codes = codelist_from_csv(
  "codelists/nhsd-transplant-spl-hes-opcs4.csv", 
  column = "code"
)

thymus_gland_transplant_nhsd_opcs4_codes = codelist_from_csv(
  "codelists/nhsd-transplant-thymus-gland-spl-hes-opcs4.csv", 
  column = "code"
)

replacement_of_organ_transplant_nhsd_opcs4_codes = codelist_from_csv(
  "codelists/nhsd-transplant-replacement-of-organ-spl-hes-opcs4.csv", 
  column = "code"
)

conjunctiva_transplant_nhsd_opcs4_codes = codelist_from_csv(
  "codelists/nhsd-transplant-conjunctiva-spl-hes-opcs4.csv", 
  column = "code"
)

conjunctiva_y_codes_transplant_nhsd_opcs4_codes = codelist_from_csv(
  "codelists/nhsd-transplant-conjunctiva-y-codes-spl-hes-opcs4.csv", 
  column = "code"
)

stomach_transplant_nhsd_opcs4_codes = codelist_from_csv(
  "codelists/nhsd-transplant-stomach-spl-hes-opcs4.csv", 
  column = "code"
)

ileum_1_transplant_nhsd_opcs4_codes = codelist_from_csv(
  "codelists/nhsd-transplant-ileum_1-spl-hes-opcs4.csv", 
  column = "code"
)

ileum_2_transplant_nhsd_opcs4_codes = codelist_from_csv(
  "codelists/nhsd-transplant-ileum_2-spl-hes-opcs4.csv", 
  column = "code"
)

ileum_1_y_codes_transplant_nhsd_opcs4_codes = codelist_from_csv(
  "codelists/nhsd-transplant-ileum_1-y-codes-spl-hes-opcs4.csv", 
  column = "code"
)

ileum_2_y_codes_transplant_nhsd_opcs4_codes = codelist_from_csv(
  "codelists/nhsd-transplant-ileum_2-y-codes-spl-hes-opcs4.csv", 
  column = "code"
)

### Patients with renal disease
#### CKD stage 5
ckd_stage_5_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-ckd-stage-5-snomed-ct.csv", 
  column = "code"
)

ckd_stage_5_nhsd_icd10_codes = codelist_from_csv(
  "codelists/nhsd-ckd-stage-5-icd-10.csv", 
  column = "code"
)
chronic_kidney_disease_stages_3_5_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-ckd35.csv",
    column="code",
)
primis_ckd_stage = codelist_from_csv(
    "codelists/user-Louis-ckd-stage.csv",
    column="code",
    category_column="stage"
)

### Patients with liver disease
liver_disease_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-liver-cirrhosis.csv", 
  column = "code"
)

liver_disease_nhsd_icd10_codes = codelist_from_csv(
  "codelists/nhsd-liver-cirrhosis-icd-10.csv", 
  column = "code"
)

# Chronic cardiac disease
chronic_cardiac_dis_codes = codelist_from_csv(
    "codelists/opensafely-chronic-cardiac-disease-snomed.csv",
    column="id"
)
# Chronic respiratory disease
chronic_respiratory_dis_codes = codelist_from_csv(
    "codelists/opensafely-chronic-respiratory-disease-snomed.csv",
    column="id"
)
# Diabetes
diabetes_codes = codelist_from_csv(
    "codelists/opensafely-diabetes-snomed.csv",
    column="id"
)
# Hypertension
hypertension_codes = codelist_from_csv(
    "codelists/opensafely-hypertension-snomed.csv",
    column="id"
)

## COVID-19 primary care
covid_primary_care_positive_test = codelist_from_csv("codelists/opensafely-covid-identification-in-primary-care-probable-covid-positive-test.csv", column="CTV3ID")
covid_primary_care_code = codelist_from_csv("codelists/opensafely-covid-identification-in-primary-care-probable-covid-clinical-code.csv", column="CTV3ID")
covid_primary_care_sequelae = codelist_from_csv("codelists/opensafely-covid-identification-in-primary-care-probable-covid-sequelae.csv", column="CTV3ID")
covid_primary_code = covid_primary_care_positive_test+covid_primary_care_code+covid_primary_care_sequelae