* TREATMENT EFFECTS - DURATION
/*Table 4׺  Treatment Effects*/
/*
This table estimates the main treatment effects  (ITT) for both experimental phases.
Columns (1)-(8)
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
gen fecha_filing=date(fecha_demanda, "YMD")
format fecha_filing %td

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor ///
abogado_pub fecha_filing fecha_treat 
gen phase=2
save "$paper\DB\temp_p2", replace

use "$sharelatex/DB/pilot_operation.dta" , clear	
replace junta=7 if missing(junta)
rename expediente exp

*Presence employee
replace p_actor=(p_actor==1)
drop if tratamientoquelestoco==0
rename tratamientoquelestoco treatment
gen fecha_filing=date(fecha_demanda, "YMD")
format fecha_filing %td
drop if fecha_filing < date("01-01-2006", "DMY")
ren fecha_treatment fecha_treat

keep seconcilio convenio_2m convenio_5m fecha junta exp anio fecha treatment p_actor ///
abogado_pub fecha_filing fecha_treat
append using "$paper\DB\temp_p2"
replace phase=1 if missing(phase)


*Follow-up (more than 5 months)
merge m:1 junta exp anio using "$sharelatex\DB\seguimiento_m5m.dta", nogen
merge m:1 junta exp anio using "$sharelatex\Terminaciones\Data\followUps2020.dta", gen(merchados) keep(1 3)

*Settlement
replace convenio_2m=seconcilio if missing(convenio_2m)
replace convenio_2m=seconcilio if seconcilio==1

replace convenio_5m=convenio_2m if missing(convenio_5m)
replace convenio_5m=convenio_2m if convenio_2m==1

replace convenio_m5m=convenio_5m if missing(convenio_m5m)
replace convenio_m5m=convenio_5m if convenio_5m==1
replace convenio_m5m = 1 if modoTermino == 3
replace convenio_m5m = 0 if modoTermino != 3 & !missing(modoTermino)
replace seconcilio = 0 if modoTermino != 3 & !missing(modoTermino)

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

merge 1:1 junta exp anio using "$sharelatex\p1_w_p3\out\inicialesP1Faltantes_wod.dta", ///
keep(1 3) gen(_mNuevasIniciales) keepusing(fechaDemanda_M tipodeabogado_M trabajadordeconfianza_M)
//

egen fechaTermino = rowmax(fecha_termino_ofirec fecha_termino_exp fechaOfirec fechaExp)

gen length=fechaTermino-fecha_filing
gen timeToTreat = fecha_treat - fecha_filing
gen lengthSinceTreat = fechaTermino - fecha_treat

/* Graphs */
twoway (kdensity npv_pub, xline(0, lpattern(dash) lcolor(gs10) lwidth(medthick)) lwidth(medthick) lpattern(solid) color(black)) ///
		(kdensity npv_pri1, lwidth(medthick) lpattern(dash) color(gs6)) ///
		(kdensity npv_pri2, lwidth(medthick) lpattern(dot) color(gs9)) ///
		(kdensity npv_pri3, lwidth(medthick) lpattern(dash_dot) color(gs12)) , ///
		scheme(s2mono) graphregion(color(white)) xtitle("NPV") ytitle("Density") ///
		legend(order(1 "Pub" 2 "Pri 2000" 3 "Pri 1000" 4 "Pri 500") rows(1))  ///
		name(pdf, replace) title("PDF")
		
		
#delimit ;
*Graph only lower 95%. Settlement;
twoway (kdensity length if treatment==2 & length<10000 & length>=0 & abogado_pub==0,  lwidth(medthick) lpattern(solid) color(black)) ||
		(kdensity length if treatment==1 & length<10000 & length>=0 & abogado_pub==0, lpattern(dash) lcolor(gs10) lwidth(medthick)), 
		legend(lab(1 "Treatment") lab(2 "Control")) xtitle("Length of case (days)") title("Length of All Cases") subtitle("Cases with valid filing dates") ytitle("kdensity") scheme(s2mono) graphregion(color(white));
#delimit cr
graph export "$sharelatex/Figures/lengthAll.pdf", replace 

#delimit ;
*Graph only lower 95%. Settlement;
twoway (kdensity length if treatment==2 & length<10000 & length>=0 & (modoTermino==3) & abogado_pub==0 ,  lwidth(medthick) lpattern(solid) color(black)) ||
		(kdensity length if treatment==1 & length<10000 & length>=0 & modoTermino==3 & abogado_pub==0, lpattern(dash) lcolor(gs10) lwidth(medthick)), 
		legend(lab(1 "Treatment") lab(2 "Control")) xtitle("Length of case (days)") title("Length of Settled Cases") subtitle("Cases with valid filing dates") ytitle("kdensity") scheme(s2mono) graphregion(color(white));
