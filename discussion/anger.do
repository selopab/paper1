* TREATMENT EFFECTS - ITT
/*Table 4׺  Treatment Effects*/
/*
This table estimates the main treatment effects  (ITT) for both experimental phases.
Columns (1)-(8)
*/
********************************************************************************

*Set controls.
local controls i.anio i.junta i.phase i.numActores
use "$sharelatex/DB/Append Encuesta Inicial Actor.dta", clear
ren (A_6_3 A_5_9) (enojoActor willingToSettle)
keep folio enojoActor willingToSettle
tempfile encuestaP1
save `encuestaP1', replace

use "$scaleup\DB\scaleup_operation.dta", clear
rename ao anio
rename expediente exp
merge m:1 junta exp anio using "$sharelatex\DB\scaleup_casefiles_wod.dta" , nogen  keep(1 3)

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
ren ea3_enojo enojoActor

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub numActores enojoActor
gen phase=2
save "$paper\DB\temp_p2", replace

use "$sharelatex/DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename (tratamientoquelestoco ) (treatment )
merge m:1 folio using  `encuestaP1', keep(1 3) 
merge m:1 junta exp anio using "$sharelatex\p1_w_p3\out\inicialesP1Faltantes_wod.dta", ///
keep(1 3) gen(_mNuevasIniciales) keepusing(abogado_pubN numActoresN)
//keepusing(fechaDemanda_M tipodeabogado_M trabajadordeconfianza_M numActoresN)

//gen fechaDemanda = date(fecha, "YMD")
gen fechaDemanda = fecha

