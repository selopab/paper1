/*Figure 3. :  Time Duration*/
/*
The figure uses the historical data (5005 casefiles) to plot the cumulative 
distribution of the duration of the case in months, by type of ending, for the 
70\% of cases concluded by the end of 2015.
*/

********************************************************************************
	*DB: Calculator:5005
use  "$sharelatex\DB\scaleup_hd.dta", clear


*Months after initial sue
gen fechadem=date(fecha_demanda,"YMD")
gen fechater=date(fecha_termino,"YMD")
gen case_duration=(fechater-fechadem)/30

gen perc_con_5005=.
gen perc_cr_5005=.
gen perc_exp_5005=.
gen perc_dro_5005=.
gen time=.

forvalues j=1/4 {
	count if modo_termino==`j'
	local obs`j'=`r(N)'
	}
	
*Proportion of cases ended at time `i' by end mode	
local n=1
forvalues i=0(0.25)60 {

	*Conciliation
	qui count if  case_duration<=`i' & modo_termino==1
	qui replace perc_con_5005=`r(N)'/`obs1' in `n'
	*Court ruling
	qui count if  case_duration<=`i' & modo_termino==3
	qui replace perc_cr_5005=`r(N)'/`obs3' in `n'
	*Expiry
	qui count if  case_duration<=`i' & modo_termino==4
	qui replace perc_exp_5005=`r(N)'/`obs4' in `n'
	*Drop
	qui count if  case_duration<=`i' & modo_termino==2
	qui replace perc_dro_5005=`r(N)'/`obs2' in `n'
	
	qui replace time=`i' in `n'
	local n=`n'+1
	
	}

	
drop if time==.


*HD	
twoway 	(line perc_con_5005 time, lwidth(medthick) lpattern(solid)) ///
		(line perc_cr_5005 time, lwidth(medthick) lpattern(dash) color(navy)) ///
		(line perc_exp_5005 time, lwidth(medthick) lpattern(dot) color(gs10)) ///
		(line perc_dro_5005 time, lwidth(medthick) lpattern(dash_dot)) ///
	, graphregion(color(none)) scheme(s2mono)  ///
	xtitle("Months after initial sue") ytitle("Percentage") ///
	xlabel(0(10)60) ///
	legend(order(1 "Conciliation" 2 "Court ruling" 3 "Expiry" 4 "Drop")) 
graph export "$sharelatex/Figures/caseending_overtime.pdf", replace 

