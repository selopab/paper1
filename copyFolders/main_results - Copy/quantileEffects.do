* NPV results
/*

This do file creates several results: 
1) followup table with NPV
2) kdensities for imputed values

*/
********************************************************************************
global int=3.43			/* Interest rate */
global int2 = 2.22		/* Interest rate (ROBUSTNESS)*/
global perc_pag=.30		/* Percentage of payment to private lawyer */
global pago_pub=0		/* Payment to public lawyer */
global pago_pri=2000	
global courtcollect=1.0 /* Recovery / Award ratio for court judgments */
global winsorize=95 	/* winsorize level for NPV levels */

local controls i.abogado_pub numActores
//local imputedControls i.tipodeabogadoImputed
********************************************************************************
use "$scaleup\DB\scaleup_operation.dta", clear
rename ao anio
rename expediente exp
merge m:1 junta exp anio using "$sharelatex\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)
merge m:1 junta exp anio using "$scaleup\DB\scaleup_predictions.dta", nogen keep(1 3)

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

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub ///
trabajador_base liq_total_laudo_avg numActores

gen phase=2
save "$paper\DB\temp_p2", replace

use "$sharelatex/DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment

gen liq_total_laudo_avg =  liq_laudopos * (prob_laudopos/prob_laudos)

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub ///
trabajador_base liq_total_laudo_avg numActores

append using "$paper\DB\temp_p2"
replace phase=1 if missing(phase)

*cap drop tipodeabogado
*ren abogado_pub tipodeabogado
*replace fechadem = fecha_treatment -90 if missing(fechadem)

*keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment ///
*p_actor abogado_pub fechadem

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
drop if treatment==3

sort junta exp anio fecha
by junta exp anio: gen renglon = _n
keep if renglon==1

//Merge nuevas iniciales-----------------------------

merge 1:1 junta exp anio using "$sharelatex\p1_w_p3\out\inicialesP1Faltantes_wod.dta", ///
keep(1 3) gen(_mNuevasIniciales) keepusing(abogado_pubN numActoresN)
//keepusing(fechaDemanda_M tipodeabogado_M trabajadordeconfianza_M numActoresN)

//gen fechaDemanda = date(fecha, "YMD")
gen fechaDemanda = fecha

