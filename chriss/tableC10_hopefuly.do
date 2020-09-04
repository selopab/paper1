* TREATMENT EFFECTS - ITT - con merge a faltanP1
/*Table 4׺  Treatment Effects*/
/*
This table estimates the main treatment effects for both experimental phases.
Columns (1)-(8)
*/
********************************************************************************
****************************
local controls i.abogado_pub numActores i.missingCasefiles i.junta i.phase i.anio


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
gen fecha_filing=date(fecha_demanda, "YMD")
format fecha fecha_filing %td

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha_filing treatment p_actor abogado_pub ///
trabajador_base liq_total_convenio liq_total_laudo numActores

gen phase=2
save "temp_p2", replace

use "$sharelatex/DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment

gen fecha_filing=date(fecha_demanda, "YMD")
format  fecha_filing %td

gen liq_total_laudo =  liq_laudopos 

//gen liq_convenio_laudo_avg =  liq_convenio * prob_convenio
ren liq_convenio liq_total_convenio
keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha_filing treatment p_actor abogado_pub ///
trabajador_base liq_total_convenio liq_total_laudo numActores

append using "temp_p2"
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

********************************************************************************
merge 1:1 junta exp anio using "$sharelatex\DB\seguimiento_m5m.dta", keep(1 3)
replace cant_convenio = cant_convenio_exp if missing(cant_convenio)
replace cant_convenio = cant_convenio_ofirec if missing(cant_convenio)
replace cant_convenio = 0 if modo_termino_expediente == 6 & missing(cant_convenio)
merge 1:1 junta exp anio using "$sharelatex\Terminaciones\Data\followUps2020.dta", gen(merchados) keep(1 3)
merge 1:1 junta exp anio using "$sharelatex\DB\missingPredictionsP1_wod", gen(_mMissingPreds) keep(1 3)

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

gen ratioGananciaConvenio = ganancia/liq_total_convenio

gen length=fechaTermino-fecha_filing
gen timeTillTreat = fecha - fecha_filing
/*
//exit
#delimit ;
*Graph only lower 95%;
twoway kdensity ratioGananciaConvenio if treatment==2 & ratioGananciaConvenio<3.5 & modoTermino==3 & abogado_pub==0 , lpattern(line) lcolor(blue) ||
		kdensity ratioGananciaConvenio if treatment==1 & ratioGananciaConvenio<3.5 & modoTermino==3 & abogado_pub==0, lpattern(line) lcolor(red)
		legend(lab(1 "Treatment") lab(2 "Control")) xtitle("Ratio of Amounts") title("Ratio of Actual and Predicted Settlement Amounts") subtitle("All hearings, truncated at 95%") ytitle("kdensity");
#delimit cr




#delimit ;
*Graph only lower 99%;
twoway (kdensity liq_total_convenio if treatment==2 & liq_total_convenio<125000  & phase==2 & modoTermino==3,  lwidth(medthick) lpattern(solid) color(black)) ||
		(kdensity liq_total_convenio if treatment==1 & liq_total_convenio<125000  & phase==2 & modoTermino==3, lpattern(dash) lcolor(gs10) lwidth(medthick)), 
		legend(lab(1 "Treatment") lab(2 "Control")) xtitle("Caluculator predicted settlement")  ytitle("kdensity")
		scheme(s2mono) graphregion(color(white));
#delimit cr

graph export "$sharelatex/Figures/CalculatorVSettlements.pdf", replace 
//title("Calculator Predicted Amounts for All Cases") subtitle("By treatment, truncated at 99%")

#delimit ;
*Graph only lower 95%;
twoway kdensity length if treatment==2 & length<10000  & abogado_pub==0  & phase==2  , lpattern(line) lcolor(blue) ||
		kdensity length if treatment==1 & length<10000  & abogado_pub==0   & phase==2 , lpattern(line) lcolor(red)
		legend(lab(1 "Treatment") lab(2 "Control")) xtitle("Length of case (days)") title("Length of Cases, All Outcomes") subtitle("Cases with valid filing dates") ytitle("kdensity");
#delimit cr

#delimit ;
*Graph only lower 95%;
twoway kdensity length if treatment==2 & length<10000 & (modoTermino==3) & abogado_pub==0 , lpattern(line) lcolor(blue) ||
		kdensity length if treatment==1 & length<10000 & modoTermino==3 & abogado_pub==0, lpattern(line) lcolor(red)
		legend(lab(1 "Treatment") lab(2 "Control")) xtitle("Length of case (days)") title("Length of Settled Cases") subtitle("Cases with valid filing dates") ytitle("kdensity");
#delimit cr

#delimit ;
*Graph only lower 95%;
twoway kdensity length if treatment==2 & length<10000 & (modoTermino==6) & abogado_pub==0 & phase==2 , lpattern(line) lcolor(blue) ||
		kdensity length if treatment==1 & length<10000 & modoTermino==6 & abogado_pub==0 & phase==2, lpattern(line) lcolor(red)
		legend(lab(1 "Treatment") lab(2 "Control")) xtitle("Length of case (days)") title("Length of Cases Ending in Judgment") subtitle("Cases with valid filing dates") ytitle("kdensity");
#delimit cr

#delimit ;
*Graph only lower 95%;
twoway kdensity length if treatment==2 & length<10000 & (modoTermino==6) & abogado_pub==0 & p_actor==0, lpattern(line) lcolor(blue) ||
		kdensity length if treatment==1 & length<10000 & modoTermino==6 & abogado_pub==0 & p_actor==0, lpattern(line) lcolor(red)
		legend(lab(1 "Treatment") lab(2 "Control")) xtitle("Length of case (days)") title("Length of Cases with Court Judgments") subtitle("Cases where plainiff was NOT at hearing") ytitle("kdensity");
#delimit cr


*Table "Duration", column 1
gen l2 = length/30
reg l2 i.treatment i.p_actor i.treatment#i.p_actor `controls' if abogado_pub==0 & length<10000 , robust cluster(fecha)

reg length i.treatment i.p_actor i.treatment#i.p_actor  `controls' if abogado_pub==0 & length<10000  & modoTermino~=2, robust cluster(fecha)  
reg length i.treatment i.p_actor i.treatment#i.p_actor i.abogado_pub numActores if abogado_pub==0 & length<10000  & modoTermino~=2, robust cluster(fecha)  
*/
replace numActores = 3 if numActores >3
replace anio = 2010 if anio < 2010
gen missingCasefiles = missing(numActores) | missing(abogado_pub)

