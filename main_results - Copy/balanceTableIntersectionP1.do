/*Table 4׺  Treatment Effects*/
/*
This table estimates the main treatment effects for both experimental phases.
Columns (1)-(8)
*/
********************************************************************************

local varsBalance abogado_pub sal_base gen c_antiguedad p_actor p_demandado

use "$sharelatex/DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0 | missing(tratamientoquelestoco)
rename tratamientoquelestoco treatment

*keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub
*append using "$paper\DB\temp_p2"
*replace phase=1 if missing(phase)


*Follow-up (more than 5 months)
merge m:1 junta exp anio using "$sharelatex\DB\seguimiento_m5m.dta", nogen keep(1 3)

*Settlement
replace convenio_2m=seconcilio if missing(convenio_2m)
replace convenio_2m=seconcilio if seconcilio==1

replace convenio_5m=convenio_2m if missing(convenio_5m)
replace convenio_5m=convenio_2m if convenio_2m==1

replace convenio_m5m=convenio_5m if missing(convenio_m5m)
replace convenio_m5m=convenio_5m if convenio_5m==1
********************************************************************************

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
drop if T1T2==1 & treatment == 1
*46 drops
*drop if T1T3==1
*31 drops
*drop if T2T3==1
*8 drops
drop if TAll==1

*bysort junta exp anio: gen DuplicatesPostdrop=_N

*44 drops
sort junta exp anio fecha
bysort junta exp anio: keep if _n==1
********************************************************************************

*Drop conciliator observations
drop if treatment==3

gen asignacion = .
replace asignacion = 1 if T1T3 ==1
replace asignacion = 2 if T2T3 ==1



*SS

putexcel set "$sharelatex/Tables/SS_intersectionTreatmentes.xlsx", sheet("SS") modify
orth_out `varsBalance' , ///
				by(asignacion) se vce(robust)   bdec(2) 
qui putexcel B2=matrix(r(matrix)) 
local varsBalance abogado_pub sal_base gen c_antiguedad p_actor p_demandado

local i=2	
foreach var of varlist `varsBalance' {
	qui putexcel A`i'=("`var'") 
	qui reg `var' i.asignacion, robust cluster(fecha)
	qui test ( 1.asignacion=0 ) (2.asignacion=0)
	qui putexcel D`i'=(`r(p)') 

	local i=`i'+2
	}
	
qui count if asignacion == 1
qui putexcel B14 = `r(N)'
qui count if asignacion == 2
qui putexcel C14 = `r(N)'