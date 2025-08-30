********************************************************************************
*
*	Do-file:		cox_subgroup.do
**
*	Programmed by:	Bang Zheng
*
**
********************************************************************************
*
*	Purpose: This do-file implements sensitivity and subgroup analyses.
*  
********************************************************************************

* Open a log file
cap log close
log using ./logs/cox_subgroup, replace t
clear

use ./output/main.dta

*subgroup analysis*
stset end_date ,  origin(start_date) failure(failure==1)
keep if _st==1
putexcel set ./output/cox_subgroup.xlsx, replace
putexcel A1=("Variable") B1=("level") C1=("N") D1=("events") E1=("Model_HR") F1=("Model_P") G1=("P_interaction") H1=("N_toci") I1=("events_toci") J1=("N_sari") K1=("events_sari")

stcox i.drug##i.omicron age_spline* i.sex solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status  covid_reinfection previous_drug, strata(region_covid_therapeutics)
matrix result = r(table) 
local p= result[4,8]
putexcel A2=("omicron")  G2=("`p'") 
stcox drug age_spline* i.sex solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status  covid_reinfection previous_drug if omicron==0, strata(region_covid_therapeutics)
matrix result = r(table) 
local drug_coef = result[1,1]
local lower_ci = result[5,1]
local upper_ci = result[6,1]
local p= result[4,1]
if `e(N_sub)' <= 7 {
        local N_sub = "<=7"
    }
else {
        local N_sub = round(`e(N_sub)',5)
    }
if `e(N_fail)' <= 7 {
        local N_fail = "<=7"
    }
else {
        local N_fail = round(`e(N_fail)',5)
    }
count if _st==1&drug==0
if r(N) <= 7 {
        local N_toci = "<=7"
    }
else {
        local N_toci = round(r(N),5)
    }
count if _st==1&drug==1
if r(N) <= 7 {
        local N_sari = "<=7"
    }
else {
        local N_sari = round(r(N),5)
    }
count if _st==1&_d==1&drug==0
if r(N) <= 7 {
        local d_toci = "<=7"
    }
else {
        local d_toci = round(r(N),5)
    }
count if _st==1&_d==1&drug==1
if r(N) <= 7 {
        local d_sari = "<=7"
    }
else {
        local d_sari = round(r(N),5)
    }
putexcel B2=("0") C2=("`N_sub'") D2=("`N_fail'") E2=("`drug_coef' (`lower_ci'-`upper_ci')") F2=("`p'") H2=("`N_toci'") I2=("`d_toci'") J2=("`N_sari'") K2=("`d_sari'") 


stcox drug age_spline* i.sex solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status  covid_reinfection previous_drug if omicron==1, strata(region_covid_therapeutics)
matrix result = r(table) 
local drug_coef = result[1,1]
local lower_ci = result[5,1]
local upper_ci = result[6,1]
local p= result[4,1]
if `e(N_sub)' <= 7 {
        local N_sub = "<=7"
    }
else {
        local N_sub = round(`e(N_sub)',5)
    }
if `e(N_fail)' <= 7 {
        local N_fail = "<=7"
    }
else {
        local N_fail = round(`e(N_fail)',5)
    }
count if _st==1&drug==0
if r(N) <= 7 {
        local N_toci = "<=7"
    }
else {
        local N_toci = round(r(N),5)
    }
count if _st==1&drug==1
if r(N) <= 7 {
        local N_sari = "<=7"
    }
else {
        local N_sari = round(r(N),5)
    }
count if _st==1&_d==1&drug==0
if r(N) <= 7 {
        local d_toci = "<=7"
    }
else {
        local d_toci = round(r(N),5)
    }
count if _st==1&_d==1&drug==1
if r(N) <= 7 {
        local d_sari = "<=7"
    }
else {
        local d_sari = round(r(N),5)
    }
putexcel A3=("omicron") B3=("1") C3=("`N_sub'") D3=("`N_fail'") E3=("`drug_coef' (`lower_ci'-`upper_ci')") F3=("`p'") H3=("`N_toci'") I3=("`d_toci'") J3=("`N_sari'") K3=("`d_sari'") 

