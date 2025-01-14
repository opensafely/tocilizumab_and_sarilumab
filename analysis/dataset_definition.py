## Import ehrQL functions
from ehrql import (
    create_dataset,
    case,
    when,
    days,
    minimum_of,
)
from ehrql.codes import CTV3Code
## Import TPP tables
from ehrql.tables.tpp import (
    apcs, 
    clinical_events, 
    medications, 
    ons_deaths,
    patients,
    covid_therapeutics,
    practice_registrations,
    addresses,
    ethnicity_from_sus,
    vaccinations,
    sgss_covid_all_tests
)

## Import all codelists from codelists.py
from codelists import *

## INITIALISE the dataset and set the dummy dataset size
dataset = create_dataset()
dataset.configure_dummy_data(population_size=10000)

## exposure
tocilizumab_date = (covid_therapeutics.where(covid_therapeutics.intervention.is_in(["Tocilizumab"]))
        .where(covid_therapeutics.covid_indication.is_in(["hospitalised_with"]))
        .where(covid_therapeutics.treatment_start_date.is_on_or_between("2021-07-01","2022-02-28"))
        .sort_by(covid_therapeutics.treatment_start_date)
        .first_for_patient().treatment_start_date )
sarilumab_date = (covid_therapeutics.where(covid_therapeutics.intervention.is_in(["sarilumab"]))
        .where(covid_therapeutics.covid_indication.is_in(["hospitalised_with"]))
        .where(covid_therapeutics.treatment_start_date.is_on_or_between("2021-07-01","2022-02-28"))
        .sort_by(covid_therapeutics.treatment_start_date)
        .first_for_patient().treatment_start_date )
start_date= minimum_of(
    tocilizumab_date,
    sarilumab_date
)

has_died = (ons_deaths.date <= (start_date - days(1)))
age = patients.age_on(start_date)

dataset.define_population(~(tocilizumab_date.is_null())|~(sarilumab_date.is_null()))
dataset.tocilizumab_date=tocilizumab_date
dataset.sarilumab_date=sarilumab_date
dataset.start_date= start_date
dataset.age=age
dataset.has_died=has_died

##outcome
dataset.death_date = ons_deaths.date
dataset.death_with_covid_yes = ons_deaths.cause_of_death_is_in(covid_icd10_codes)

dataset.dereg_date = practice_registrations.where(
        practice_registrations.end_date.is_on_or_after(start_date)
    ).sort_by(practice_registrations.end_date).first_for_patient().end_date

registered = practice_registrations.for_patient_on(start_date)
dataset.out_date_dereg = registered.end_date


dataset.all_hosp_discharge = apcs.where(
        apcs.admission_date.is_on_or_before(start_date)
).sort_by(apcs.admission_date).last_for_patient().discharge_date 

dataset.all_hosp_admission = apcs.where(
        apcs.admission_date.is_on_or_before(start_date)
).sort_by(apcs.admission_date).last_for_patient().admission_date 

dataset.all_hosp_discharge2 = apcs.where(
        apcs.discharge_date.is_on_or_after(start_date)
).sort_by(apcs.discharge_date).first_for_patient().discharge_date 

dataset.all_hosp_admission2 = apcs.where(
        apcs.discharge_date.is_on_or_after(start_date)
).sort_by(apcs.discharge_date).first_for_patient().admission_date 


## covariates
dataset.sex = patients.sex

ethnicity_snomed = (
    clinical_events.where(clinical_events.snomedct_code.is_in(ethnicity_snomed_codes))
    .sort_by(clinical_events.date)
    .last_for_patient()
    .snomedct_code.to_category(ethnicity_snomed_codes))

ethnicity_sus = ethnicity_from_sus.code

dataset.ethnicity = case(
  when((ethnicity_snomed == "1") | ((ethnicity_snomed.is_null()) & (ethnicity_sus.is_in(["A", "B", "C"])))).then("White"),
  when((ethnicity_snomed == "2") | ((ethnicity_snomed.is_null()) & (ethnicity_sus.is_in(["D", "E", "F", "G"])))).then("Mixed"),
  when((ethnicity_snomed == "3") | ((ethnicity_snomed.is_null()) & (ethnicity_sus.is_in(["H", "J", "K", "L"])))).then("South Asian"),
  when((ethnicity_snomed == "4") | ((ethnicity_snomed.is_null()) & (ethnicity_sus.is_in(["M", "N", "P"])))).then("Black"),
  when((ethnicity_snomed == "5") | ((ethnicity_snomed.is_null()) & (ethnicity_sus.is_in(["R", "S"])))).then("Other"),
  otherwise="Missing", 
) 