foreach var in numActores abogado_pub{
replace `var' = `var'N if missing(`var') & !missing(`var'N)
}


gen missingCasefiles = missing(numActores) | missing(abogado_pub)

*replace trabajador_base = abs(trabajadordeconfianza_M-1) if !missing(trabajadordeconfianza_M)
tostring anio, gen(s_anio)
gen fechaArtificial = s_anio + "-01-" + "01"
gen fechaDemandaImputed = fechaDemanda
replace fechaDemandaImputed = date(fechaArtificial, "YMD") if missing(fechaDemandaImputed) | fechaDemandaImputed <0 

gen trabajador_baseImputed = trabajador_base
replace trabajador_baseImputed = 2 if trabajador_baseImputed ==0
replace trabajador_baseImputed = 0 if missing(trabajador_baseImputed)

*gen tipodeabogadoImputed = tipodeabogado
*replace tipodeabogadoImputed = 0 if missing(tipodeabogadoImputed)

bysort anio exp: gen order = _n

*Drop conciliator observations
*drop if treatment==3
********************************************************************************

merge 1:1 junta exp anio using "$sharelatex\DB\seguimiento_m5m.dta", keep(1 3)
replace cant_convenio = cant_convenio_exp if missing(cant_convenio)
replace cant_convenio = cant_convenio_ofirec if missing(cant_convenio)
replace cant_convenio = 0 if modo_termino_expediente == 6 & missing(cant_convenio)
merge 1:1 junta exp anio using "$sharelatex\Terminaciones\Data\followUps2020.dta", gen(merchados) keep(1 3)
merge 1:1 junta exp anio using "$sharelatex\DB\missingPredictionsP1_wod", gen(_mMissingPreds) keep(1 3)
replace liq_total_laudo_avg = liq_total_laudo_avgM if missing(liq_total_laudo_avg)
/*
--------------+-----------------------------------
1)           AG |         18        5.70        5.70
2)     CONTINUA |         98       31.01       36.71
3)     CONVENIO |        130       41.14       77.85
4) DESISTIMIENTO |          5        1.58       79.43
5) INCOMPETENCIA |          5        1.58       81.01
6)        LAUDO |         60       18.99      100.00
--------------+-----------------------------------
*/


gen fechaTerminoAux = date("$S_DATE", "DMY") //date("$dateCode", "YMD") 
format fechaTerminoAux

replace modoTermino = modo_termino_expediente if missing(modoTermino)
replace modoTermino = 2 if missing(modoTermino)

egen fechaTermino = rowmax(fecha_termino_ofirec fecha_termino_exp fechaOfirec fechaExp)
*replace fechaTermino = fecha_termino_exp if missing(fechaTermino)
*replace fechaTermino = fechaOfirec if missing(fechaTermino)
*replace fechaTermino = fechaTerminoAux if missing(fechaTermino) | modo_termino_expediente==2 | fechaTermino<0
*
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

replace fechaTermino = fechaTerminoAux if missing(fechaTermino) 
format fechaTermino %td
gen months=(fechaTermino-fecha)/30
replace months = 0 if months<0
gen npv=.
gen npv_robust = .

replace npv=(ganancia/(1+(${int})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npv=(ganancia/(1+(${int})/100)^months)-${pago_pub} if abogado_pub==1 

replace npv_robust=(ganancia/(1+(${int2})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npv_robust=(ganancia/(1+(${int2})/100)^months)-${pago_pub} if abogado_pub==1 

*replace npv = 0 if missing(npv) & !missing(modoTermino)

gen asinhNPV = asinh(npv)

gen gananciaImputed = ganancia
replace gananciaImputed = liq_total_laudo_avg if  ganancia==0 & modoTermino==2

///!missing(liq_total_laudo_avg) 
//& !missing(liq_laudopos) 

gen npvImputed=.
replace npvImputed=(gananciaImputed/(1+(${int})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npvImputed=(gananciaImputed/(1+(${int})/100)^months)-${pago_pub} if abogado_pub==1

gen npvImputed_robust=.
replace npvImputed_robust=(gananciaImputed/(1+(${int2})/100)^months)*(1-${perc_pag})-${pago_pri} if abogado_pub==0
replace npvImputed_robust=(gananciaImputed/(1+(${int2})/100)^months)-${pago_pub} if abogado_pub==1

*replace npvImputed = 0 if missing(npv) & !missing(modoTermino)

gen asinhNPVImputed = asinh(npvImputed)
gen asinhNPVImputed_robust = asinh(npvImputed_robust)

**************
* CW Coding 29 August 2020 *
**************
replace numActores=1 if numActores==0
replace numActores=3 if numActores>3 & numActores~=.
replace anio=2010 if anio<2010
/*

quantile Regressions

*/
reg asinhNPV  i.treatment##i.p_actor if !missing(asinhNPVImputed), robust cluster(fecha)
local intEffect = _b[2.treatment#1.p_actor]
local calcEffect = _b[2.treatment]

matrix results = J(99,6,.)
//  6 cols are: (1) quantile, (2) betaCalc, (3) std errorCalc, (4) InteractionCoef, (5) Interaction std, (6) Degrees of freedom

forvalues i = 0.01 (.01) 1{
   di `i'
	qreg2 asinhNPV  i.treatment##i.p_actor if !missing(asinhNPVImputed), q(`i') cluster(fecha)
	matrix coefs =  e(b)
	matrix vars = e(V)
	local df = e(df_r)
	
	local calculatorCoef = coefs[1,2]
	local calculatorVar = sqrt(vars[2,2])
	
	local interactionCoef = coefs[1,8]
	local interactionVar = sqrt(vars[8,8])
	
	local index = `i'*100
	
	matrix results[`index',1] = `index'
	matrix results[`index',2] = `calculatorCoef'
	matrix results[`index',3] = `calculatorVar'
	matrix results[`index',4] = `interactionCoef'
	matrix results[`index',5] = `interactionVar'
	matrix results[`index',6] = `df'
} 


	matrix colnames results = "percentiles" "betaCalculator" "sebetaCalculator" "betaInteraction" "sebetaInteraction" "df"
	
	preserve
	
	clear
	svmat results, names(col) 

	// Confidence intervals (95%)
	local alpha = .05 // for 95% confidence intervals
	gen rcap_loCalc = betaCalculator - invttail(df,`=`alpha'/2')*sebetaCalculator
	gen rcap_hiCalc = betaCalculator + invttail(df,`=`alpha'/2')*sebetaCalculator
	
	gen rcap_loInter = betaInteraction - invttail(df,`=`alpha'/2')*sebetaInteraction
	gen rcap_hiInter = betaInteraction + invttail(df,`=`alpha'/2')*sebetaInteraction
	gen regBetaInteraction = `intEffect'
	gen regBetaCalculator = `calcEffect'
	
		
	#delimit ;
	twoway (line rcap_hiInter percentiles, lpattern(dash) lcolor(gs10) lwidth(medthick)) ||
		  (line rcap_loInter percentiles, lpattern(dash) lcolor(gs10) lwidth(medthick)) ||
		  (line betaInteraction percentiles, lwidth(medthick) lpattern(solid) color(black)) ||
		  (line regBetaInteraction percentiles, lpattern(longdash_dot) lcolor(gs5) lwidth(medthick)) ,
		   legend(order(1 "95% C.I." 3 "Quantile treatment effect" 4 "OLS")) xtitle("Length of case (days)") title("Interaction effect on NPV of earnings") 
		  subtitle("Imputing 0") ytitle("NPV Inverse Hyperbolyc Sine") scheme(s2mono) graphregion(color(white)) yline(0, lcolor(gs3)); 
	#delimit cr		
	graph export "$sharelatex/Figures/quantilesInteraction.pdf", replace 

	
	#delimit ;
	twoway (line rcap_hiCalc percentiles, lpattern(dash) lcolor(gs10) lwidth(medthick)) ||
		  (line rcap_loCalc percentiles, lpattern(dash) lcolor(gs10) lwidth(medthick)) ||
		  (line betaCalculator percentiles, lwidth(medthick) lpattern(solid) color(black)) ||
		  (line regBetaCalculator percentiles, lpattern(longdash_dot) lcolor(gs5) lwidth(medthick)) ,
		   legend(order(1 "95% C.I." 3 "Quantile treatment effect" 4 "OLS")) xtitle("Length of case (days)") title("Calculator effect on NPV of earnings") 
		  subtitle("Imputing 0") ytitle("NPV Inverse Hyperbolyc Sine") scheme(s2mono) graphregion(color(white)) yline(0, lcolor(gs3)); 
	#delimit cr		
	graph export "$sharelatex/Figures/quantilesCalculator.pdf", replace 

	restore
	
	/* Model w/calculator only */
	
	reg asinhNPV  i.treatment if !missing(asinhNPVImputed), robust cluster(fecha)
	local calcEffect = _b[2.treatment]


	qreg2 asinhNPV  i.treatment if !missing(asinhNPVImputed), q(.5) cluster(fecha)
	matrix coefs =  e(b)
	matrix vars = e(V)


	matrix results = J(99,4,.)
//  4 cols are: (1) quantile, (2) betaCalc, (3) std errorCalc, (4) InteractionCoef

	forvalues i = 0.01 (.01) 1{
	   di `i'
		qreg2 asinhNPV  i.treatment if !missing(asinhNPVImputed), q(`i') cluster(fecha)
		matrix coefs =  e(b)
		matrix vars = e(V)
		local df = e(df_r)
		
		local calculatorCoef = coefs[1,2]
		local calculatorVar = sqrt(vars[2,2])

		local index = `i'*100
		
		matrix results[`index',1] = `index'
		matrix results[`index',2] = `calculatorCoef'
		matrix results[`index',3] = `calculatorVar'
		matrix results[`index',4] = `df'
	} 


	matrix colnames results = "percentiles" "betaCalculator" "sebetaCalculator" "df"
	
	clear
	svmat results, names(col) 

	// Confidence intervals (95%)
	local alpha = .05 // for 95% confidence intervals
	gen rcap_loCalc = betaCalculator - invttail(df,`=`alpha'/2')*sebetaCalculator
	gen rcap_hiCalc = betaCalculator + invttail(df,`=`alpha'/2')*sebetaCalculator
	gen regBetaCalculator = `calcEffect'
	
	#delimit ;
	twoway (line rcap_hiCalc percentiles, lpattern(dash) lcolor(gs10) lwidth(medthick)) ||
		  (line rcap_loCalc percentiles, lpattern(dash) lcolor(gs10) lwidth(medthick)) ||
		  (line betaCalculator percentiles, lwidth(medthick) lpattern(solid) color(black)) ||
		  (line regBetaCalculator percentiles, lpattern(longdash_dot) lcolor(gs5) lwidth(medthick)) ,
		   legend(order(1 "95% C.I." 3 "Quantile treatment effect" 4 "OLS")) xtitle("Length of case (days)") title("Calculator effect on NPV of earnings") 
		  subtitle("Imputing 0") ytitle("NPV Inverse Hyperbolyc Sine") scheme(s2mono) graphregion(color(white)) yline(0, lcolor(gs3)); 
	#delimit cr		
	graph export "$sharelatex/Figures/quantilesCalculator_simpleModel.pdf", replace 