stcox i.drug##i.sex age_spline* calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status  covid_reinfection previous_drug, strata(region_covid_therapeutics)
matrix result = r(table) 
local p= result[4,8]
putexcel A4=("sex")  G4=("`p'") 
stcox drug  age_spline* calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status  covid_reinfection previous_drug if sex==0, strata(region_covid_therapeutics)
matrix result = r(table) 
local drug_coef = result[1,1]
local lower_ci = result[5,1]
local upper_ci = result[6,1]
local p= result[4,1]
if `e(N_sub)' <= 7 {
        local N_sub = "<=7"
    }
else {
        local N_sub = round(`e(N_sub)',5)
    }
if `e(N_fail)' <= 7 {
        local N_fail = "<=7"
    }
else {
        local N_fail = round(`e(N_fail)',5)
    }
count if _st==1&drug==0
if r(N) <= 7 {
        local N_toci = "<=7"
    }
else {
        local N_toci = round(r(N),5)
    }
count if _st==1&drug==1
if r(N) <= 7 {
        local N_sari = "<=7"
    }
else {
        local N_sari = round(r(N),5)
    }
count if _st==1&_d==1&drug==0
if r(N) <= 7 {
        local d_toci = "<=7"
    }
else {
        local d_toci = round(r(N),5)
    }
count if _st==1&_d==1&drug==1
if r(N) <= 7 {
        local d_sari = "<=7"
    }
else {
        local d_sari = round(r(N),5)
    }
putexcel B4=("0") C4=("`N_sub'") D4=("`N_fail'") E4=("`drug_coef' (`lower_ci'-`upper_ci')") F4=("`p'") H4=("`N_toci'") I4=("`d_toci'") J4=("`N_sari'") K4=("`d_sari'") 
stcox drug  age_spline* calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status  covid_reinfection previous_drug if sex==1, strata(region_covid_therapeutics)
matrix result = r(table) 
local drug_coef = result[1,1]
local lower_ci = result[5,1]
local upper_ci = result[6,1]
local p= result[4,1]
if `e(N_sub)' <= 7 {
        local N_sub = "<=7"
    }
else {
        local N_sub = round(`e(N_sub)',5)
    }
if `e(N_fail)' <= 7 {
        local N_fail = "<=7"
    }
else {
        local N_fail = round(`e(N_fail)',5)
    }
count if _st==1&drug==0
if r(N) <= 7 {
        local N_toci = "<=7"
    }
else {
        local N_toci = round(r(N),5)
    }
count if _st==1&drug==1
if r(N) <= 7 {
        local N_sari = "<=7"
    }
else {
        local N_sari = round(r(N),5)
    }
count if _st==1&_d==1&drug==0
if r(N) <= 7 {
        local d_toci = "<=7"
    }
else {
        local d_toci = round(r(N),5)
    }
count if _st==1&_d==1&drug==1
if r(N) <= 7 {
        local d_sari = "<=7"
    }
else {
        local d_sari = round(r(N),5)
    }
putexcel A5=("sex") B5=("1") C5=("`N_sub'") D5=("`N_fail'") E5=("`drug_coef' (`lower_ci'-`upper_ci')") F5=("`p'") H5=("`N_toci'") I5=("`d_toci'") J5=("`N_sari'") K5=("`d_sari'") 

stcox i.drug##i.age_60 i.sex calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status  covid_reinfection previous_drug, strata(region_covid_therapeutics)
matrix result = r(table) 
local p= result[4,8]
putexcel A6=("age")  G6=("`p'") 
stcox drug i.sex calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status  covid_reinfection previous_drug if age_60==0, strata(region_covid_therapeutics)
matrix result = r(table) 
local drug_coef = result[1,1]
local lower_ci = result[5,1]
local upper_ci = result[6,1]
local p= result[4,1]
if `e(N_sub)' <= 7 {
        local N_sub = "<=7"
    }
else {
        local N_sub = round(`e(N_sub)',5)
    }
if `e(N_fail)' <= 7 {
        local N_fail = "<=7"
    }
else {
        local N_fail = round(`e(N_fail)',5)
    }
count if _st==1&drug==0
if r(N) <= 7 {
        local N_toci = "<=7"
    }