dataset.imd_quintile = addresses.for_patient_on(start_date).imd_quintile

dataset.stp = practice_registrations.for_patient_on(start_date).practice_stp
dataset.region_nhs = practice_registrations.for_patient_on(start_date).practice_nuts1_region_name
dataset.rural_urban = addresses.for_patient_on(start_date).rural_urban_classification

dataset.region_covid_therapeutics = (covid_therapeutics.where(covid_therapeutics.treatment_start_date.is_on_or_after(start_date))
        .sort_by(covid_therapeutics.treatment_start_date)
        .first_for_patient().region )


#comorbidity
# Solid cancer 
dataset.cancer_opensafely_snomed_ever = (clinical_events.where(clinical_events.snomedct_code.is_in(solid_cancer_codes))
        .where(clinical_events.date.is_on_or_before(start_date))
        .sort_by(clinical_events.date)
        .last_for_patient().date)

# Haematological diseases
haematopoietic_stem_cell_snomed = (clinical_events.where(clinical_events.snomedct_code.is_in(haematopoietic_stem_cell_transplant_nhsd_snomed_codes))
        .where(clinical_events.date.is_on_or_before(start_date))
        .sort_by(clinical_events.date)
        .last_for_patient().date)
haematopoietic_stem_cell_icd10 = (apcs.where(
        apcs.all_diagnoses.contains_any_of(haematopoietic_stem_cell_transplant_nhsd_icd10_codes)
        ).where(
        apcs.admission_date.is_on_or_before(start_date))
        .sort_by(apcs.admission_date)
        .last_for_patient().admission_date)
haematopoietic_stem_cell_opcs4 = (apcs.where(
        apcs.all_procedures.contains_any_of(haematopoietic_stem_cell_transplant_nhsd_opcs4_codes)
        ).where(
        apcs.admission_date.is_on_or_before(start_date)
        ).sort_by(apcs.admission_date)
        .last_for_patient().admission_date)
haematological_malignancies_snomed = (clinical_events.where(clinical_events.snomedct_code.is_in(haematological_malignancies_nhsd_snomed_codes))
        .where(clinical_events.date.is_on_or_before(start_date))
        .sort_by(clinical_events.date)
        .last_for_patient().date)
haematological_malignancies_icd10 = (apcs.where(
        apcs.all_diagnoses.contains_any_of(haematological_malignancies_nhsd_icd10_codes)
        ).where(
        apcs.admission_date.is_on_or_before(start_date))
        .sort_by(apcs.admission_date)
        .last_for_patient().admission_date)
sickle_cell_disease_nhsd_snomed = (clinical_events.where(clinical_events.snomedct_code.is_in(sickle_cell_disease_nhsd_snomed_codes))
        .where(clinical_events.date.is_on_or_before(start_date))
        .sort_by(clinical_events.date)
        .last_for_patient().date)
sickle_cell_disease_nhsd_icd10 = (apcs.where(
        apcs.all_diagnoses.contains_any_of(sickle_cell_disease_nhsd_icd10_codes)
        ).where(
        apcs.admission_date.is_on_or_before(start_date))
        .sort_by(apcs.admission_date)
        .last_for_patient().admission_date)
dataset.haematological_disease_nhsd_ever= minimum_of(
    haematopoietic_stem_cell_snomed,
    haematopoietic_stem_cell_icd10,
    haematopoietic_stem_cell_opcs4,
    haematological_malignancies_snomed,
    haematological_malignancies_icd10,
    sickle_cell_disease_nhsd_snomed,
    sickle_cell_disease_nhsd_icd10
)

# Immune-mediated inflammatory disorders (IMID)
dataset.immunosuppresant_drugs_nhsd = medications.where(
        medications.dmd_code.is_in(immunosuppresant_drugs_dmd_codes)
        ).where(
        medications.date.is_on_or_between(start_date-days(180), start_date)
        ).sort_by(
        medications.date
        ).last_for_patient().date
dataset.oral_steroid_drugs_nhsd = medications.where(
        medications.dmd_code.is_in(oral_steroid_drugs_dmd_codes)
        ).where(
        medications.date.is_on_or_between(start_date-days(365), start_date)
        ).sort_by(
        medications.date
        ).last_for_patient().date
