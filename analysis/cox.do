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
mkspline calendar_day_spline = calendar_day, cubic nknots(4)
stcox drug age_spline* i.sex calendar_day_spline*, strata(region_covid_therapeutics)
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * drug_se)
local upper_ci = exp(b[1,1] + 1.96 * drug_se)
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel A2 = "`drug_coef' (`lower_ci'-`upper_ci')"  B2="`p'"


clear
import excel ./output/cox.xlsx, sheet("Sheet1") firstrow
export delimited using ./output/cox.csv, replace



log close