else {
        local N_toci = round(r(N),5)
    }
count if _st==1&drug==1
if r(N) <= 7 {
        local N_sari = "<=7"
    }
else {
        local N_sari = round(r(N),5)
    }
count if _st==1&_d==1&drug==0
if r(N) <= 7 {
        local d_toci = "<=7"
    }
else {
        local d_toci = round(r(N),5)
    }
count if _st==1&_d==1&drug==1
if r(N) <= 7 {
        local d_sari = "<=7"
    }
else {
        local d_sari = round(r(N),5)
    }
putexcel B6=("0") C6=("`N_sub'") D6=("`N_fail'") E6=("`drug_coef' (`lower_ci'-`upper_ci')") F6=("`p'") H6=("`N_toci'") I6=("`d_toci'") J6=("`N_sari'") K6=("`d_sari'") 
stcox drug i.sex calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status  covid_reinfection previous_drug if age_60==1, strata(region_covid_therapeutics)
matrix result = r(table) 
local drug_coef = result[1,1]
local lower_ci = result[5,1]
local upper_ci = result[6,1]
local p= result[4,1]
if `e(N_sub)' <= 7 {
        local N_sub = "<=7"
    }
else {
        local N_sub = round(`e(N_sub)',5)
    }
if `e(N_fail)' <= 7 {
        local N_fail = "<=7"
    }
else {
        local N_fail = round(`e(N_fail)',5)
    }
count if _st==1&drug==0
if r(N) <= 7 {
        local N_toci = "<=7"
    }
else {
        local N_toci = round(r(N),5)
    }
count if _st==1&drug==1
if r(N) <= 7 {
        local N_sari = "<=7"
    }
else {
        local N_sari = round(r(N),5)
    }
count if _st==1&_d==1&drug==0
if r(N) <= 7 {
        local d_toci = "<=7"
    }
else {
        local d_toci = round(r(N),5)
    }
count if _st==1&_d==1&drug==1
if r(N) <= 7 {
        local d_sari = "<=7"
    }
else {
        local d_sari = round(r(N),5)
    }
putexcel A7=("age") B7=("1") C7=("`N_sub'") D7=("`N_fail'") E7=("`drug_coef' (`lower_ci'-`upper_ci')") F7=("`p'") H7=("`N_toci'") I7=("`d_toci'") J7=("`N_sari'") K7=("`d_sari'") 

stcox i.drug##i.White i.sex age_spline* calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b5.imd_with_missing i.vaccination_status  covid_reinfection previous_drug, strata(region_covid_therapeutics)
matrix result = r(table) 
local p= result[4,8]
putexcel A8=("White")  G8=("`p'") 
stcox drug i.sex age_spline* calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b5.imd_with_missing i.vaccination_status  covid_reinfection previous_drug if White==0, strata(region_covid_therapeutics)
matrix result = r(table) 
local drug_coef = result[1,1]
local lower_ci = result[5,1]
local upper_ci = result[6,1]
local p= result[4,1]
if `e(N_sub)' <= 7 {
        local N_sub = "<=7"
    }
else {
        local N_sub = round(`e(N_sub)',5)
    }
if `e(N_fail)' <= 7 {
        local N_fail = "<=7"
    }
else {
        local N_fail = round(`e(N_fail)',5)
    }
count if _st==1&drug==0
if r(N) <= 7 {
        local N_toci = "<=7"
    }
else {
        local N_toci = round(r(N),5)
    }
count if _st==1&drug==1
if r(N) <= 7 {
        local N_sari = "<=7"
    }
else {
        local N_sari = round(r(N),5)
    }
count if _st==1&_d==1&drug==0
if r(N) <= 7 {
        local d_toci = "<=7"
    }
else {
        local d_toci = round(r(N),5)
    }
count if _st==1&_d==1&drug==1
if r(N) <= 7 {
        local d_sari = "<=7"
    }
else {
        local d_sari = round(r(N),5)
    }