dataset.oral_steroid_drug_nhsd_3m_count = medications.where(
        medications.dmd_code.is_in(oral_steroid_drugs_dmd_codes)
        ).where(
        medications.date.is_on_or_between(start_date-days(90), start_date)
        ).count_for_patient()
dataset.oral_steroid_drug_nhsd_12m_count = medications.where(
        medications.dmd_code.is_in(oral_steroid_drugs_dmd_codes)
        ).where(
        medications.date.is_on_or_between(start_date-days(365), start_date)
        ).count_for_patient()

# Primary immune deficiencies-updated
dataset.immunosupression_nhsd_new = (clinical_events.where(clinical_events.snomedct_code.is_in(immunosupression_nhsd_codes_new))
        .where(clinical_events.date.is_on_or_before(start_date))
        .sort_by(clinical_events.date)
        .last_for_patient().date)

# Solid organ transplant
solid_organ_nhsd_snomed_new = (clinical_events.where(clinical_events.snomedct_code.is_in(solid_organ_transplant_nhsd_snomed_codes_new))
        .where(clinical_events.date.is_on_or_before(start_date))
        .sort_by(clinical_events.date)
        .last_for_patient().date)
solid_organ_transplant_nhsd_opcs4 = (apcs.where(
        apcs.all_procedures.contains_any_of(solid_organ_transplant_nhsd_opcs4_codes)
        ).where(
        apcs.admission_date.is_on_or_before(start_date))
        .sort_by(apcs.admission_date)
        .last_for_patient().admission_date)
transplant_all_y_codes_opcs4 = (apcs.where(
        apcs.all_procedures.contains_any_of(replacement_of_organ_transplant_nhsd_opcs4_codes)
        ).where(
        apcs.admission_date.is_on_or_before(start_date))
        .sort_by(apcs.admission_date)
        .last_for_patient().admission_date)
transplant_thymus_opcs4 = (apcs.where(
        apcs.all_procedures.contains_any_of(thymus_gland_transplant_nhsd_opcs4_codes)
        ).where(
        apcs.admission_date.is_on_or_between(transplant_all_y_codes_opcs4,transplant_all_y_codes_opcs4))
        .sort_by(apcs.admission_date)
        .last_for_patient().admission_date)
transplant_conjunctiva_y_code_opcs4 = (apcs.where(
        apcs.all_procedures.contains_any_of(conjunctiva_y_codes_transplant_nhsd_opcs4_codes)
        ).where(
        apcs.admission_date.is_on_or_before(start_date))
        .sort_by(apcs.admission_date)
        .last_for_patient().admission_date)
transplant_conjunctiva_opcs4 = (apcs.where(
        apcs.all_procedures.contains_any_of(conjunctiva_transplant_nhsd_opcs4_codes)
        ).where(
        apcs.admission_date.is_on_or_between(transplant_conjunctiva_y_code_opcs4,transplant_conjunctiva_y_code_opcs4))
        .sort_by(apcs.admission_date)
        .last_for_patient().admission_date)
transplant_stomach_opcs4 = (apcs.where(
        apcs.all_procedures.contains_any_of(stomach_transplant_nhsd_opcs4_codes)
        ).where(
        apcs.admission_date.is_on_or_between(transplant_all_y_codes_opcs4,transplant_all_y_codes_opcs4))
        .sort_by(apcs.admission_date)
        .last_for_patient().admission_date)
transplant_ileum_1_Y_codes_opcs4 = (apcs.where(
        apcs.all_procedures.contains_any_of(ileum_1_y_codes_transplant_nhsd_opcs4_codes)
        ).where(
        apcs.admission_date.is_on_or_before(start_date))
        .sort_by(apcs.admission_date)
        .last_for_patient().admission_date)
transplant_ileum_2_Y_codes_opcs4 = (apcs.where(
        apcs.all_procedures.contains_any_of(ileum_2_y_codes_transplant_nhsd_opcs4_codes)
        ).where(
        apcs.admission_date.is_on_or_before(start_date))
        .sort_by(apcs.admission_date)
        .last_for_patient().admission_date)
transplant_ileum_1_opcs4 = (apcs.where(
        apcs.all_procedures.contains_any_of(ileum_1_transplant_nhsd_opcs4_codes)
        ).where(
        apcs.admission_date.is_on_or_between(transplant_ileum_1_Y_codes_opcs4,transplant_ileum_1_Y_codes_opcs4))
        .sort_by(apcs.admission_date)
        .last_for_patient().admission_date)
