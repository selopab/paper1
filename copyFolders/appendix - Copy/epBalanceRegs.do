/*Table C7:  Balance regression on characteristics conditional on employee present*/
/*
The table shows results of regressions with the specification 
$y_i = \alpha_t + \sum_{j = 1,2}\beta_{j} T_{j} + \epsilon_{i}$, 
where j refers to the treatment assignment ${calculator, conciliator}$.
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

keep junta exp anio seconcilio convenio_2m convenio_5m fecha junta fecha treatment p_actor ///
abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem abogado_pub
gen phase=2
tempfile temp_p2
save `temp_p2'

use "$sharelatex/DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)

=======

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename (tratamientoquelestoco expediente) (treatment exp)
>>>>>>> cleanAppendixC

keep junta exp anio seconcilio convenio_2m convenio_5m fecha junta fecha treatment p_actor ///
abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem abogado_pub
append using `temp_p2'
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

********************************************************************************

*CONDITIONAL ON EP
keep if p_actor==1


tab junta, gen(junta)

for var abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem junta1-junta5: egen Xs=std(X)

local bvc abogado_pubs gens trabajador_bases c_antiguedads salario_diarios horas_sems

	eststo clear
	
	
foreach var of varlist `bvc' {	
	eststo: reg `var' i.treatment junta2s-junta5s if treatment!=0, robust  cluster(fecha)
	estadd scalar Erre=e(r2)	
	estadd scalar F_stat=e(F)
	estadd local Junta="YES"
	}
		
		
	*************************
	esttab using "$sharelatex/Tables/reg_results/ep_balance.csv", se star(* 0.1 ** 0.05 *** 0.01) b(a2) ///
	scalars("Erre R-squared" "F_stat F_stat" "Junta Court dummies") replace 

		