putexcel B8=("0") C8=("`N_sub'") D8=("`N_fail'") E8=("`drug_coef' (`lower_ci'-`upper_ci')") F8=("`p'") H8=("`N_toci'") I8=("`d_toci'") J8=("`N_sari'") K8=("`d_sari'") 
stcox drug i.sex age_spline* calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b5.imd_with_missing i.vaccination_status  covid_reinfection previous_drug if White==1, strata(region_covid_therapeutics)
matrix result = r(table) 
local drug_coef = result[1,1]
local lower_ci = result[5,1]
local upper_ci = result[6,1]
local p= result[4,1]
if `e(N_sub)' <= 7 {
        local N_sub = "<=7"
    }
else {
        local N_sub = round(`e(N_sub)',5)
    }
if `e(N_fail)' <= 7 {
        local N_fail = "<=7"
    }
else {
        local N_fail = round(`e(N_fail)',5)
    }
count if _st==1&drug==0
if r(N) <= 7 {
        local N_toci = "<=7"
    }
else {
        local N_toci = round(r(N),5)
    }
count if _st==1&drug==1
if r(N) <= 7 {
        local N_sari = "<=7"
    }
else {
        local N_sari = round(r(N),5)
    }
count if _st==1&_d==1&drug==0
if r(N) <= 7 {
        local d_toci = "<=7"
    }
else {
        local d_toci = round(r(N),5)
    }
count if _st==1&_d==1&drug==1
if r(N) <= 7 {
        local d_sari = "<=7"
    }
else {
        local d_sari = round(r(N),5)
    }
putexcel A9=("White") B9=("1") C9=("`N_sub'") D9=("`N_fail'") E9=("`drug_coef' (`lower_ci'-`upper_ci')") F9=("`p'") H9=("`N_toci'") I9=("`d_toci'") J9=("`N_sari'") K9=("`d_sari'") 

stcox i.drug##i.vaccination_0 i.sex age_spline* calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing  covid_reinfection previous_drug, strata(region_covid_therapeutics)
matrix result = r(table) 
local p= result[4,8]
putexcel A10=("vac")  G10=("`p'") 
stcox drug i.sex age_spline* calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing  covid_reinfection previous_drug if vaccination_0==0, strata(region_covid_therapeutics)
matrix result = r(table) 
local drug_coef = result[1,1]
local lower_ci = result[5,1]
local upper_ci = result[6,1]
local p= result[4,1]
if `e(N_sub)' <= 7 {
        local N_sub = "<=7"
    }
else {
        local N_sub = round(`e(N_sub)',5)
    }
if `e(N_fail)' <= 7 {
        local N_fail = "<=7"
    }
else {
        local N_fail = round(`e(N_fail)',5)
    }
count if _st==1&drug==0
if r(N) <= 7 {
        local N_toci = "<=7"
    }
else {
        local N_toci = round(r(N),5)
    }
count if _st==1&drug==1
if r(N) <= 7 {
        local N_sari = "<=7"
    }
else {
        local N_sari = round(r(N),5)
    }
count if _st==1&_d==1&drug==0
if r(N) <= 7 {
        local d_toci = "<=7"
    }
else {
        local d_toci = round(r(N),5)
    }
count if _st==1&_d==1&drug==1
if r(N) <= 7 {
        local d_sari = "<=7"
    }
else {
        local d_sari = round(r(N),5)
    }
putexcel B10=("0") C10=("`N_sub'") D10=("`N_fail'") E10=("`drug_coef' (`lower_ci'-`upper_ci')") F10=("`p'") H10=("`N_toci'") I10=("`d_toci'") J10=("`N_sari'") K10=("`d_sari'") 
stcox drug i.sex age_spline* calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing  covid_reinfection previous_drug if vaccination_0==1, strata(region_covid_therapeutics)
matrix result = r(table) 
local drug_coef = result[1,1]
local lower_ci = result[5,1]
local upper_ci = result[6,1]
local p= result[4,1]
if `e(N_sub)' <= 7 {
        local N_sub = "<=7"
    }
else {
        local N_sub = round(`e(N_sub)',5)
    }
if `e(N_fail)' <= 7 {
        local N_fail = "<=7"
    }
else {
        local N_fail = round(`e(N_fail)',5)
    }
count if _st==1&drug==0
if r(N) <= 7 {
        local N_toci = "<=7"
    }