transplant_ileum_2_opcs4 = (apcs.where(
        apcs.all_procedures.contains_any_of(ileum_2_transplant_nhsd_opcs4_codes)
        ).where(
        apcs.admission_date.is_on_or_between(transplant_ileum_2_Y_codes_opcs4,transplant_ileum_2_Y_codes_opcs4))
        .sort_by(apcs.admission_date)
        .last_for_patient().admission_date)
  
dataset.solid_organ_transplant_nhsd_new = minimum_of(solid_organ_nhsd_snomed_new, solid_organ_transplant_nhsd_opcs4,
                                                    transplant_thymus_opcs4, transplant_conjunctiva_opcs4, transplant_stomach_opcs4,
                                                    transplant_ileum_1_opcs4,transplant_ileum_2_opcs4)

# Renal disease
ckd_stage_5_nhsd_snomed = (clinical_events.where(clinical_events.snomedct_code.is_in(ckd_stage_5_nhsd_snomed_codes))
        .where(clinical_events.date.is_on_or_before(start_date))
        .sort_by(clinical_events.date)
        .last_for_patient().date)
ckd_stage_5_nhsd_icd10 = (apcs.where(
        apcs.all_diagnoses.contains_any_of(ckd_stage_5_nhsd_icd10_codes)
        ).where(
        apcs.admission_date.is_on_or_before(start_date))
        .sort_by(apcs.admission_date)
        .last_for_patient().admission_date)
dataset.ckd_stage_5_nhsd = minimum_of(ckd_stage_5_nhsd_snomed, ckd_stage_5_nhsd_icd10)

# CKD DEFINITIONS - adapted from https://github.com/opensafely/risk-factors-research
dataset.ckd_stages_3_5 = (clinical_events.where(clinical_events.snomedct_code.is_in(chronic_kidney_disease_stages_3_5_codes))
        .where(clinical_events.date.is_on_or_before(start_date))
        .sort_by(clinical_events.date)
        .last_for_patient().date)
dataset.ckd_primis_stage=(clinical_events.where(clinical_events.snomedct_code.is_in(primis_ckd_stage))
        .where(clinical_events.date.is_on_or_before(start_date))
        .sort_by(clinical_events.date)
        .last_for_patient().date)
dataset.ckd3_icd10 = (apcs.where(
        apcs.all_diagnoses.contains("N183"))
        .where(
        apcs.admission_date.is_on_or_before(start_date))
        .sort_by(apcs.admission_date)
        .last_for_patient().admission_date)
dataset.ckd4_icd10 = (apcs.where(
        apcs.all_diagnoses.contains("N184"))
        .where(
        apcs.admission_date.is_on_or_before(start_date))
        .sort_by(apcs.admission_date)
        .last_for_patient().admission_date)
dataset.ckd5_icd10 = (apcs.where(
        apcs.all_diagnoses.contains("N185"))
        .where(
        apcs.admission_date.is_on_or_before(start_date))
        .sort_by(apcs.admission_date)
        .last_for_patient().admission_date)

# Liver disease
liver_disease_nhsd_snomed = (clinical_events.where(clinical_events.snomedct_code.is_in(liver_disease_nhsd_snomed_codes))
        .where(clinical_events.date.is_on_or_before(start_date))
        .sort_by(clinical_events.date)
        .last_for_patient().date)
liver_disease_nhsd_icd10 = (apcs.where(
        apcs.all_diagnoses.contains_any_of(liver_disease_nhsd_icd10_codes)
        ).where(
        apcs.admission_date.is_on_or_before(start_date))
        .sort_by(apcs.admission_date)
        .last_for_patient().admission_date)
dataset.liver_disease_nhsd = minimum_of(liver_disease_nhsd_snomed, liver_disease_nhsd_icd10)


# Covid-19 vaccination history
dataset.covid_vaccination_count = (
  vaccinations
  .where(vaccinations.target_disease.is_in(["SARS-2 CORONAVIRUS"]))
  .where(vaccinations.date.is_on_or_before(start_date))
  .count_for_patient()
)
dataset.last_vaccination_date = (
  vaccinations
  .where(vaccinations.target_disease.is_in(["SARS-2 CORONAVIRUS"]))
  .where(vaccinations.date.is_on_or_before(start_date))
  .sort_by(vaccinations.date)
  .last_for_patient()
  .date
)


