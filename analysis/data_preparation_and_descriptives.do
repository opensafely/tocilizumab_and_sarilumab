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


*save ./output/main.dta, replace
log close