else {
        local N_toci = round(r(N),5)
    }
count if _st==1&drug==1
if r(N) <= 7 {
        local N_sari = "<=7"
    }
else {
        local N_sari = round(r(N),5)
    }
count if _st==1&_d==1&drug==0
if r(N) <= 7 {
        local d_toci = "<=7"
    }
else {
        local d_toci = round(r(N),5)
    }
count if _st==1&_d==1&drug==1
if r(N) <= 7 {
        local d_sari = "<=7"
    }
else {
        local d_sari = round(r(N),5)
    }
putexcel A11=("vac") B11=("1") C11=("`N_sub'") D11=("`N_fail'") E11=("`drug_coef' (`lower_ci'-`upper_ci')") F11=("`p'") H11=("`N_toci'") I11=("`d_toci'") J11=("`N_sari'") K11=("`d_sari'") 

stcox i.drug##i.bmi_30 i.sex age_spline* calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status  covid_reinfection previous_drug, strata(region_covid_therapeutics)
matrix result = r(table) 
local p= result[4,8]
putexcel A12=("bmi")  G12=("`p'") 
stcox drug i.sex age_spline* calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status  covid_reinfection previous_drug if bmi_30==0, strata(region_covid_therapeutics)
matrix result = r(table) 
local drug_coef = result[1,1]
local lower_ci = result[5,1]
local upper_ci = result[6,1]
local p= result[4,1]
if `e(N_sub)' <= 7 {
        local N_sub = "<=7"
    }
else {
        local N_sub = round(`e(N_sub)',5)
    }
if `e(N_fail)' <= 7 {
        local N_fail = "<=7"
    }
else {
        local N_fail = round(`e(N_fail)',5)
    }
count if _st==1&drug==0
if r(N) <= 7 {
        local N_toci = "<=7"
    }
else {
        local N_toci = round(r(N),5)
    }
count if _st==1&drug==1
if r(N) <= 7 {
        local N_sari = "<=7"
    }
else {
        local N_sari = round(r(N),5)
    }
count if _st==1&_d==1&drug==0
if r(N) <= 7 {
        local d_toci = "<=7"
    }
else {
        local d_toci = round(r(N),5)
    }
count if _st==1&_d==1&drug==1
if r(N) <= 7 {
        local d_sari = "<=7"
    }
else {
        local d_sari = round(r(N),5)
    }
putexcel B12=("0") C12=("`N_sub'") D12=("`N_fail'") E12=("`drug_coef' (`lower_ci'-`upper_ci')") F12=("`p'") H12=("`N_toci'") I12=("`d_toci'") J12=("`N_sari'") K12=("`d_sari'") 
stcox drug i.sex age_spline* calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease  b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status  covid_reinfection previous_drug if bmi_30==1, strata(region_covid_therapeutics)
matrix result = r(table) 
local drug_coef = result[1,1]
local lower_ci = result[5,1]
local upper_ci = result[6,1]
local p= result[4,1]
if `e(N_sub)' <= 7 {
        local N_sub = "<=7"
    }
else {
        local N_sub = round(`e(N_sub)',5)
    }
if `e(N_fail)' <= 7 {
        local N_fail = "<=7"
    }
else {
        local N_fail = round(`e(N_fail)',5)
    }
count if _st==1&drug==0
if r(N) <= 7 {
        local N_toci = "<=7"
    }
else {
        local N_toci = round(r(N),5)
    }
count if _st==1&drug==1
if r(N) <= 7 {
        local N_sari = "<=7"
    }
else {
        local N_sari = round(r(N),5)
    }
count if _st==1&_d==1&drug==0
if r(N) <= 7 {
        local d_toci = "<=7"
    }
else {
        local d_toci = round(r(N),5)
    }
count if _st==1&_d==1&drug==1
if r(N) <= 7 {
        local d_sari = "<=7"
    }
else {
        local d_sari = round(r(N),5)
    }
putexcel A13=("bmi") B13=("1") C13=("`N_sub'") D13=("`N_fail'") E13=("`drug_coef' (`lower_ci'-`upper_ci')") F13=("`p'") H13=("`N_toci'") I13=("`d_toci'") J13=("`N_sari'") K13=("`d_sari'") 


