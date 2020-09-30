/*
SUBSET LIST OF MISSING CASEFILES
*/
********************************************************************************

use "$sharelatex/DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment

bysort junta exp anio: gen DuplicatesPredrop=_N
forvalues i=1/3{
	gen T`i'_aux=[treatment==`i'] 
	bysort junta exp anio: egen T`i'=max(T`i'_aux)
}

gen T1T2=[T1==1 & T2==1]
gen T1T3=[T1==1 & T3==1]
gen T2T3=[T2==1 & T3==1]
gen TAll=[T1==1 & T2==1 & T3==1]

replace T1T2=0 if TAll==1
replace T1T3=0 if TAll==1
replace T2T3=0 if TAll==1

*32 drops
*drop if T1T2==1
*46 drops
drop if T1T3==1
*31 drops
drop if T2T3==1
*8 drops
drop if TAll==1

bysort junta exp anio: gen DuplicatesPostdrop=_N

*44 drops
sort junta exp anio fecha
bysort junta exp anio: keep if _n==1
********************************************************************************

*Drop conciliator observations
drop if treatment==3

tostring exp, replace
gen expediente = "7" + "_" + exp  + "_" + s_anio

tempfile tempPilot
save `tempPilot', replace

*******************************************************************************

import excel "$sharelatex/Raw/missingCasefilesPilot", clear firstr
gen expediente = subinstr(Expediente, "-", "_",.)
drop if Pudodescargarse==1
merge 1:1 expediente using `tempPilot', keepusing(expediente) keep(3) nogen 

drop Pudodescargarse Capturista Expediente

export excel "$sharelatex/out/inicialesP1aBuscar.xlsx", firstr(var) replace


