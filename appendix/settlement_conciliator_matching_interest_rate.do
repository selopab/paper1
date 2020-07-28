
global int=3.43			/* Interest rate */
global perc_pag=.30		/* Percentage of payment to private lawyer */
global pago_pub=0		/* Payment to public lawyer */
global pago_pri=2000	/* Payment to private lawyer */


*******************************PILOT 1 DATA*************************************
forvalues tasa=1/100 {
di `tasa'
qui {
use "$sharelatex/DB/pilot_operation.dta" , clear	
qui merge m:1 folio using "$sharelatex\DB\pilot_casefiles_wod.dta" , nogen  keep(1 3)
ren(tratamientoquelestoco expediente) (exp treatment)

merge m:1 junta exp anio using "$sharelatex\DB\seguimiento_m5m.dta", keep(1 3)
merge m:1 junta exp anio using "$sharelatex\Terminaciones\Data\followUps2020.dta", gen(merchados) keep(1 3)

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

*Not in experiment
drop if treatment==0


*Outliers
foreach var of varlist min_ley c1_cantidad_total_pagada_conveni comp_esp {
	cap drop perc
	xtile perc=`var', nq(90)
	replace `var'=. if perc>=86
	}
	
	
*********
*Settlement amount for 'treated' files
keep if (c1_se_concilio==1 & calculator==1)


*Date imputation
replace fecha_con=fechadem if missing(fecha_con)
replace fechadem=fecha_con if missing(fechadem)
gen ganancia = cant_convenio 
replace ganancia = cant_convenio_exp if missing(ganancia)
replace ganancia = cant_convenio_ofirec if missing(ganancia)
replace ganancia = cantidadPagada if missing(ganancia) & cantidadPagada != 0 //liq_convenio
replace ganancia = cantidadOtorgada if missing(ganancia)

replace ganancia = 0 if [modoTermino == 4 & missing(ganancia)]| modoTermino==5 | [modoTermino==6  & missing(ganancia)] ///
| [modoTermino==1  & missing(ganancia)]

//egen tmp = rowmax(cantidaddedesistimiento c1_cantidad_total_pagada_conveni c2_cantidad_total_pagada_conveni)
//replace ganancia = tmp if modoTermino== 3 & missing(ganancia)
*replace ganancia = liq_convenio if modoTermino== 3 & missing(ganancia)
//drop tmp
replace ganancia = . if modoTermino == 2
replace abogado_pub = 0 if missing(abogado_pub)

// Ganancia imputing 0
replace ganancia = 0 if missing(ganancia) //& modoTermino==2

egen fechaTermino = rowmax(fecha_termino_ofirec fecha_termino_exp fechaOfirec fechaExp)

format fechaTermino %td
gen months=(fechaTermino-fecha)/30
gen npv=.

replace npv=(ganancia/(1+(${int})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npv=(ganancia/(1+(${int})/100)^months)-${pago_pub} if abogado_pub==1 

keep npv fecha_con ///
/*Calculator prediction*/  	 comp_esp ///
/*Entitlement by law*/       min_ley ///
/*Basic variable contrlols*/ abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem ///
	months

*Homologation
rename fecha_con fecha
gen mes=month(fecha)
gen anio=year(fecha)

qui merge m:1 mes anio using "$sharelatex/Raw/inpc.dta", nogen keep(1 3) 

*NO DEFLATION
*NPV at constant prices (June 2016)
*replace npv=(npv/inpc)*118.901

*Treated dummy
gen treat=1

*Save file to append it with HD data
tempfile temp_conc_p1
save `temp_conc_p1'

*******************************PILOT 2 DATA*************************************
use "$scaleup/DB/scaleup_operation.dta" , clear	
rename ao anio
rename expediente exp
qui merge m:1 junta exp anio using "$scaleup\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)
qui merge m:1 junta exp anio using "$scaleup\DB\scaleup_predictions.dta", nogen keep (1 3)

merge m:1 junta exp anio using "$sharelatex\DB\seguimiento_m5m.dta", keep(1 3)
merge m:1 junta exp anio using "$sharelatex\Terminaciones\Data\followUps2020.dta", gen(merchados) keep(1 3)

gen fecha=date(fecha_lista,"YMD")
format fecha %td
gen treatment=.
replace treatment=2 if dia_tratamiento==1
replace treatment=1 if dia_tratamiento==0
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

*Expected compensation
gen comp_esp=liq_total_laudo_avg


*Outliers
foreach var of varlist min_ley cantidad_convenio comp_esp {
	cap drop perc
	xtile perc=`var', nq(100)
	replace `var'=. if perc>=95
	}
	
	
	
*********
*Settlement amount for 'treated' files
keep if (convenio==1 & (dia_tratamiento==1))


*Date 
gen fecha_con=date(fecha_lista, "YMD")
gen fechadem=date(fecha_demanda, "YMD")

*Date imputation
replace fecha_con=fechadem if missing(fecha_con)
replace fechadem=fecha_con if missing(fechadem)
gen ganancia = cant_convenio 
replace ganancia = cant_convenio_exp if missing(ganancia)
replace ganancia = cant_convenio_ofirec if missing(ganancia)
replace ganancia = cantidadPagada if missing(ganancia) & cantidadPagada != 0 //liq_convenio
replace ganancia = cantidadOtorgada if missing(ganancia)

replace ganancia = 0 if [modoTermino == 4 & missing(ganancia)]| modoTermino==5 | [modoTermino==6  & missing(ganancia)] ///
| [modoTermino==1  & missing(ganancia)]

//egen tmp = rowmax(cantidaddedesistimiento c1_cantidad_total_pagada_conveni c2_cantidad_total_pagada_conveni)
//replace ganancia = tmp if modoTermino== 3 & missing(ganancia)
*replace ganancia = liq_convenio if modoTermino== 3 & missing(ganancia)
//drop tmp
replace ganancia = . if modoTermino == 2
replace abogado_pub = 0 if missing(abogado_pub)

// Ganancia imputing 0
replace ganancia = 0 if missing(ganancia) //& modoTermino==2

egen fechaTermino = rowmax(fecha_termino_ofirec fecha_termino_exp fechaOfirec fechaExp)

format fechaTermino %td
gen months=(fechaTermino-fecha)/30
gen npv=.

replace npv=(ganancia/(1+(${int})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npv=(ganancia/(1+(${int})/100)^months)-${pago_pub} if abogado_pub==1 


keep npv fecha_con ///
/*Calculator prediction*/  	 comp_esp ///
/*Entitlement by law*/       min_ley ///
/*Basic variable contrlols*/ abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem ///
	months
		
*Homologation
rename fecha_con fecha
gen mes=month(fecha)
gen anio=year(fecha)

qui merge m:1 mes anio using "$sharelatex/Raw/inpc.dta", nogen keep(1 3) 

*NO DEFLATION
*NPV at constant prices (June 2016)
*replace npv=(npv/inpc)*118.901

*Treated dummy
gen treat=1

*Save file to append it with HD data
tempfile temp_conc_p2
save `temp_conc_p2'

*********************************HD DATA****************************************
use  "$sharelatex\DB\scaleup_hd.dta", clear

*Compare with ONLY those who end case by COURT RULING
keep if modo_termino==3


*Dates
gen fechadem=date(fecha_demanda,"YMD")
gen fechater=date(fecha_termino,"YMD")

*NPV
gen months=(fechater-fechadem)/30
gen npv=.
replace npv=(liq_total_tope/(1+(100*((`tasa'/100+1)^(1/12)-1))/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npv=(liq_total_tope/(1+(100*((`tasa'/100+1)^(1/12)-1))/100)^months)-${pago_pub} if abogado_pub==1
drop if npv==.