/* Por lo que entiendo esto genera la última tabla del appendix C*/

reg length i.treatment i.p_actor i.treatment#i.p_actor `controls' if  length>0  & length < 2300, robust cluster(fecha)
	qui test 2.treatment + 2.treatment#1.p_actor = 0
	local testInteraction=`r(p)'
	qui su p_actor if e(sample)
	local IntMean=r(mean)
	qui su seconcilio if e(sample)
	local DepVarMean=r(mean)
	outreg2 using  "$sharelatex/Tables/reg_results/durationTE.xls", replace ctitle("OLS")  ///
	addtext(Casefile Controls, Yes, Includes settled, Yes) addstat(Dependent Variable Mean, `DepVarMean', Interaction Mean,`IntMean', test interaction,`testInteraction') ///
	keep(2.treatment 1.p_actor 2.treatment#1.p_actor) dec(3) 
*Bigger cases are sped up regardless of whether the plaintiff is present or not; The smaller cases are sped up only when the plaintiff is present.
gen settle=modoTermino==3 if modoTermino~=.
*Hazard model
gen unresolved = modoTermino!=2 if modoTermino~=. // failure = not completed
stset length, failure(unresolved)

*Table "Duration", column 2
stcox  i.treatment i.p_actor i.treatment#i.p_actor `controls' if length<2300 & length>0 ,  robust nohr cluster(fecha)
outreg2 using  "$sharelatex/Tables/reg_results/durationTE.xls", append ctitle("Cox")  ///
	addtext(Casefile Controls, Yes, Includes settled, Yes) ///
	keep(2.treatment 1.p_actor 2.treatment#1.p_actor) dec(3) 
stcox  i.treatment i.p_actor i.treatment#i.p_actor `controls' if length<2300 & length>0  & modoTermino != 3,  robust nohr cluster(fecha)
outreg2 using  "$sharelatex/Tables/reg_results/durationTE.xls", append ctitle("Cox")  ///
	addtext(Casefile Controls, Yes, Includes settled, No) ///
	keep(2.treatment 1.p_actor 2.treatment#1.p_actor) dec(3) 
 
