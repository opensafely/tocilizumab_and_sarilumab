********************************************************************************
*
*	Do-file:		data_preparation_and_descriptives.do
*
*	Project:		tocilizumab_and_sarilumab
*
*	Programmed by:	Bang Zheng
*
*	Data used:		output/input.csv
*
*	Data created:	output/main.dta  (main analysis dataset)
*
*	Other output:	logs/data_preparation.log
*
********************************************************************************
*
*	Purpose: This do-file creates the variables required for the 
*			 main analysis and saves into Stata dataset, and describes 
*            variables by drug groups.
*  
********************************************************************************
* Open a log file
cap log close
log using ./logs/data_preparation, replace t
clear

* import dataset
import delimited ./output/input.csv, delimiter(comma) varnames(1) case(preserve) 
*describe
codebook

*  Convert strings to dates  *
foreach var of varlist tocilizumab_date sarilumab_date start_date death_date dereg_date  all_hosp_discharge all_hosp_admission ///
		all_hosp_discharge2 all_hosp_admission2 cancer_opensafely_snomed_ever haematological_disease_nhsd_ever immunosuppresant_drugs_nhsd ///
		oral_steroid_drugs_nhsd  immunosupression_nhsd_new solid_organ_transplant_nhsd_new ckd_stage_5_nhsd ckd_stages_3_5 ckd_primis_stage ///
		ckd3_icd10 ckd4_icd10 ckd5_icd10 liver_disease_nhsd last_vaccination_date bmi_date covid_test_positive_date covid_test_positive_date00 ///
		covid_primary_care_date covid_primary_care_date00 previous_drug previous_drug00 previous_hosp previous_hosp00   {
	  capture confirm string variable `var'
	  if _rc==0 {
	  rename `var' a
	  gen `var' = date(a, "YMD")
	  drop a
	  format %td `var'
	  sum `var',f de
  }
}

putexcel set "./output/descriptives.xlsx", replace
putexcel A1=("Variable") B1=("tocilizumab") C1=("sarilumab") D1=("total") E1=("P") F1=("group_labels") G1=("count")

*exclusion*
keep if start_date>=mdy(07,01,2021)&start_date<=mdy(02,28,2022)
count
if r(N) <= 7 {
        local result = "<=7"
    }
    else {
        local result = round(r(N),5)
    }
putexcel G2="`result'"
sum age,de
keep if age>=18 & age<110
count
if r(N) <= 7 {
        local result = "<=7"
    }
    else {
        local result = round(r(N),5)
    }
putexcel G3="`result'"
tab sex,m
keep if sex=="female"|sex=="male"
*keep if has_died==0
keep if region_nhs!=""|region_covid_therapeutics!=""
count
if r(N) <= 7 {
        local result = "<=7"
    }
    else {
        local result = round(r(N),5)
    }
putexcel G4="`result'"
drop if start_date>=death_date
count
if r(N) <= 7 {
        local result = "<=7"
    }
    else {
        local result = round(r(N),5)
    }
putexcel G5="`result'"
drop if tocilizumab_date==sarilumab_date
gen drug=1 if sarilumab_date==start_date
replace drug=0 if tocilizumab_date ==start_date
label define drug 1 "sarilumab" 0 "tocilizumab"
label values drug drug
tab drug,m


count
if r(N) <= 7 {
        local result = "<=7"
    }
    else {
        local result = round(r(N),5)
    }
putexcel A2=("N") D2="`result'"
count if drug==0
if r(N) <= 7 {
        local result = "<=7"
    }
    else {
        local result = round(r(N),5)
    }
putexcel B2="`result'"
count if drug==1
if r(N) <= 7 {
        local result = "<=7"
    }
    else {
        local result = round(r(N),5)
    }
putexcel C2="`result'"

*define outcome and follow-up time*
gen study_end_date=mdy(02,28,2024)
gen start_date_28=start_date+28
*primary outcome*
gen failure=(death_date!=.&death_date<=min(study_end_date,start_date_28))
tab drug failure,m
gen end_date=death_date if failure==1
replace end_date=min(study_end_date, start_date_28) if failure==0
format %td  end_date study_end_date start_date_28
gen failure_covid=(failure==1&death_with_covid_yes=="T")
stset end_date ,  origin(start_date) failure(failure==1)
keep if _st==1

*secondary outcome: within 90 day*
gen start_date_90d=start_date+90
gen failure_90d=(death_date!=.&death_date<=min(study_end_date,start_date_90d))
tab drug failure_90d,m
gen end_date_90d=death_date if failure_90d==1
replace end_date_90d=min(study_end_date, start_date_90d) if failure_90d==0
format %td  end_date_90d  start_date_90d
gen failure_90d_covid=(failure_90d==1&death_with_covid_yes=="T")


*secondary outcome: time to discharge*
gen discharge_days=all_hosp_discharge-start_date
replace discharge_days=all_hosp_discharge2-start_date if  discharge_days==.| discharge_days<0
replace discharge_days=. if  discharge_days<0

gen event_discharge=0 if death_date!=.&(death_date-start_date)<=discharge_days
replace event_discharge=0 if (death_date==.|(death_date-start_date)>discharge_days)&discharge_days>28&discharge_days!=.
replace event_discharge=1 if (death_date==.|(death_date-start_date)>discharge_days)&discharge_days<=28&discharge_days!=.
gen discharge_missing=(event_discharge==.)
gen end_date_discharge=start_date+discharge_days if event_discharge==1
replace end_date_discharge=start_date_28 if event_discharge==0
format %td  end_date_discharge  



*covariates* 
replace oral_steroid_drugs_nhsd=. if oral_steroid_drug_nhsd_3m_count < 2 & oral_steroid_drug_nhsd_12m_count < 4
gen imid_nhsd=min(oral_steroid_drugs_nhsd, immunosuppresant_drugs_nhsd)
gen solid_cancer_ever=(cancer_opensafely_snomed_ever<=start_date)
gen haema_disease_ever=( haematological_disease_nhsd_ever <=start_date)
gen ckd_3_5=( ckd_stage_5_nhsd <=start_date|ckd_stages_3_5<=start_date|ckd_primis_stage==3|ckd_primis_stage==4|ckd_primis_stage==5|ckd3_icd10<=start_date|ckd4_icd10<=start_date|ckd5_icd10<=start_date)
gen liver_disease=( liver_disease_nhsd <=start_date)
gen imid=( imid_nhsd <=start_date)
gen immunosupression=( immunosupression_nhsd_new <=start_date)
gen solid_organ=( solid_organ_transplant_nhsd_new<=start_date)

sum covid_test_positive_date,f de
gen covid_test_positive_date_d=start_date - covid_test_positive_date
sum covid_test_positive_date_d,de
gen covid_test_positive_date_m=(covid_test_positive_date==.)
sum covid_test_positive_date00,f de
gen covid_reinfection=(min(covid_test_positive_date00,covid_primary_care_date00, previous_drug00 ///
     , previous_hosp00)<=(start_date-90))
tab covid_reinfection,m

rename previous_drug previous_drug_date
gen previous_drug=(previous_drug_date<start_date)
tab previous_drug,m

gen d_admission_treat=start_date-all_hosp_admission
replace d_admission_treat= start_date - all_hosp_admission2 if d_admission_treat==.
replace d_admission_treat=. if d_admission_treat<0
sum d_admission_treat,de
gen admission_missing=(d_admission_treat==.)

*demo*
gen age_group3=(age>=40)+(age>=60)
label define age_group3 0 "18-39" 1 "40-59" 2 ">=60" 
label values age_group3 age_group3
tab age_group3,m
egen age_5y_band=cut(age), at(18,25,30,35,40,45,50,55,60,65,70,75,80,85,110) label
tab age_5y_band,m
mkspline age_spline = age, cubic nknots(4)
gen age_50=(age>=50)
gen age_55=(age>=55)
gen age_60=(age>=60)

tab sex,m
rename sex sex_str
gen sex=0 if sex_str=="male"
replace sex=1 if sex_str=="female"
label define sex 0 "Male" 1 "Female"
label values sex sex

tab ethnicity,m
rename ethnicity ethnicity_with_missing_str
encode  ethnicity_with_missing_str ,gen(ethnicity_with_missing)
label list ethnicity_with_missing
gen ethnicity=ethnicity_with_missing
replace ethnicity=. if ethnicity_with_missing_str=="Missing"
label values ethnicity ethnicity_with_missing
gen White=1 if ethnicity_with_missing_str=="White"
replace White=0 if ethnicity_with_missing_str!="White"&ethnicity!=.
gen ethnicity_missing=(ethnicity==.)

tab imd_quintile,m
rename imd_quintile imd_with_missing_str
encode  imd_with_missing_str ,gen(imd)
replace imd=. if imd==6
gen imd_1=(imd==1)
gen imd_with_missing=imd
replace imd_with_missing=9 if imd==.
gen imd_missing=(imd==.)

tab region_nhs,m
rename region_nhs region_nhs_str 
encode  region_nhs_str ,gen(region_nhs)
label list region_nhs

tab region_covid_therapeutics ,m
rename region_covid_therapeutics region_covid_therapeutics_str
encode  region_covid_therapeutics_str ,gen( region_covid_therapeutics )
label list region_covid_therapeutics
tab region_nhs,m
tab region_covid_therapeutics,m
*tab region_nhs region_covid_therapeutics,m

tab rural_urban,m
replace rural_urban=. if rural_urban<1
replace rural_urban=3 if rural_urban==4
replace rural_urban=5 if rural_urban==6
replace rural_urban=7 if rural_urban==8
tab rural_urban,m
gen rural_urban_with_missing=rural_urban
replace rural_urban_with_missing=99 if rural_urban==.

*comor*
sum bmi,de
replace bmi=. if bmi<10|bmi>60
rename bmi bmi_all
*latest BMI within recent 10 years*
gen bmi=bmi_all if bmi_date!=.&bmi_date>=start_date-365.25*10&(age+((bmi_date-start_date)/365.25)>=18)
gen bmi_group4=(bmi>=25)+(bmi>=30.0)+(bmi>=35.0) if bmi!=.
label define bmi 0 "underweight/normal" 1 "overweight" 2 "obese" 3 "severely obese"
label values bmi_group4 bmi
gen bmi_g4_with_missing=bmi_group4
replace bmi_g4_with_missing=9 if bmi_group4==.
gen bmi_g3=bmi_group4
replace bmi_g3=1 if bmi_g3==0
label values bmi_g3 bmi
gen bmi_25=(bmi>=25) if bmi!=.
gen bmi_30=(bmi>=30) if bmi!=.
gen bmi_missing=(bmi==.)

rename diabetes diabetes_str
gen diabetes=(diabetes_str=="T")
tab diabetes,m
rename chronic_cardiac_disease chronic_cardiac_disease_str
gen chronic_cardiac_disease=(chronic_cardiac_disease_str=="T")
tab chronic_cardiac_disease,m
rename hypertension hypertension_str
gen hypertension=(hypertension_str=="T")
tab hypertension,m
rename chronic_respiratory_disease chronic_respiratory_disease_str
gen chronic_respiratory_disease=(chronic_respiratory_disease_str=="T")
tab chronic_respiratory_disease,m

*vac *
tab covid_vaccination_count,m
gen vaccination_status=0 if covid_vaccination_count==0|covid_vaccination_count==.
replace vaccination_status=1 if covid_vaccination_count==1
replace vaccination_status=2 if covid_vaccination_count==2
replace vaccination_status=3 if covid_vaccination_count>=3&covid_vaccination_count!=.
label define vac 0 "Un-vaccinated" 1 "One vaccination" 2 "Two vaccinations" 3 "Three or more vaccinations"
label values vaccination_status vac
gen vaccination_0=1 if vaccination_status==0
replace vaccination_0=0 if vaccination_status>0
*Time between last vaccination and treatment*
gen d_vaccinate_treat=start_date - last_vaccination_date
sum d_vaccinate_treat,de
gen month_after_vaccinate=ceil(d_vaccinate_treat/30)
tab month_after_vaccinate,m
gen month_after_vaccinate_missing=month_after_vaccinate
replace month_after_vaccinate_missing=99 if month_after_vaccinate_missing==.
*calendar time*
gen calendar_day=start_date - mdy(7,1,2021)
sum calendar_day,de
gen calendar_month=ceil((start_date-mdy(7,1,2021))/30)
tab calendar_month,m
gen omicron=(start_date>=mdy(12,6,2021))
tab omicron,m
gen 




*descriptives by drug groups*
local i = 3 
foreach var in age bmi {
		quietly summarize `var'  if drug==0 
		putexcel A`i' = "`var'" ///
        B`i' = "`r(mean)' (`r(sd)')" 
		quietly summarize `var'  if drug==1 
		putexcel C`i' = "`r(mean)' (`r(sd)')" 
		quietly summarize `var' 
		putexcel D`i' = "`r(mean)' (`r(sd)')" 
		quietly ttest `var' , by( drug )
		putexcel E`i' = `r(p)'  	
    local i = `i' + 1
}

local i = 5 
foreach var in imd covid_test_positive_date_d calendar_day d_vaccinate_treat d_admission_treat discharge_days {
    quietly summarize `var'  if drug==0,de
	putexcel A`i' = "`var'" ///
	B`i' = "`r(p50)' (`r(p25)'-`r(p75)')" 
    quietly summarize `var'  if drug==1 ,de
    putexcel C`i' = "`r(p50)' (`r(p25)'-`r(p75)')" 	
    quietly summarize `var' ,de
    putexcel D`i' = "`r(p50)' (`r(p25)'-`r(p75)')" 
	quietly ranksum `var' , by( drug )
	local result = 2 * (1 - normal(abs(`r(z)')))	
	putexcel E`i' =  `result'
    local i = `i' + 1
}

local row = 11
foreach var in sex ethnicity imd rural_urban region_nhs region_covid_therapeutics age_group3 solid_cancer_ever ///
     haema_disease_ever  ckd_3_5 liver_disease imid immunosupression solid_organ ///
	 bmi_group4 diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease vaccination_status ///
	 omicron previous_drug covid_reinfection failure failure_covid failure_90d failure_90d_covid  ///
	  event_discharge discharge_missing ///
	 covid_test_positive_date_m imd_missing bmi_missing ethnicity_missing admission_missing {

tab `var' drug , matcell(freq) matrow(labels) chi2
putexcel A`row' = "`var'"  E`row' = "`r(p)'"
forval i = 1/`=rowsof(freq)' {
    putexcel F`row' = labels[`i',1]
	if freq[`i',1] <= 7 {
        local result = "<=7"
    }
    else {
        local result = round(freq[`i',1],5)
    }
    putexcel     B`row' =  "`result'"
	if freq[`i',2] <= 7 {
        local result = "<=7"
    }
    else {
        local result = round(freq[`i',2],5)
    }	
    putexcel     C`row' = "`result'"
	if freq[`i',1]+freq[`i',2] <= 7 {
        local result = "<=7"
    }
    else {
        local result = round(freq[`i',1]+freq[`i',2],5)
    }		
	putexcel 	D`row' = "`result'"
    local row = `row' + 1
}
}

stset end_date ,  origin(start_date) failure(failure==1)
keep if _st==1
tab failure drug,m col
*stratified Cox, missing values as a separate category*
mkspline calendar_day_spline = calendar_day, cubic nknots(4)
stcox drug age_spline* i.sex calendar_day_spline* solid_cancer_ever haema_disease_ever ckd_3_5 liver_disease imid immunosupression solid_organ diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease b1.bmi_g4_with_missing b6.ethnicity_with_missing b5.imd_with_missing i.vaccination_status covid_reinfection previous_drug, strata(region_covid_therapeutics)
matrix b = e(b) 
matrix se = e(V)
local drug_coef = exp(b[1,1])
local drug_se = sqrt(se[1,1])
local lower_ci = exp(b[1,1] - 1.96 * `drug_se')
local upper_ci = exp(b[1,1] + 1.96 * `drug_se')
local p=2 * (1 - normal(abs(b[1,1]/`drug_se')))
putexcel A`row' = "HR"  B`row'="`drug_coef' (`lower_ci'-`upper_ci')"  C`row'="`p'"


*counts by calendar month*
putexcel set "./output/descriptives2.xlsx", replace
putexcel A1=("Variable") B1=("tocilizumab") C1=("sarilumab") D1=("total") 

tab calendar_month drug , matcell(freq) matrow(labels)
putexcel A2 = "calendar_month"  
local row = 2
forval i = 1/`=rowsof(freq)' {
	if freq[`i',1] <= 7 {
        local result = "<=7"
    }
    else {
        local result = round(freq[`i',1],5)
    }
    putexcel     B`row' =  "`result'"
	if freq[`i',2] <= 7 {
        local result = "<=7"
    }
    else {
        local result = round(freq[`i',2],5)
    }	
    putexcel     C`row' = "`result'"
	if freq[`i',1]+freq[`i',2] <= 7 {
        local result = "<=7"
    }
    else {
        local result = round(freq[`i',1]+freq[`i',2],5)
    }		
	putexcel 	D`row' = "`result'"
    local row = `row' + 1
}

save ./output/main.dta, replace

clear
import excel ./output/descriptives.xlsx, sheet("Sheet1") firstrow
export delimited using ./output/descriptives.csv, replace

clear
import excel ./output/descriptives2.xlsx, sheet("Sheet1") firstrow
export delimited using ./output/descriptives2.csv, replace

log close

