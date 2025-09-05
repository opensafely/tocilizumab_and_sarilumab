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
log using ./logs/cox_subgroup2, replace t
clear

use ./output/main.dta

stset end_date ,  origin(start_date) failure(failure==1)
keep if _st==1
putexcel set ./output/cox_subgroup2.xlsx, replace
putexcel A1=("Variable") B1=("Model_HR") C1=("Model_P") D1=("BF") 

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
putexcel A32 = "poisson"  B32=("`drug_coef' (`lower_ci'-`upper_ci')") C32=("`p'")   

set seed 1000
bayes, saving(poisson1,replace): poisson _d drug age_spline* i.sex calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status covid_reinfection previous_drug i.region_covid_therapeutics ibn.interval, exposure(log_exposure) noconstant 
estimates store poisson1
bayes, saving(poisson2,replace): poisson _d age_spline* i.sex calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status covid_reinfection previous_drug i.region_covid_therapeutics ibn.interval, exposure(log_exposure)  noconstant
estimates store poisson2
bayesstats ic poisson2 poisson1
matrix result = r(ic) 
local log_BF= result[2,3]
putexcel D32=("BF=`log_BF'")   

if missing("`log_BF'")|"`log_BF'"=="."   {
    display as error "error"
    exit 198
}

clear
import excel ./output/cox_subgroup2.xlsx, sheet("Sheet1") firstrow
export delimited using ./output/cox_subgroup2.csv, replace



log close