keep npv fechadem ///
/*Calculator prediction*/  	 comp_esp_p1 ///
/*Entitlement by law*/       min_ley ///
/*Basic variable contrlols*/ abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem ///
	months

	
*Homologation
rename comp_esp_p1 comp_esp
rename fechadem fecha
gen mes=month(fecha)
gen anio=year(fecha)

qui merge m:1 mes anio using "$sharelatex/Raw/inpc.dta", nogen keep(1 3) 

*NO DEFLATION
*NPV at constant prices (June 2016)
*replace npv=(npv/inpc)*118.901



append using `temp_conc_p1'
append using `temp_conc_p2'
replace treat=0 if missing(treat)


*Residuals 
qui reg npv comp_esp ///
	/*Entitlement by law*/       min_ley ///
	/*Basic variable contrlols*/  abogado_pub gen trabajador_base c_antiguedad salario_diario horas_sem, r
predict npv_hat
gen residual=npv-npv_hat

		
*Trimming
foreach var of varlist residual {
	capture drop perc
	xtile perc=`var', nq(100)
	}



********************************************************************************
*************************************NN Match***********************************
********************************************************************************

forvalues i=1/3 {
	gen ate_`i'=.
	gen rcap_lo_`i'=.
	gen rcap_hi_`i'=.
}