local row = 14
foreach var in solid_cancer_ever haema_disease_ever imid  ///
	  diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease {
stcox c.drug##c.`var' i.sex age_spline* calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status  covid_reinfection previous_drug, strata(region_covid_therapeutics)
matrix result = r(table) 
local p= result[4,3]
putexcel A`row' = "`var'"  G`row' = "`p'"

stcox drug i.sex age_spline* calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status  covid_reinfection previous_drug if `var'==0, strata(region_covid_therapeutics)
matrix result = r(table) 
local drug_coef = result[1,1]
local lower_ci = result[5,1]
local upper_ci = result[6,1]
local p= result[4,1]
if `e(N_sub)' <= 7 {
        local N_sub = "<=7"
    }
else {
        local N_sub = round(`e(N_sub)',5)
    }
if `e(N_fail)' <= 7 {
        local N_fail = "<=7"
    }
else {
        local N_fail = round(`e(N_fail)',5)
    }
count if _st==1&drug==0
if r(N) <= 7 {
        local N_toci = "<=7"
    }
else {
        local N_toci = round(r(N),5)
    }
count if _st==1&drug==1
if r(N) <= 7 {
        local N_sari = "<=7"
    }
else {
        local N_sari = round(r(N),5)
    }
count if _st==1&_d==1&drug==0
if r(N) <= 7 {
        local d_toci = "<=7"
    }
else {
        local d_toci = round(r(N),5)
    }
count if _st==1&_d==1&drug==1
if r(N) <= 7 {
        local d_sari = "<=7"
    }
else {
        local d_sari = round(r(N),5)
    }
putexcel B`row'=("0") C`row'=("`N_sub'") D`row'=("`N_fail'") E`row'=("`drug_coef' (`lower_ci'-`upper_ci')") F`row'=("`p'") H`row'=("`N_toci'") I`row'=("`d_toci'") J`row'=("`N_sari'") K`row'=("`d_sari'") 
local row = `row' + 1

stcox drug i.sex age_spline* calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status  covid_reinfection previous_drug if `var'==1, strata(region_covid_therapeutics)
matrix result = r(table) 
local drug_coef = result[1,1]
local lower_ci = result[5,1]
local upper_ci = result[6,1]
local p= result[4,1]
if `e(N_sub)' <= 7 {
        local N_sub = "<=7"
    }
else {
        local N_sub = round(`e(N_sub)',5)
    }
if `e(N_fail)' <= 7 {
        local N_fail = "<=7"
    }
else {
        local N_fail = round(`e(N_fail)',5)
    }
count if _st==1&drug==0
if r(N) <= 7 {
        local N_toci = "<=7"
    }
else {
        local N_toci = round(r(N),5)
    }
count if _st==1&drug==1
if r(N) <= 7 {
        local N_sari = "<=7"
    }
else {
        local N_sari = round(r(N),5)
    }
count if _st==1&_d==1&drug==0
if r(N) <= 7 {
        local d_toci = "<=7"
    }
else {
        local d_toci = round(r(N),5)
    }
count if _st==1&_d==1&drug==1
if r(N) <= 7 {
        local d_sari = "<=7"
    }
else {
        local d_sari = round(r(N),5)
    }
putexcel A`row'=("`var'") B`row'=("1") C`row'=("`N_sub'") D`row'=("`N_fail'") E`row'=("`drug_coef' (`lower_ci'-`upper_ci')") F`row'=("`p'") H`row'=("`N_toci'") I`row'=("`d_toci'") J`row'=("`N_sari'") K`row'=("`d_sari'") 
local row = `row' + 1
}




*MI*
clear
use ./output/main.dta

stset end_date ,  origin(start_date) failure(failure==1)
keep if _st==1
*install ice package by changing ado filepath*
sysdir
sysdir set PLUS "analysis/ado"
sysdir set PERSONAL "analysis/ado"

set seed 1000

ice m.ethnicity m.bmi_group4  m.imd   drug age_spline* calendar_day_spline* i.sex i.region_covid_therapeutics solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease i.vaccination_status  covid_reinfection previous_drug  failure, m(5) saving(imputed,replace)  
clear
use imputed
mi import ice, imputed(ethnicity bmi_group4  imd)
mi stset end_date ,  origin(start_date) failure(failure==1)
mi estimate, hr: stcox drug age_spline* i.sex calendar_day_spline* b6.ethnicity b5.imd  i.vaccination_status covid_reinfection, strata(region_covid_therapeutics)
matrix result = r(table) 
local drug_coef = result[1,1]
local lower_ci = result[5,1]
local upper_ci = result[6,1]
local p= result[4,1]
putexcel A28 = "mi"   A29 = "mi"  B28=("Model2") B29=("Model3") E28=("`drug_coef' (`lower_ci'-`upper_ci')") F28=("`p'")   
mi estimate, hr: stcox drug age_spline* i.sex calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_group4 b6.ethnicity b5.imd i.vaccination_status covid_reinfection previous_drug, strata(region_covid_therapeutics)
matrix result = r(table) 
local drug_coef = result[1,1]
local lower_ci = result[5,1]
local upper_ci = result[6,1]
local p= result[4,1]
putexcel E29=("`drug_coef' (`lower_ci'-`upper_ci')") F29=("`p'")   



*additionally adjusting for time between last COVID-19 vaccination and treatment initiation, days between hospital admission and treatment initiation, and rural or urban area*
clear
use ./output/main.dta

stset end_date ,  origin(start_date) failure(failure==1)
keep if _st==1
sum d_admission_treat,de
replace d_admission_treat=-1 if d_admission_treat==.
stcox drug age_spline* i.sex calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status covid_reinfection previous_drug ///
admission_missing d_admission_treat i.rural_urban_with_missing i.month_after_vaccinate_missing, strata(region_covid_therapeutics)
matrix result = r(table) 
local drug_coef = result[1,1]
local lower_ci = result[5,1]
local upper_ci = result[6,1]
local p= result[4,1]
putexcel A30 = "add_adjust"  E30=("`drug_coef' (`lower_ci'-`upper_ci')") F30=("`p'")   


*COVID-specific mortality*
stset end_date ,  origin(start_date) failure(failure_covid==1)
stcox drug age_spline* i.sex calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status covid_reinfection previous_drug ///
, strata(region_covid_therapeutics)
matrix result = r(table) 
local drug_coef = result[1,1]
local lower_ci = result[5,1]
local upper_ci = result[6,1]
local p= result[4,1]
putexcel A31 = "COVID_specific_mortality"  E31=("`drug_coef' (`lower_ci'-`upper_ci')") F31=("`p'")   



*Bayesian Cox*
stset end_date ,  origin(start_date) failure(failure==1) id(patient_id)
keep if _st==1
stsplit, at(failures) riskset(interval)
gen log_exposure = _t - _t0
poisson _d drug age_spline* i.sex calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status covid_reinfection previous_drug i.region_covid_therapeutics ibn.interval, exposure(log_exposure) noconstant irr
matrix result = r(table) 
local drug_coef = result[1,1]
local lower_ci = result[5,1]
local upper_ci = result[6,1]
local p= result[4,1]
putexcel A32 = "poisson"  E32=("`drug_coef' (`lower_ci'-`upper_ci')") F32=("`p'")   

set seed 1000
bayes, saving(poisson1,replace): poisson _d drug age_spline* i.sex calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status covid_reinfection previous_drug i.region_covid_therapeutics ibn.interval, exposure(log_exposure) noconstant 
estimates store poisson1
bayes, saving(poisson2,replace): poisson _d age_spline* i.sex calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status covid_reinfection previous_drug i.region_covid_therapeutics ibn.interval, exposure(log_exposure)  noconstant
estimates store poisson2
bayesstats ic poisson2 poisson1
matrix result = r(ic) 
local log_BF= result[2,3]
putexcel G32=("BF=`log_BF'")   
matrix list result
putexcel A33="poisson_matrix[1,]"  A34="poisson_matrix[2,]"  B33=matrix(result)


clear
import excel ./output/cox_subgroup.xlsx, sheet("Sheet1") firstrow
export delimited using ./output/cox_subgroup.csv, replace



log close
