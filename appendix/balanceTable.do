/*Table C6:  Balance table*/
/*
Balance table on basic and strategic variables.
*/

********************************************************************************

use "$scaleup\DB\scaleup_operation.dta", clear
rename ao anio
rename expediente exp
merge m:1 junta exp anio using "$scaleup\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)

*Notified casefiles
keep if notificado==1

*Homologation
gen treatment=.
replace treatment=2 if dia_tratamiento==1
replace treatment=1 if dia_tratamiento==0
rename convenio seconcilio
rename convenio_seg_2m convenio_2m 
rename convenio_seg_5m convenio_5m
gen fecha=date(fecha_lista,"YMD")
format fecha %td

gen phase=2
tempfile temp_p2
save `temp_p2'

**************

use "$sharelatex/DB/pilot_operation.dta" , clear
//duplicates drop folio, force
merge m:1 folio  using ///
	"$sharelatex\DB\pilot_casefiles_wod.dta", keep(1 3)
drop _merge	
replace junta=7 if missing(junta)
ren expediente exp
*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment

*Homologation
rename p_demandado p_dem
rename p_rdemandado p_rdem

append using `temp_p2', force
replace phase=1 if missing(phase)

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
*drop if T1T2==1 & treatment == 1
*46 drops
drop if T1T3==1
*31 drops
drop if T2T3==1
*8 drops
drop if TAll==1

*bysort junta exp anio: gen DuplicatesPostdrop=_N

*44 drops
*sort junta exp anio fecha
*bysort junta exp anio: keep if _n==1
********************************************************************************
*Drop conciliator observations
drop if treatment==3

sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1


local balance_var gen trabajador_base	horas_sem c_antiguedad abogado_pub	reinst	///
indem	salario_diario	sal_caidos	prima_antig	hextra	rec20  prima_dom  desc_sem ///
 desc_ob sarimssinf utilidades nulidad min_ley p_actor p_ractor p_dem p_rdem

************************************PHASE 1*************************************
********************************************************************************


orth_out `balance_var' ///
			if phase==1, ///
				by(treatment)  vce(robust)   bdec(3)  count pcompare stars
				
qui putexcel L5=matrix(r(matrix)) using "$sharelatex\Tables\Balance.xlsx", sheet("Balance") modify
 

************************************PHASE 2*************************************
********************************************************************************


orth_out `balance_var' ///
			if phase==2, ///
				by(treatment)  vce(robust)   bdec(3)  count pcompare stars
				
qui putexcel O5=matrix(r(matrix)) using "$sharelatex\Tables\Balance.xlsx", sheet("Balance") modify
	
************************************PHASE 1/2***********************************
********************************************************************************


orth_out `balance_var' if treatment!=3,  ///
				by(treatment)  vce(robust)   bdec(3)  count pcompare stars
				
qui putexcel R5=matrix(r(matrix)) using "$sharelatex\Tables\Balance.xlsx", sheet("Balance") modify