local j=1
	
******************************************

 qui teffects nnmatch (npv  ///
	/*Calculator prediction*/  	 comp_esp ///
	/*Entitlement by law*/       min_ley ///
	/*Basic variable contrlols*/  gen trabajador_base c_antiguedad salario_diario horas_sem ///
					) (treat) if perc<95 , ///
	ematch(abogado_pub) biasadj( min_ley c_antiguedad salario_diario horas_sem)

mat def ate=e(b)
mat def var=e(V)
qui replace ate_1=ate[1,1] in `j'
qui replace rcap_lo_1=ate[1,1] - invttail(`e(N)'-1,0.025)*sqrt(var[1,1]) in `j'
qui replace rcap_hi_1=ate[1,1] + invttail(`e(N)'-1,0.025)*sqrt(var[1,1]) in `j'	
	
******************************************

qui teffects nnmatch (npv  ///
	/*Calculator prediction*/  	 comp_esp ///
	/*Entitlement by law*/       min_ley ///
	/*Basic variable contrlols*/  gen trabajador_base c_antiguedad salario_diario horas_sem ///
					) (treat) if perc<97 , ///
	ematch(abogado_pub) biasadj( min_ley c_antiguedad salario_diario horas_sem)

mat def ate=e(b)
mat def var=e(V)
qui replace ate_2=ate[1,1] in `j'
qui replace rcap_lo_2=ate[1,1] - invttail(`e(N)'-1,0.025)*sqrt(var[1,1]) in `j'
qui replace rcap_hi_2=ate[1,1] + invttail(`e(N)'-1,0.025)*sqrt(var[1,1]) in `j'	
	
******************************************
		
qui teffects nnmatch (npv  ///
	/*Calculator prediction*/  	 comp_esp ///
	/*Entitlement by law*/       min_ley ///
	/*Basic variable contrlols*/  gen trabajador_base c_antiguedad salario_diario horas_sem ///
					) (treat) if perc<99 , ///
	ematch(abogado_pub) biasadj( min_ley c_antiguedad salario_diario horas_sem)

mat def ate=e(b)
mat def var=e(V)
qui replace ate_3=ate[1,1] in `j'
qui replace rcap_lo_3=ate[1,1] - invttail(`e(N)'-1,0.025)*sqrt(var[1,1]) in `j'
qui replace rcap_hi_3=ate[1,1] + invttail(`e(N)'-1,0.025)*sqrt(var[1,1]) in `j'	

******************************************

tempfile temp_`tasa'
keep ate_* rcap_*
gen tasa=`tasa'
keep if _n==1
save `temp_`tasa''
}
}


*DB
use `temp_1', clear
forvalues tasa=2/100 {
append using `temp_`tasa''
}


gen zero=0

twoway rarea rcap_hi_3 rcap_lo_3 tasa, color(gs10)  || line ate_3 tasa, lwidth(thick) lpattern(solid) lcolor(black) || line zero tasa , lpattern(solid) lcolor(navy) ///
		, scheme(s2mono) graphregion(color(white))  ///
	xtitle("Interest rate (annually)") ytitle("ATE (Pesos)") legend(off) 	
graph export "$sharelatex\Figures\atematch_intrate.pdf", replace 
	

