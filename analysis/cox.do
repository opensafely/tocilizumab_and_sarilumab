********************************************************************************
*
*	Do-file:		cox.do
**
*	Programmed by:	Bang Zheng
*
**
********************************************************************************
*
*	Purpose: This do-file implements stratified Cox regression, propensity score
*   weighted Cox, and subgroup analyses.
*  
********************************************************************************

* Open a log file
cap log close
log using ./logs/cox, replace t
clear

use ./output/main.dta

*follow-up time and events*
stset end_date ,  origin(start_date) failure(failure==1)
keep if _st==1

putexcel set ./output/cox.xlsx, replace
putexcel A1=("Model1_HR") B1=("Model1_P") C1=("Model2_HR") D1=("Model2_P") E1=("Model3_HR") F1=("Model3_P") G1=("PH_test")
tab failure drug,m col

*stratified Cox, missing values as a separate category*
*mkspline calendar_day_spline = calendar_day, cubic nknots(4)
stcox drug age_spline* i.sex calendar_day_spline*, strata(region_covid_therapeutics)
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel A2 = "`drug_coef' (`lower_ci'-`upper_ci')"  B2="`p'"

stcox drug age_spline* i.sex calendar_day_spline* b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status covid_reinfection, strata(region_covid_therapeutics)
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel C2 = "`drug_coef' (`lower_ci'-`upper_ci')"  D2="`p'"

stcox drug age_spline* i.sex calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status covid_reinfection previous_drug, strata(region_covid_therapeutics)
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel E2 = "`drug_coef' (`lower_ci'-`upper_ci')"  F2="`p'"

estat phtest
putexcel G2 = "`r(p)'"
*estat phtest, plot(1.drug)
*graph export ./output/phtest_feasibility.svg, as(svg) replace



*propensity score weighted Cox*
do "analysis/ado/psmatch2.ado"
psmatch2 drug age_spline* i.sex i.region_covid_therapeutics calendar_day_spline*, logit
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox drug
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel A3 = "`drug_coef' (`lower_ci'-`upper_ci')"  B3="`p'"

psmatch2 drug age_spline* i.sex i.region_covid_therapeutics b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* covid_reinfection, logit
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox drug
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel C3 = "`drug_coef' (`lower_ci'-`upper_ci')"  D3="`p'"

psmatch2 drug age_spline* i.sex solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* covid_reinfection previous_drug, logit
histogram _pscore, by(drug, col(1))
graph export ./output/psgraph.svg, as(svg) replace
drop psweight
gen psweight=cond( drug ==1,1/_pscore,1/(1-_pscore)) if _pscore!=.
sum psweight,de
by drug, sort: sum _pscore ,de
*teffects ipw (failure) (drug age_spline* i.sex solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status calendar_day_spline* covid_reinfection previous_drug) if _pscore!=.
*tebalance summarize
stset end_date [pwei=psweight],  origin(start_date) failure(failure==1)
stcox drug
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel E3 = "`drug_coef' (`lower_ci'-`upper_ci')"  F3="`p'"

*secondary outcomes*
*90 day death*
stset end_date_90d ,  origin(start_date) failure(failure_90d==1)
*stratified Cox, missing values as a separate category*
stcox drug age_spline* i.sex  calendar_day_spline* , strata(region_covid_therapeutics)
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel A4 = "`drug_coef' (`lower_ci'-`upper_ci')"  B4="`p'"

stcox drug age_spline* i.sex b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection, strata(region_covid_therapeutics)
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel C4 = "`drug_coef' (`lower_ci'-`upper_ci')"  D4="`p'"

stcox drug age_spline* i.sex solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_group4 b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection previous_drug, strata(region_covid_therapeutics)
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel E4 = "`drug_coef' (`lower_ci'-`upper_ci')"  F4="`p'"

*180 day death*
stset end_date_180d ,  origin(start_date) failure(failure_180d==1)
*stratified Cox, missing values as a separate category*
stcox drug age_spline* i.sex  calendar_day_spline* , strata(region_covid_therapeutics)
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel A5 = "`drug_coef' (`lower_ci'-`upper_ci')"  B5="`p'"

stcox drug age_spline* i.sex b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection, strata(region_covid_therapeutics)
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel C5 = "`drug_coef' (`lower_ci'-`upper_ci')"  D5="`p'"

stcox drug age_spline* i.sex solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_group4 b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection previous_drug, strata(region_covid_therapeutics)
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel E5 = "`drug_coef' (`lower_ci'-`upper_ci')"  F5="`p'"

*1 y death*
stset end_date_1y ,  origin(start_date) failure(failure_1y==1)
*stratified Cox, missing values as a separate category*
stcox drug age_spline* i.sex  calendar_day_spline* , strata(region_covid_therapeutics)
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel A6 = "`drug_coef' (`lower_ci'-`upper_ci')"  B6="`p'"

stcox drug age_spline* i.sex b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection, strata(region_covid_therapeutics)
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel C6 = "`drug_coef' (`lower_ci'-`upper_ci')"  D6="`p'"

stcox drug age_spline* i.sex solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_group4 b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection previous_drug, strata(region_covid_therapeutics)
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel E6 = "`drug_coef' (`lower_ci'-`upper_ci')"  F6="`p'"

*2 y death*
stset end_date_2y ,  origin(start_date) failure(failure_2y==1)
*stratified Cox, missing values as a separate category*
stcox drug age_spline* i.sex  calendar_day_spline* , strata(region_covid_therapeutics)
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel A7 = "`drug_coef' (`lower_ci'-`upper_ci')"  B7="`p'"

stcox drug age_spline* i.sex b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection, strata(region_covid_therapeutics)
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel C7 = "`drug_coef' (`lower_ci'-`upper_ci')"  D7="`p'"

stcox drug age_spline* i.sex solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_group4 b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection previous_drug, strata(region_covid_therapeutics)
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel E7 = "`drug_coef' (`lower_ci'-`upper_ci')"  F7="`p'"

*discharge*
stset end_date_discharge ,  origin(start_date) failure(event_discharge==1)
*stratified Cox, missing values as a separate category*
stcox drug age_spline* i.sex  calendar_day_spline* , strata(region_covid_therapeutics)
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel A8 = "`drug_coef' (`lower_ci'-`upper_ci')"  B8="`p'"

stcox drug age_spline* i.sex b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection, strata(region_covid_therapeutics)
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel C8 = "`drug_coef' (`lower_ci'-`upper_ci')"  D8="`p'"

stcox drug age_spline* i.sex solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_group4 b6.ethnicity b5.imd i.vaccination_status calendar_day_spline* covid_reinfection previous_drug, strata(region_covid_therapeutics)
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel E8 = "`drug_coef' (`lower_ci'-`upper_ci')"  F8="`p'"


clear
import excel ./output/cox.xlsx, sheet("Sheet1") firstrow
export delimited using ./output/cox.csv, replace



log close