#delimit cr
graph export "$sharelatex/Figures/lengthSettlement.pdf", replace 


#delimit ;
*Graph only lower 95%. Court ruling;
twoway (kdensity length if treatment==2 & length<10000 & length>=0 & (modoTermino==6) & abogado_pub==0 ,  lwidth(medthick) lpattern(solid) color(black)) ||
		(kdensity length if treatment==1 & length<10000 & length>=0 & modoTermino==6 & abogado_pub==0, lpattern(dash) lcolor(gs10) lwidth(medthick)),
		legend(lab(1 "Treatment") lab(2 "Control")) xtitle("Length of case (days)") title("Length of Cases with Court Judgments") subtitle("Cases with valid filing dates") ytitle("kdensity") scheme(s2mono) graphregion(color(white));
#delimit cr
graph export "$sharelatex/Figures/lengthRuling.pdf", replace 


/* Regs */

reg length i.treatment i.p_actor i.treatment#i.p_actor  if abogado_pub==0 & length<10000 , robust cluster(fecha)
qui test 2.treatment + 2.treatment#1.p_actor = 0
local testInteraction=`r(p)'
qui su length if e(sample) & p_actor ==1
local IntMean=r(mean)
qui su length if e(sample)
local DepVarMean=r(mean)
outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsDuration.xls", replace ctitle("All casefiles")  ///
addtext(Court Dummies, Yes) addstat(Dependent Variable Mean, `DepVarMean', Interaction Mean,`IntMean', test interaction,`testInteraction') ///
keep(2.treatment 1.p_actor 2.treatment#1.p_actor )
	
reg length i.treatment i.p_actor i.treatment#i.p_actor  if abogado_pub==0 & length<10000 & modoTermino~=2, robust cluster(fecha)
qui test 2.treatment + 2.treatment#1.p_actor = 0
local testInteraction=`r(p)'
qui su length if e(sample) & p_actor ==1
local IntMean=r(mean)
qui su length if e(sample)
local DepVarMean=r(mean)
outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsDuration.xls", append ctitle("Non-continuing casefiles")  ///
addtext(Court Dummies, Yes) addstat(Dependent Variable Mean, `DepVarMean', Interaction Mean,`IntMean', test interaction,`testInteraction') ///
keep(2.treatment 1.p_actor 2.treatment#1.p_actor )

reg length i.treatment i.p_actor i.treatment#i.p_actor timeToTreat if abogado_pub==0 & length<10000 , robust cluster(fecha)
qui test 2.treatment + 2.treatment#1.p_actor = 0
local testInteraction=`r(p)'
qui su length if e(sample) & p_actor ==1
local IntMean=r(mean)
qui su length if e(sample)
local DepVarMean=r(mean)
outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsDuration.xls", append ctitle("All casefiles")  ///
addtext(Court Dummies, Yes) addstat(Dependent Variable Mean, `DepVarMean', Interaction Mean,`IntMean', test interaction,`testInteraction') ///
keep(2.treatment 1.p_actor 2.treatment#1.p_actor timeToTreat)
	
reg length i.treatment i.p_actor i.treatment#i.p_actor timeToTreat if abogado_pub==0 & length<10000 & modoTermino~=2, robust cluster(fecha)
qui test 2.treatment + 2.treatment#1.p_actor = 0
local testInteraction=`r(p)'
qui su length if e(sample) & p_actor ==1
local IntMean=r(mean)
qui su length if e(sample)
local DepVarMean=r(mean)
outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsDuration.xls", append ctitle("Non-continuing casefiles")  ///
addtext(Court Dummies, Yes) addstat(Dependent Variable Mean, `DepVarMean', Interaction Mean,`IntMean', test interaction,`testInteraction') ///
keep(2.treatment 1.p_actor 2.treatment#1.p_actor timeToTreat)


/* Balance on time to treat */

reg timeToTreat i.treatment i.p_actor i.treatment#i.p_actor  if abogado_pub==0 & timeToTreat<1500 & timeToTreat>0, robust cluster(fecha)
qui test 2.treatment + 2.treatment#1.p_actor = 0
local testInteraction=`r(p)'
qui su length if e(sample) & p_actor ==1
local IntMean=r(mean)
qui su length if e(sample)
local DepVarMean=r(mean)
outreg2 using  "$sharelatex/Tables/reg_results/timeToTreat.xls", replace ctitle("All casefiles")  ///
addtext(Court Dummies, Yes) addstat(Dependent Variable Mean, `DepVarMean', Interaction Mean,`IntMean', test interaction,`testInteraction') ///
keep(2.treatment 1.p_actor 2.treatment#1.p_actor )
	
reg timeToTreat i.treatment i.p_actor i.treatment#i.p_actor  if abogado_pub==0 & timeToTreat<1500 & timeToTreat>0 & modoTermino~=2, robust cluster(fecha)
qui test 2.treatment + 2.treatment#1.p_actor = 0
local testInteraction=`r(p)'
qui su length if e(sample) & p_actor ==1
local IntMean=r(mean)
qui su length if e(sample)
local DepVarMean=r(mean)
outreg2 using  "$sharelatex/Tables/reg_results/timeToTreat.xls", append ctitle("Non-continuing casefiles")  ///
addtext(Court Dummies, Yes) addstat(Dependent Variable Mean, `DepVarMean', Interaction Mean,`IntMean', test interaction,`testInteraction') ///
keep(2.treatment 1.p_actor 2.treatment#1.p_actor )


/* Regs with treatment*/

reg lengthSinceTreat i.treatment i.p_actor i.treatment#i.p_actor  if abogado_pub==0 & length<10000 , robust cluster(fecha)
qui test 2.treatment + 2.treatment#1.p_actor = 0
local testInteraction=`r(p)'
qui su length if e(sample) & p_actor ==1
local IntMean=r(mean)
qui su length if e(sample)
local DepVarMean=r(mean)
outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsDurationSinceTreatment.xls", replace ctitle("All casefiles")  ///
addtext(Court Dummies, Yes) addstat(Dependent Variable Mean, `DepVarMean', Interaction Mean,`IntMean', test interaction,`testInteraction') ///
keep(2.treatment 1.p_actor 2.treatment#1.p_actor )
	
reg lengthSinceTreat i.treatment i.p_actor i.treatment#i.p_actor  if abogado_pub==0 & length<10000 & modoTermino~=2, robust cluster(fecha)
qui test 2.treatment + 2.treatment#1.p_actor = 0
local testInteraction=`r(p)'
qui su length if e(sample) & p_actor ==1
local IntMean=r(mean)
qui su length if e(sample)
local DepVarMean=r(mean)
outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsDurationSinceTreatment.xls", append ctitle("Non-continuing casefiles")  ///
addtext(Court Dummies, Yes) addstat(Dependent Variable Mean, `DepVarMean', Interaction Mean,`IntMean', test interaction,`testInteraction') ///
keep(2.treatment 1.p_actor 2.treatment#1.p_actor )

reg lengthSinceTreat i.treatment i.p_actor i.treatment#i.p_actor timeToTreat if abogado_pub==0 & length<10000 , robust cluster(fecha)
qui test 2.treatment + 2.treatment#1.p_actor = 0
local testInteraction=`r(p)'
qui su length if e(sample) & p_actor ==1
local IntMean=r(mean)
qui su length if e(sample)
local DepVarMean=r(mean)
outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsDurationSinceTreatment.xls", append ctitle("All casefiles")  ///
addtext(Court Dummies, Yes) addstat(Dependent Variable Mean, `DepVarMean', Interaction Mean,`IntMean', test interaction,`testInteraction') ///
keep(2.treatment 1.p_actor 2.treatment#1.p_actor timeToTreat)
	
reg lengthSinceTreat i.treatment i.p_actor i.treatment#i.p_actor timeToTreat if abogado_pub==0 & length<10000 & modoTermino~=2, robust cluster(fecha)
qui test 2.treatment + 2.treatment#1.p_actor = 0
local testInteraction=`r(p)'
qui su length if e(sample) & p_actor ==1
local IntMean=r(mean)
qui su length if e(sample)
local DepVarMean=r(mean)
outreg2 using  "$sharelatex/Tables/reg_results/treatment_effectsDurationSinceTreatment.xls", append ctitle("Non-continuing casefiles")  ///
addtext(Court Dummies, Yes) addstat(Dependent Variable Mean, `DepVarMean', Interaction Mean,`IntMean', test interaction,`testInteraction') ///
keep(2.treatment 1.p_actor 2.treatment#1.p_actor timeToTreat)