foreach var in numActores abogado_pub{
replace `var' = `var'N if missing(`var') & !missing(`var'N)
}


keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor abogado_pub numActores enojoActor  willingToSettle
append using "$paper\DB\temp_p2" 
replace phase=1 if missing(phase)

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

*Follow-up (more than 5 months)
merge 1:1 junta exp anio using "$sharelatex\DB\seguimiento_m5m.dta", nogen keep(1 3)
merge 1:1 junta exp anio using "$sharelatex\Terminaciones\Data\followUps2020.dta", gen(merchados) keep(1 3)


*Settlement
replace convenio_2m=seconcilio if missing(convenio_2m)
replace convenio_2m=seconcilio if seconcilio==1

replace convenio_5m=convenio_2m if missing(convenio_5m)
replace convenio_5m=convenio_2m if convenio_2m==1

replace convenio_m5m=convenio_5m if missing(convenio_m5m)
replace convenio_m5m=convenio_5m if convenio_5m==1
replace convenio_m5m = 1 if modoTermino == 3
//replace convenio_m5m = 0 if modoTermino != 3 & !missing(modoTermino)
replace seconcilio = 0 if modoTermino != 3 & !missing(modoTermino)

replace anio = 2010 if anio < 2010
replace numActores = 3 if numActores>3

gen angry = 4-enojoActor
label define angryLabel 0 "Not angry" 1 "Somewhat angry" 2 "Mildly angry" 3 "Very angry"
lab val angry angryLabel

gen isAngry = angry>2
replace isAngry = . if missing(angry)
gen treatedAngry = (treatment - 1 )*isAngry

replace numActores = 3 if numActores>3
replace anio =2010 if anio < 2010

//Regressions
* 1) same day settlement
	reg seconcilio i.isAngry `controls', robust  cluster(fecha)
	outreg2 using  "$sharelatex/Tables/reg_results/angerRegressions.xls" if !missing(angry), replace ctitle("Same day settlement") ///
	addtext(Court Dummies, Yes, Casefile Controls, Yes) dec(3) keep(1.isAngry 2.treatment treatedAngry)
	
	reg seconcilio i.treatment `controls', robust  cluster(fecha)
	outreg2 using  "$sharelatex/Tables/reg_results/angerRegressions.xls" if !missing(angry), append ctitle("Same day settlement") ///
	addtext(Court Dummies, Yes, Casefile Controls, Yes) dec(3) keep(1.isAngry 2.treatment treatedAngry)
	
	reg seconcilio i.isAngry i.treatment `controls', robust  cluster(fecha)
	outreg2 using  "$sharelatex/Tables/reg_results/angerRegressions.xls" if !missing(angry), append ctitle("Same day settlement") ///
	addtext(Court Dummies, Yes, Casefile Controls, Yes) dec(3) keep(1.isAngry 2.treatment treatedAngry)

	reg seconcilio i.treatment i.isAngry treatedAngry `controls', robust  cluster(fecha)
	outreg2 using  "$sharelatex/Tables/reg_results/angerRegressions.xls" if !missing(angry), append ctitle("Same day settlement") ///
	addtext(Court Dummies, Yes, Casefile Controls, Yes) dec(3) keep(1.isAngry 2.treatment treatedAngry)
	
* 1) LR day settlement
	reg convenio_m5m i.isAngry `controls', robust  cluster(fecha) 
	outreg2 using  "$sharelatex/Tables/reg_results/angerRegressionsLR.xls" , replace ctitle("Long run settlement") ///
	addtext(Court Dummies, Yes, Casefile Controls, Yes) dec(3) keep(1.isAngry 2.treatment treatedAngry)
	
	reg convenio_m5m i.treatment `controls', robust  cluster(fecha)
	outreg2 using  "$sharelatex/Tables/reg_results/angerRegressionsLR.xls" if !missing(angry), append ctitle("Long run settlement") ///
	addtext(Court Dummies, Yes, Casefile Controls, Yes) dec(3) keep(1.isAngry 2.treatment treatedAngry)
	 
	reg convenio_m5m i.isAngry i.treatment `controls', robust  cluster(fecha)
	outreg2 using  "$sharelatex/Tables/reg_results/angerRegressionsLR.xls", append ctitle("Long run settlement") ///
	addtext(Court Dummies, Yes, Casefile Controls, Yes) dec(3) keep(1.isAngry 2.treatment treatedAngry)

	reg convenio_m5m i.treatment i.isAngry treatedAngry `controls', robust  cluster(fecha)
	outreg2 using  "$sharelatex/Tables/reg_results/angerRegressionsLR.xls", append ctitle("Long run settlement") ///
	addtext(Court Dummies, Yes, Casefile Controls, Yes) dec(3) keep(1.isAngry 2.treatment treatedAngry)
	
* 2) willingToSettle 
gen lsettAmmount = log(willingToSettle + 1)
	reg lsettAmmount i.isAngry `controls', robust  cluster(fecha)
	outreg2 using  "$sharelatex/Tables/reg_results/angerRegressionsSettlementAmmount.xls", replace ctitle("Log of settlement ammount required") ///
	addtext(Court Dummies, Yes, Casefile Controls, Yes) dec(3) keep(1.isAngry 2.treatment treatedAngry)
	
	reg lsettAmmount i.treatment `controls', robust  cluster(fecha)
	outreg2 using  "$sharelatex/Tables/reg_results/angerRegressionsSettlementAmmount.xls", append ctitle("Log of settlement ammount required") ///
	addtext(Court Dummies, Yes, Casefile Controls, Yes) dec(3) keep(1.isAngry 2.treatment treatedAngry)
	
	reg lsettAmmount i.isAngry i.treatment `controls', robust  cluster(fecha)
	outreg2 using  "$sharelatex/Tables/reg_results/angerRegressionsSettlementAmmount.xls", append ctitle("Log of settlement ammount required") ///
	addtext(Court Dummies, Yes, Casefile Controls, Yes) dec(3) keep(1.isAngry 2.treatment treatedAngry)

	reg lsettAmmount i.treatment i.isAngry treatedAngry `controls', robust  cluster(fecha)
	outreg2 using  "$sharelatex/Tables/reg_results/angerRegressionsSettlementAmmount.xls", append ctitle("Log of settlement ammount required") ///
	addtext(Court Dummies, Yes, Casefile Controls, Yes) dec(3) keep(1.isAngry 2.treatment treatedAngry)