#BMI, diabetes, hypertension, chronic heart diseases, Chronic respiratory disease
dataset.bmi = (clinical_events
        .where(clinical_events.ctv3_code == CTV3Code("22K.."))
        .where(clinical_events.date.is_on_or_before(start_date))
        .where(clinical_events.date >= patients.date_of_birth + days(
        int(365.25 * 18)))
        .sort_by(clinical_events.date)
        .last_for_patient().numeric_value)
dataset.bmi_date = (clinical_events
        .where(clinical_events.ctv3_code == CTV3Code("22K.."))
        .where(clinical_events.date.is_on_or_before(start_date))
        .where(clinical_events.date >= patients.date_of_birth + days(
        int(365.25 * 18)))
        .sort_by(clinical_events.date)
        .last_for_patient().date)

# Diabetes
dataset.diabetes = (clinical_events.where(clinical_events.snomedct_code.is_in(diabetes_codes))
        .where(clinical_events.date.is_on_or_before(start_date))
        .exists_for_patient())

# Chronic cardiac disease
dataset.chronic_cardiac_disease=(clinical_events.where(clinical_events.snomedct_code.is_in(chronic_cardiac_dis_codes))
        .where(clinical_events.date.is_on_or_before(start_date))
        .exists_for_patient())
# Hypertension
dataset.hypertension=(clinical_events.where(clinical_events.snomedct_code.is_in(hypertension_codes))
        .where(clinical_events.date.is_on_or_before(start_date))
        .exists_for_patient())
# Chronic respiratory disease
dataset.chronic_respiratory_disease=(clinical_events.where(clinical_events.snomedct_code.is_in(chronic_respiratory_dis_codes))
        .where(clinical_events.date.is_on_or_before(start_date))
        .exists_for_patient())


# COVID test
dataset.covid_test_positive_date = (sgss_covid_all_tests.where(sgss_covid_all_tests.specimen_taken_date.is_on_or_before(start_date))
  .where(sgss_covid_all_tests.is_positive)
  .sort_by(sgss_covid_all_tests.specimen_taken_date)
  .last_for_patient()
  .specimen_taken_date)
# previous positive SARS-CoV-2 test
dataset.covid_test_positive_date00 = (sgss_covid_all_tests.where(sgss_covid_all_tests.specimen_taken_date.is_on_or_before(dataset.covid_test_positive_date-days(90)))
  .where(sgss_covid_all_tests.is_positive)
  .sort_by(sgss_covid_all_tests.specimen_taken_date)
  .last_for_patient()
  .specimen_taken_date)

# First COVID-19 event in primary care
dataset.covid_primary_care_date = (clinical_events
        .where(clinical_events.ctv3_code.is_in(covid_primary_code))
        .where(clinical_events.date.is_on_or_between("2020-01-01",start_date))
        .sort_by(clinical_events.date)
        .last_for_patient().date)
dataset.covid_primary_care_date00 = (clinical_events
        .where(clinical_events.ctv3_code.is_in(covid_primary_code))
        .where(clinical_events.date.is_on_or_between("2020-01-01",start_date-days(90)))
        .sort_by(clinical_events.date)
        .last_for_patient().date)


#previous covid drug
dataset.previous_drug = (covid_therapeutics.where(covid_therapeutics.treatment_start_date.is_before(start_date))
        .sort_by(covid_therapeutics.treatment_start_date)
        .last_for_patient().treatment_start_date)
dataset.previous_drug00 = (covid_therapeutics.where(covid_therapeutics.treatment_start_date.is_on_or_before(start_date-days(90)))
        .sort_by(covid_therapeutics.treatment_start_date)
        .last_for_patient().treatment_start_date)


#previous covid hosp
dataset.previous_hosp = (apcs.where(
        apcs.all_diagnoses.contains_any_of(covid_icd10_codes))
        .where(
        apcs.admission_date.is_before(dataset.all_hosp_admission)
        ).sort_by(apcs.admission_date).last_for_patient().admission_date) 
dataset.previous_hosp00 = (apcs.where(
        apcs.all_diagnoses.contains_any_of(covid_icd10_codes))
        .where(
        apcs.admission_date.is_before(start_date-days(90))
        ).sort_by(apcs.admission_date).last_for_patient().admission_date )