
********************************************************************************
*
*	Do-file:		psw_check.do
**
*	Programmed by:	Bang Zheng
*
**
********************************************************************************
*
*	Purpose: This do-file implements balance check for propensity score
*   weighted Cox.
*  
********************************************************************************

* Open a log file
cap log close
log using ./logs/psw_check, replace t
clear

*export balance check*
use ./output/main.dta

do "analysis/ado/psmatch2.ado"

psmatch2 drug age_spline* i.sex i.region_covid_therapeutics solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* covid_reinfection previous_drug, logit
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
teffects ipw (failure) (drug age_spline* i.sex i.region_covid_therapeutics solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* covid_reinfection previous_drug) if _pscore!=.
tebalance summarize
putexcel set ./output/psw_check.xlsx, replace
putexcel A1=("raw_std_diff") B1=("weighted_std_diff") 
matrix results = r(table)
matrix two_columns = results[1..., 1..2]
putexcel A2=matrix(two_columns)

clear
import excel ./output/psw_check.xlsx, sheet("Sheet1") firstrow
export delimited using ./output/psw_check.csv, replace

log close
