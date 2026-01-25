********************************************************************************
*
*	Do-file:		plot.do
**
*	Programmed by:	Bang Zheng
*
* Open a log file
cap log close
log using ./logs/plot, replace t
clear

use ./output/main.dta

stset end_date ,  origin(start_date) failure(failure==1)
keep if _st==1

sts list, by(drug) saving(km_table, replace)

use "km_table.dta", clear

local threshold = 10

sort drug time

by drug: gen N =  begin[1]

by drug: gen cml_event = sum(fail)
gen cml_event_floor = floor(cml_event / `threshold') * `threshold'

by drug: gen n_event_new = cml_event_floor[_n] - cml_event_floor[_n-1]
by drug: replace n_event_new = cml_event_floor if _n == 1
replace n_event_new = max(n_event_new, 0)

by drug: gen cum_loss = sum(n_event_new + net_lost)

by drug: gen n_risk_new = N - (cum_loss[_n-1])
replace n_risk_new = N if missing(n_risk_new)
replace n_risk_new = max(n_risk_new, 1)

by drug: gen hazard = n_event_new / n_risk_new
by drug: gen surv_new = 1 if _n == 1
by drug: replace surv_new = surv_new[_n-1] * (1 - hazard) if _n > 1

save "km_processed.dta", replace

graph twoway ///
    (connected surv_new time if drug == 0, ///
        connect(stairstep)   msymbol(none)) ///
    (connected surv_new time if drug == 1, ///
        connect(stairstep)  lpattern(dash)  msymbol(none)), ///
    title("KM Curves with Threshold Applied") ///
    xtitle("Time (days)") ytitle("Survival probability") ///
    ylabel(0(0.2)1) ///
	legend(label(1 "Tocilizumab") label(2 "Sarilumab")) ///
    xsize(8) ysize(6)
    
graph export ./output/km_threshold.svg, as(svg) replace

log close



